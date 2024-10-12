module fs

import io
import mem
import intrinsics
import sys.libc
import time

// CFile is a C file pointer.
// If you need to use a C file pointer in your code, you can use this type.
pub type CFile = *libc.FILE

// size returns the size of the file in bytes.
pub fn (f CFile) size() -> i64 {
	intrinsics.file_seek(f, 0, SeekMode.end as i32)
	size := intrinsics.file_tell(f)
	intrinsics.file_rewind(f)
	return size
}

// close closes the file.
pub fn (f CFile) close() -> ! {
	if intrinsics.file_close(f) != 0 {
		return error(FsError.from_errno('Could not close file: '))
	}
}

// File is thin wrapper around a C file pointer.
pub struct File {
	fd      CFile
	fno     i32
	is_open bool
}

// close closes the file.
pub fn (f &mut File) close() -> ! {
	f.is_open = false
	f.fd.close()!
}

// size returns the size of the file in bytes.
pub fn (f File) size() -> i64 {
	return f.fd.size()
}

// eof returns true if the current position is at the end of the file.
pub fn (f File) eof() -> bool {
	return intrinsics.file_eof(f.fd) != 0
}

// flush flushes the file.
pub fn (f File) flush() -> ![i32, FsError] {
	f.assert_file_open()!
	res := libc.fflush(f.fd)
	if res != 0 {
		return error(FsError.from_errno('Could not flush file: '))
	}

	return res
}

// read reads up to [`buf`]`.len` bytes from the file.
// Returns an [`FsError`] if the file could not be read.
pub fn (f &mut File) read(buf &mut []u8) -> ![i32, Error] {
	f.assert_file_open()!
	if buf.len == 0 {
		return 0
	}

	read := intrinsics.file_read(buf.data as *void, 1, buf.len as u32, f.fd) as i32
	if read <= 0 {
		if f.eof() {
			return error(io.EOF)
		}

		return error(FsError.from_errno('Could not read from file: '))
	}

	return read
}

// write writes the given `[]u8` to the file.
// Returns an [`FsError`] if the file could not be written to.
pub fn (f &mut File) write(data []u8) -> !i32 {
	f.assert_file_open()!
	if data.len == 0 {
		return data.len as i32
	}
	written := intrinsics.file_write(data.data as *void, 1, data.len as u32, f.fd)
	if written != data.len as u32 {
		return error(FsError.from_errno('Could not write to file: '))
	}
	return data.len as i32
}

// write_string writes the given string to the file.
// Returns an [`FsError`] if the file could not be written to.
pub fn (f &mut File) write_string(data string) -> !i32 {
	// SAFETY: bytes array is not leaked, it's only used for the duration of this function.
	//         so it's safe to use `bytes_no_copy` here.
	bytes := unsafe { data.bytes_no_copy() }
	return f.write(bytes)
}

pub fn (f &mut File) write_line(data string) -> !i32 {
	data_len := f.write_string(data)!
	new_line_len := f.write_string('\n')!
	return data_len + new_line_len
}

pub enum SeekMode {
	start
	current
	end
}

pub fn (f File) seek(pos i64, mode SeekMode) -> ![unit, FsError] {
	f.assert_file_open()!
	res := intrinsics.file_seek(f.fd, pos, mode as i32)
	if res == -1 {
		return error(FsError.from_errno('Could not seek file: '))
	}
}

pub fn (f File) tell() -> ![i64, FsError] {
	f.assert_file_open()!
	return intrinsics.file_tell(f.fd)
}

fn (f File) assert_file_open() -> ![unit, FsError] {
	if !f.is_open {
		return error(FsError{ msg: 'file is closed' })
	}
}

pub fn (f &mut File) read_bytes_until_newline(buf &mut []u8) -> !i32 {
	if buf.len == 0 {
		return error("buf should not be empty")
	}

	mut c := 0
	mut buf_ptr := 0
	mut nbytes := 0

	stream := f.fd

	for buf_ptr < buf.len {
		c = libc.getc(stream)
		match c {
			libc.EOF => {
				if libc.feof(stream) != 0 {
					return nbytes
				}
				if libc.ferror(stream) != 0 {
					return error('file read error')
				}
			}
			b`\n` => {
				buf[buf_ptr] = c as u8
				nbytes++
				return nbytes
			}
			else => {
				buf[buf_ptr] = c as u8
				buf_ptr++
				nbytes++
			}
		}
	}
	return nbytes
}

// read_file reads the file at path and returns its contents as a string.
// Returns an [`FsError`] if the file could not be read.
pub fn read_file(path string) -> ![string, FsError] {
	mut file := open_file(path, 'rb')!
	size := file.size()
	buf := mem.alloc(size + 1)
	read_bytes := intrinsics.file_read(buf as *void, 1, size as u32, file.fd)
	file.close() or {
		if err is FsError {
			return error(*err)
		}
		return error(FsError{ msg: 'Could not close file' })
	}
	return string.view_from_c_str_len(buf, read_bytes)
}

