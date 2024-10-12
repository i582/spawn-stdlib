module fs

import sys.libc

#[include("<sys/stat.h>")]

// is_atty returns 1 if the `fd` file descriptor is open and refers to a terminal
pub fn is_atty(fd i32) -> i32 {
	return libc.isatty(fd)
}

// remove removes the named file or directory.
pub fn remove(path string) -> ! {
	FsError.throw(libc.remove(path.c_str()) == 0, 'Cannot remove "${path}": ')!
}

// exists returns true if the given path exists.
pub fn exists(path string) -> bool {
	return libc.access(path.c_str(), 0) == 0
}

// symlink creates a symbolic link.
pub fn symlink(origin string, target string) -> ! {
	FsError.throw(libc.symlink(origin.c_str(), target.c_str()) == 0, 'Cannot create a symbolic link from "${origin}" to "${target}": ')!
}

// link creates a hard link.
pub fn link(origin string, target string) -> ! {
	FsError.throw(libc.link(origin.c_str(), target.c_str()) == 0, 'Cannot create a hard link from "${origin}" to "${target}": ')!
}

// is_link returns true if the file at the given path is a symbolic link.
//
// NOTE: [`is_link`] is known to cause a TOCTOU vulnerability when used incorrectly.
pub fn is_link(path string) -> bool {
	attr := lstat(path) or { return false }
	return attr.filetype() == .symbolic_link
}

// stat returns the file metadata for the file at the given path.
//
// If path is a symbolic link, stat returns the metadata for the file that the
// symbolic link points to. See [`lstat`] for metadata of the symbolic link itself.
//
// If data cannot be retrieved, stat returns an [`FsError`].
pub fn stat(path string) -> ![Stat, FsError] {
	mut s := libc.sstat{}
	res := libc.stat(path.c_str(), &mut s)
	if res != 0 {
		return error(FsError.from_errno('stat for "${path}" failed: '))
	}
	return Stat.from_sstat(s)
}

// lstat returns the file metadata for the file at the given path.
//
// If path is a symbolic link, lstat returns the metadata for the
// symbolic link itself. See [`stat`] for metadata of the file that
// the symbolic link points to.
//
// If data cannot be retrieved, stat returns an [`FsError`].
pub fn lstat(path string) -> ![Stat, FsError] {
	mut s := libc.sstat{}
	res := libc.lstat(path.c_str(), &mut s)
	if res != 0 {
		return error(FsError.from_errno('lstat for "${path}" failed: '))
	}
	return Stat.from_sstat(s)
}

// readlink returns the target of a symbolic link.
// If the path is not a symbolic link, readlink returns an error.
pub fn readlink(path string) -> ![string, FsError] {
	mut buf := [4096]u8{}
	res := libc.readlink(path.c_str(), buf.as_ptr(), buf.len() as u64)
	if res == -1 {
		return error(FsError.from_errno('readlink for "${path}" failed: '))
	}
	buf[res] = 0
	return buf[..res].ascii_str()
}

// chmod changes file access attributes of [`path`] to [`mode`].
//
// For the mode, you can use either octal numbers or constants
// from the [`sys.libc`] module.
//
// Example:
// ```
// import sys.libc
//
// // change permissions to rwxr-xr-x (755)
// fs.chmod("file.txt", 0o755).unwrap()
//
// // change permissions to rw-r--r-- (644)
// fs.chmod("file.txt", libc.S_IRUSR | libc.S_IWUSR | libc.S_IRGRP | libc.S_IROTH).unwrap()
// ```
pub fn chmod(path string, mode u32) -> ! {
	res := libc.chmod(path.c_str(), mode)
	if res == -1 {
		return error(FsError.from_errno('chmod for "${path}" failed: '))
	}
}

// is_readable returns true if the file at the given path is readable.
//
// NOTE: Can lead to TOCTOU vulnerabilities if used incorrectly.
pub fn is_readable(path string) -> bool {
	return libc.access(path.c_str(), libc.R_OK) == 0
}

// is_writable returns true if the file at the given path is writable.
//
// NOTE: Can lead to TOCTOU vulnerabilities if used incorrectly.
pub fn is_writable(path string) -> bool {
	return libc.access(path.c_str(), libc.W_OK) == 0
}

// is_executable returns true if the file at the given path is executable.
//
// NOTE: Can lead to TOCTOU vulnerabilities if used incorrectly.
pub fn is_executable(path string) -> bool {
	return libc.access(path.c_str(), libc.X_OK) == 0
}

// num returns the file descriptor of an opened C file.
// Same as `fileno()`.
pub fn (f CFile) num() -> i32 {
	return libc.fileno(f)
}

// filetype returns the [`FileType`] from the [`Stat`] struct.
pub fn (st &Stat) filetype() -> FileType {
	return match st.mode & libc.S_IFMT {
		libc.S_IFREG => .regular
		libc.S_IFDIR => .directory
		libc.S_IFCHR => .character_device
		libc.S_IFBLK => .block_device
		libc.S_IFIFO => .fifo
		libc.S_IFLNK => .symbolic_link
		libc.S_IFSOCK => .socket
		else => .unknown
	}
}

// get_mode returns the file type and permissions (readable, writable, executable)
// in owner/group/others format.
pub fn (st &Stat) get_mode() -> FileMode {
	return FileMode{
		typ: st.filetype()
		owner: FilePermission{
			read: is_set(st.mode, libc.S_IRUSR)
			write: is_set(st.mode, libc.S_IWUSR)
			execute: is_set(st.mode, libc.S_IXUSR)
		}
		group: FilePermission{
			read: is_set(st.mode, libc.S_IRGRP)
			write: is_set(st.mode, libc.S_IWGRP)
			execute: is_set(st.mode, libc.S_IXGRP)
		}
		others: FilePermission{
			read: is_set(st.mode, libc.S_IROTH)
			write: is_set(st.mode, libc.S_IWOTH)
			execute: is_set(st.mode, libc.S_IXOTH)
		}
	}
}

#[inline]
fn is_set(mode u32, flag u32) -> bool {
	return (mode & flag) != 0
}
