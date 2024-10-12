module fs

import pathlib
import sys.libc
import sys.winapi

// is_atty returns 1 if the `fd` file descriptor is open and refers to a terminal
pub fn is_atty(fd i32) -> i32 {
	mut mode := 0 as u32
	osfh := winapi._get_osfhandle(fd)
	winapi.GetConsoleMode(osfh, &mut mode)
	return mode as i32
}

// exists returns true if the given path exists.
pub fn exists(path string) -> bool {
	return winapi._waccess(path.replace('/', '\\').to_wide(), 0) == 0
}

// remove removes the named file or directory.
pub fn remove(path string) -> ! {
	FsError.throw(winapi._wremove(path.to_wide()) == 0, 'Cannot remove "${path}": ')!
}

// symlink creates a symbolic link.
pub fn symlink(origin string, target string) -> ! {
	mut flags := 0
	if is_dir(origin) {
		flags ^= winapi.SYMBOLIC_LINK_FLAG_DIRECTORY
	}

	flags ^= winapi.SYMBOLIC_LINK_FLAG_ALLOW_UNPRIVILEGED_CREATE
	winapi.throw(winapi.CreateSymbolicLinkW(target.to_wide(), origin.to_wide(), flags) != 0, 'Cannot create a symbolic link from "${origin}" to "${target}"')!

	if !exists(target) {
		return error(winapi.WinError{
			code: 0
			msg: 'CreateSymbolicLinkW reported success but the link does not exist'
			context: 'Cannot create a symbolic link from "${origin}" to "${target}"'
		})
	}
}

// link creates a hard link.
pub fn link(origin string, target string) -> ! {
	winapi.throw(winapi.CreateHardLinkW(target.to_wide(), origin.to_wide(), nil) != 0, 'Cannot create a hard link from "${origin}" to "${target}"')!

	if !exists(target) {
		return error(winapi.WinError{
			code: 0
			msg: 'CreateHardLinkW reported success but the link does not exist'
			context: 'Cannot create a hard link from "${origin}" to "${target}"'
		})
	}
}

// is_link returns true if the file at the given path is a symbolic link.
//
// NOTE: [`is_link`] is known to cause a TOCTOU vulnerability when used incorrectly.
pub fn is_link(path string) -> bool {
	attr := winapi.GetFileAttributesW(pathlib.from_slash(path).to_wide())
	if attr == winapi.INVALID_FILE_ATTRIBUTES {
		return false
	}

	return attr & winapi.FILE_ATTRIBUTE_REPARSE_POINT != 0
}

// stat returns the file metadata for the file at the given path.
//
// If path is a symbolic link, stat returns the metadata for the file that the
// symbolic link points to. On Windows we cannot retrieve the metadata for a
// symbolic link, so [`lstat`] behaves the same as [`stat`].
//
// If data cannot be retrieved, stat returns an [`FsError`].
pub fn stat(path string) -> ![Stat, FsError] {
	mut s := winapi._stat64{}
	// see https://learn.microsoft.com/en-us/cpp/c-runtime-library/reference/stat-functions?view=msvc-170
	res := winapi._wstat64(path.to_wide(), &mut s)
	if res != 0 {
		return error(FsError.from_errno('stat for "${path}" failed: '))
	}
	return Stat.from_sstat64(s)
}

// lstat returns the file metadata for the file at the given path.
//
// On Windows we cannot retrieve the metadata for a symbolic link, so [`lstat`]
// behaves the same as [`stat`].
//
// If data cannot be retrieved, stat returns an [`FsError`].
pub fn lstat(path string) -> ![Stat, FsError] {
	return stat(path)
}

// readlink is a stub function for Windows.
pub fn readlink(path string) -> ![string, FsError] {
	return error(FsError.from_errno('not implemented'))
}

// is_readable returns true if the file at the given path is readable.
//
// NOTE: Can lead to TOCTOU vulnerabilities if used incorrectly.
pub fn is_readable(path string) -> bool {
	wide_path := path.to_wide()
	return winapi._waccess(wide_path, libc.R_OK) == 0
}

// is_writable returns true if the file at the given path is writable.
//
// NOTE: Can lead to TOCTOU vulnerabilities if used incorrectly.
pub fn is_writable(path string) -> bool {
	wide_path := path.to_wide()
	return winapi._waccess(wide_path, libc.W_OK) == 0
}

// is_executable returns true if the file at the given path is executable.
//
// NOTE: Can lead to TOCTOU vulnerabilities if used incorrectly.
pub fn is_executable(path string) -> bool {
	// On Windows _waccess does not support X_OK, se we need other way.
	if !exists(path) {
		// fast path, no file no problem
		return false
	}
	real := real_path(path) or { return false }
	ext := pathlib.ext(real)
	if ext in ['exe', 'com', 'bat', 'cmd'] {
		// assume that the file is executable because it has an executable extension
		return true
	}

	// trying query the file permissions
	stat_info := stat(real) or { return false }
	return stat_info.get_mode().owner.execute
}

// num returns the file descriptor of an opened C file.
// Same as `fileno()`.
pub fn (f CFile) num() -> i32 {
	return winapi._fileno(f)
}

// filetype returns the [`FileType`] from the [`Stat`] struct.
pub fn (st &Stat) filetype() -> FileType {
	return match st.mode & winapi.S_IFMT {
		winapi.S_IFDIR => .directory
		else => .regular
	}
}

// get_mode returns the file type and permissions (readable, writable, executable)
// in owner/group/others format.
pub fn (st &Stat) get_mode() -> FileMode {
	return FileMode{
		typ: st.filetype()
		owner: FilePermission{
			read: is_set(st.mode, winapi.S_IRUSR)
			write: is_set(st.mode, winapi.S_IWUSR)
			execute: is_set(st.mode, winapi.S_IXUSR)
		}
		group: FilePermission{
			read: is_set(st.mode, winapi.S_IRGRP)
			write: is_set(st.mode, winapi.S_IWGRP)
			execute: is_set(st.mode, winapi.S_IXGRP)
		}
		others: FilePermission{
			read: is_set(st.mode, winapi.S_IROTH)
			write: is_set(st.mode, winapi.S_IWOTH)
			execute: is_set(st.mode, winapi.S_IXOTH)
		}
	}
}

#[inline]
fn is_set(mode u32, flag u32) -> bool {
	return (mode & flag) != 0
}

fn Stat.from_sstat64(s winapi._stat64) -> Stat {
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
