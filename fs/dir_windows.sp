module fs

import sys.winapi
import pathlib

// is_dir returns true if the path is a directory and false otherwise.
pub fn is_dir(path string) -> bool {
	windows_path := pathlib.from_slash(path).to_wide()
	mut attr := winapi.GetFileAttributesW(windows_path)
	if attr == winapi.INVALID_FILE_ATTRIBUTES {
		return false
	}

	if attr & winapi.FILE_ATTRIBUTE_REPARSE_POINT != 0 {
		// TODO: handle symbol links
	}

	return attr & winapi.FILE_ATTRIBUTE_DIRECTORY != 0
}

// mkdir creates a new directory with the specified path.
pub fn mkdir(path string, _ u32) -> ! {
	if path == '.' {
		return
	}
	apath := real_path_safe(path)
	winapi.throw(winapi.CreateDirectoryW(apath.to_wide(), nil), "Failed to create directory '${path}'")!
}

// rmdir removes the directory specified by path.
pub fn rmdir(path string) -> ! {
	winapi.throw(winapi.RemoveDirectoryW(path.to_wide()), "Failed to remove directory '${path}'")!
}
