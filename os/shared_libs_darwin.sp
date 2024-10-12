module os

import mem
import sync

// This file is port of darwin implementation from
// https://github.com/gimli-rs/findshlibs
//
// Used in CPU profiler to block profiling of some
// segments of shared libraries.

#[include("<mach-o/loader.h>")]
#[include("<mach-o/dyld.h>")]

extern {
	const (
		MH_MAGIC    = 0
		MH_MAGIC_64 = 0
	)

	const (
		LC_SEGMENT    = 0
		LC_SEGMENT_64 = 0
	)

	#[typedef]
	struct mach_header {
		magic u32
		ncmds u32
	}

	#[typedef]
	struct mach_header_64 {
		ncmds u32
	}

	#[typedef]
	struct load_command {
		cmd     u32
		cmdsize u32
	}

	#[typedef]
	struct segment_command {
		cmd     u32
		cmdsize u32
		segname [16]u8
		vmaddr  u32
		vmsize  u32
	}

	#[typedef]
	struct segment_command_64 {
		cmd     u32
		cmdsize u32
		segname [16]u8
		vmaddr  u64
		vmsize  u64
	}

	fn _dyld_image_count() -> u32
	fn _dyld_get_image_header(index u32) -> *mach_header
	fn _dyld_get_image_vmaddr_slide(index u32) -> isize
	fn _dyld_get_image_name(index u32) -> *u8
}

pub var dyld_lock = sync.Mutex.new()

struct MachHeader32 {
	data &mach_header
}

struct MachHeader64 {
	data &mach_header_64
}

union MachHeader = MachHeader32 | MachHeader64

fn MachHeader.from_header_ptr(header *mach_header) -> ?MachHeader {
	magic := unsafe { header.magic }
	if magic == MH_MAGIC {
		return MachHeader32{ data: mem.assume_safe(header) }
	} else if magic == MH_MAGIC_64 {
		return MachHeader64{ data: mem.assume_safe((header as *mach_header_64)) }
	}
	return none
}

pub struct SharedLibrary {
	header MachHeader
	slide  usize
	name   string
}

pub fn SharedLibrary.new(header MachHeader, slide usize, name string) -> SharedLibrary {
	return SharedLibrary{ header: header, slide: slide, name: name }
}

pub fn (l SharedLibrary) name() -> string {
	return l.name
}

pub enum IterationControl {
	keep_going
	stop
}

pub fn SharedLibrary.each(callback fn (_ &SharedLibrary) -> IterationControl) {
	dyld_lock.lock()

	count := _dyld_image_count()

	for i in 0 .. count {
		header := _dyld_get_image_header(i)
		slide := _dyld_get_image_vmaddr_slide(i)
		name := _dyld_get_image_name(i)

		if name != nil {
			mach_header_ := MachHeader.from_header_ptr(header) or { continue }

			shlib := SharedLibrary.new(mach_header_, slide as usize, string.view_from_c_str(name))
			match callback(&shlib) {
				.keep_going => continue
				.stop => break
			}
		}
	}

	dyld_lock.unlock()
}

pub fn (l &SharedLibrary) virtual_memory_bias() -> usize {
	return l.slide
}

pub fn (l &SharedLibrary) segments() -> SegmentIter {
	match l.header {
		MachHeader32 => {
			num_commands := l.header.data.ncmds
			commands := unsafe { (l.header.data + 1) as *load_command }
			return SegmentIter.new(commands, num_commands as usize)
		}
		MachHeader64 => {
			num_commands := l.header.data.ncmds
			commands := unsafe { (l.header.data + 1) as *load_command }
			return SegmentIter.new(commands, num_commands as usize)
		}
	}

	return SegmentIter{}
}

pub struct Segment32 {
	data &segment_command
}

pub struct Segment64 {
	data &segment_command_64
}

union Segment = Segment32 | Segment64

pub fn (s &Segment) name() -> string {
	return match s {
		Segment32 => string.view_from_c_str(&s.data.segname[0])
		Segment64 => string.view_from_c_str(&s.data.segname[0])
	}
}

pub fn (s &Segment) is_code() -> bool {
	return s.name() == "__TEXT"
}

pub fn (s &Segment) actual_virtual_memory_address(lib &SharedLibrary) -> usize {
	svma := s.stated_virtual_memory_address()
	bias := lib.virtual_memory_bias()
	return svma + bias
}

pub fn (s &Segment) stated_virtual_memory_address() -> usize {
	return match s {
		Segment32 => s.data.vmaddr as usize
		Segment64 => s.data.vmaddr as usize
	}
}

pub fn (s &Segment) len() -> usize {
	return match s {
		Segment32 => s.data.vmsize as usize
		Segment64 => s.data.vmsize as usize
	}
}

pub struct SegmentIter {
	commands     *load_command
	num_commands usize
}

fn SegmentIter.new(commands *load_command, num_commands usize) -> SegmentIter {
	return SegmentIter{ commands: commands, num_commands: num_commands }
}

fn (i &mut SegmentIter) next() -> ?Segment {
	for i.num_commands > 0 {
		i.num_commands -= 1

		this_command := unsafe { mem.assume_safe(i.commands) }
		command_size := this_command.cmdsize as isize

		match this_command.cmd {
			LC_SEGMENT => {
				segment := mem.assume_safe(i.commands as *segment_command)
				i.commands = (i.commands as *u8 + command_size) as *load_command
				return Segment32{ data: segment }
			}
			LC_SEGMENT_64 => {
				segment := mem.assume_safe(i.commands as *segment_command_64)
				i.commands = (i.commands as *u8 + command_size) as *load_command
				return Segment64{ data: segment }
			}
			else => {
				// Some other kind of load command; skip to the next one.
				i.commands = (i.commands as *u8 + command_size) as *load_command
				continue
			}
		}
	}

	return none
}