// read_bytes_from_file reads the file at path and returns its contents as a byte array.
// Returns an [`FsError`] if the file could not be read.
// The file is read in binary mode.
pub fn read_bytes_from_file(path string) -> ![[]u8, FsError] {
	mut file := open_file(path, 'rb')!
	size := file.size()
	buf := mem.alloc(size)
	read_bytes := intrinsics.file_read(buf as *void, 1, size as u32, file.fd)
	file.close() or {
		if err is FsError {
			return error(*err)
		}
		return error(FsError{ msg: 'Could not close file' })
	}
	return Array.from_ptr_no_copy[u8](buf, read_bytes)
}

// open_file opens a file at path in the given mode.
// Returns an [`FsError`] if the file could not be opened.
pub fn open_file(filename string, mode string) -> ![File, FsError] {
	fd := intrinsics.file_open(filename.data, mode.data) as CFile
	if fd == nil {
		msg := 'Could not open file `${filename}` in `${mode}` mode: '
		return error(FsError.from_errno(msg))
	}
	return File{
		fd: fd
		fno: fd.num()
		is_open: true
	}
}

// write_file writes the given content to the file at path.
// Returns an [`FsError`] if the file could not be written to.
// If the file does not exist, it will be created.
pub fn write_file(path string, content string) -> ![unit, FsError] {
	mut file := open_file(path, 'w')!
	file.write_string(content) or {
		if err is FsError {
			return error(*err)
		}
		return error(FsError{ msg: 'Could not write to file' })
	}
	file.close() or {
		if err is FsError {
			return error(*err)
		}
		return error(FsError{ msg: 'Could not close file' })
	}
}

// write_bytes_to_file writes the given bytes to the file at path.
// Returns an [`FsError`] if the file could not be written to.
// If the file does not exist, it will be created.
pub fn write_bytes_to_file(path string, data []u8) -> ![unit, FsError] {
	mut file := open_file(path, 'w')!
	file.write(data) or {
		if err is FsError {
			return error(*err)
		}
		return error(FsError{ msg: 'Could not write to file' })
	}
	file.close() or {
		if err is FsError {
			return error(*err)
		}
		return error(FsError{ msg: 'Could not close file' })
	}
}

// is_file returns true if the file at path exists and is a regular file.
pub fn is_file(path string) -> bool {
	return exists(path) && !is_dir(path)
}

// last_modified returns the last modified time of the file at path.
//
// If the file is not found or an error occurs, an [`FsError`] is returned.
pub fn last_modified(path string) -> ![i64, FsError] {
	mut stat := stat(path)!
	return stat.mtime
}

// stdin returns `File` for stdin.
pub fn stdin() -> File {
	return File{
		fd: C.stdin as CFile
		fno: 0
		is_open: true
	}
}

// stdout returns `File` for stdout.
pub fn stdout() -> File {
	return File{
		fd: C.stdout as CFile
		fno: 1
		is_open: true
	}
}

// stderr returns `File` for stderr.
pub fn stderr() -> File {
	return File{
		fd: C.stderr as CFile
		fno: 2
		is_open: true
	}
}

// Stat is a struct that contains information about a file.
//
// Use [`os.stat`] to get the `Stat` struct for a file.
pub struct Stat {
	// dev is the ID of the device containing file
	dev u64
	// inode is the inode number
	inode u64
	// mode is the file type and user/group/world permission bits
	mode u32
	// nlink is the number of hard links to file
	nlink u64
	// uid is the user ID of owner
	uid u32
	// gid is the group ID of owner
	gid u32
	// rdev is the device ID (if special file)
	rdev u64
	// size is the total size in bytes
	size u64
	// atime is the last access time (seconds since UNIX epoch)
	atime i64
	// mtime is the last modified time (seconds since UNIX epoch)
	mtime i64
	// ctime is the last status change time (seconds since UNIX epoch)
	ctime i64
}

fn Stat.from_sstat(s libc.sstat) -> Stat {
	return Stat{
		dev: s.st_dev
		inode: s.st_ino
		nlink: s.st_nlink
		mode: s.st_mode
		uid: s.st_uid
		gid: s.st_gid
		rdev: s.st_rdev
		size: s.st_size
		atime: s.st_atime
		mtime: s.st_mtime
		ctime: s.st_ctime
	}
}

pub fn (s &Stat) modified_time() -> time.Time {
	return time.Time.from_nanos(s.mtime, 0)
}

pub fn (s &Stat) accessed_time() -> time.Time {
	return time.Time.from_nanos(s.atime, 0)
}

pub fn (s &Stat) created_time() -> time.Time {
	return time.Time.from_nanos(s.ctime, 0)
}

pub struct FileMode {
	typ    FileType
	owner  FilePermission
	group  FilePermission
	others FilePermission
}

pub fn (m &FileMode) as_octal() -> u32 {
	return m.owner.as_octal() << 6 | m.group.as_octal() << 3 | m.others.as_octal()
}

pub struct FilePermission {
	read    bool
	write   bool
	execute bool
}

pub fn (p &FilePermission) as_octal() -> u32 {
	return (p.read as u32) << 2 | (p.write as u32) << 1 | p.execute as u32
}

pub enum FileType {
	unknown
	regular
	directory
	character_device
	block_device
	fifo
	symbolic_link
	socket
}
