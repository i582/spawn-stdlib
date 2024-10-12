module fs

import sys.libc

// is_dir returns true if the path is a directory and false otherwise.
//
// If the path is a symbolic link, the function checks the file pointed
// to by the link.
pub fn is_dir(path string) -> bool {
	if path.len == 0 {
		return false
	}

	attr := stat(path) or { return false }
	return attr.filetype() == .directory
}

// mkdir creates a new directory with the specified path.
pub fn mkdir(path string, mode u32) -> ! {
	if path == '.' {
		return
	}
	apath := real_path_safe(path)
	FsError.throw(libc.mkdir(apath.c_str(), mode) != -1, 'Could not create folder "${path}": ')!
}

// rmdir removes the directory specified by path.
pub fn rmdir(path string) -> ! {
	FsError.throw(libc.rmdir(path.c_str()) != -1, 'Could not remove folder "${path}": ')!
}
