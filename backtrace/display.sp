module backtrace

import term
import pathlib
import sys.libc

pub comptime const (
	// one_line_backtrace prints the stack trace frame by frame, each frame is
	// printed on a single line.
	one_line_backtrace = false
)

// display prints the stack trace to stderr, skipping the first [`skip`] frames.
//
// Example:
// ```
// backtrace.display(skip: 1)
// ```
//
// Marked as `no_inline` since we already increased [`skip`] by 1 to get nice
// stack trace. If we don't do this, sometimes (when [`display`] is inlined) we will
// get an extra frame for the [`capture`] function.
#[no_inline]
pub fn display(skip usize) {
	bt := capture() or { return }
	bt.display(skip)
}

// display prints the stack trace to stderr, skipping the first [`skip`] frames.
//
// Example:
// ```
// bt := backtrace.capture().unwrap()
// bt.display(skip: 1)
// ```
pub fn (b Backtrace) display(skip usize) {
	frames := b.frames(skip)
	print_frames(frames)
}

// format_one_line_with_length formats a frame in one line.
// It takes the max length of file name and function name as arguments to align
// the output.
//
// Example:
// ```text
// ./y/builtin/checked_arithmetic.sp:446            at i32.must_div      (0x10009d55b)
// ./dummy.sp:206                                   at main              (0x10009f277)
// ```
#[spawnfmt.skip]
pub fn (f &ResolvedFrame) format_one_line_with_length(max_file_name usize, max_func_name usize) -> string {
    name := term.colorize(term.yellow, f.demangled_name())
    path := term.colorize(term.bold, relative_path(f))
    pc := term.colorize(term.gray, f.pc.str())

    mut file_and_line := [250]u8{}
    libc.snprintf(&mut file_and_line[0], 250, c'%s:%-4d', path.c_str(), f.line)

    mut buffer := [500]u8{}
    len := libc.snprintf(&mut buffer[0], 500, c'%-*s at %-*s %s\n',
                              max_file_name + 20,
                              file_and_line,
                              max_func_name + 15,
                              name.c_str(), pc.c_str())
    return string.view_from_c_str_len(&buffer[0], len)
}

// format_two_line formats a frame in two lines.
//
// Example:
// ```text
// i32.must_div()
//   ./y/builtin/checked_arithmetic.sp:446 at 0x1009455ef
// main()
//   ./spawnlang/dummy.sp:206 at 0x10094727f
// ```
#[spawnfmt.skip]
pub fn (f &ResolvedFrame) format_two_line() -> string {
    name := term.colorize(term.yellow, f.demangled_name())
    path := term.colorize(term.bold, relative_path(f))
    pc := term.colorize(term.gray, f.pc.str())

    mut buffer := [500]u8{}
    len := libc.snprintf(&mut buffer[0], 500, c'%s()\n   %s:%d at %s\n',
        name.c_str(), path.c_str(), f.line, pc.c_str())
    return string.view_from_c_str_len(&buffer[0], len).clone()
}

fn relative_path(f &ResolvedFrame) -> string {
	return if f.filename.contains($SPAWN_ROOT) {
		f.relative_path_to(pathlib.join($SPAWN_ROOT, 'y'))
	} else {
		f.relative_path()
	}
}

// print_frames prints the stack trace to stderr.
fn print_frames(frames []ResolvedFrame) {
	comptime if one_line_backtrace {
		print_one_line_frames(frames)
	} $else {
		print_two_line_frames(frames)
	}
}

fn print_two_line_frames(frames []ResolvedFrame) {
	for frame in frames {
		eprint(frame.format_two_line())
	}
}

fn print_one_line_frames(frames []ResolvedFrame) {
	mut max_func_name := 0 as usize
	mut max_file_name := 0 as usize
	for frame in frames {
		demangled_name := frame.demangled_name()

		if demangled_name.len > max_func_name {
			max_func_name = demangled_name.len
		}
		if frame.filename.len > max_file_name {
			max_file_name = frame.filename.len
		}
	}

	for frame in frames {
		eprint(frame.format_one_line_with_length(max_file_name, max_func_name))
	}
}
