module fs

import sys.winapi

pub const (
	PATH_SEPARATOR        = b`\\`
	PATH_SEPARATOR_STRING = '\\'
	PATH_DELIMITER        = b`;`
	PATH_DELIMITER_STRING = ';'
)

pub const (
	MAX_PATH_LEN = 4096
)

pub fn is_path_separator(c u8) -> bool {
	// Windows accepts both `/` and `\` as path separators.
	return c == PATH_SEPARATOR || c == b`/`
}

// real_path returns the canonicalized absolute pathname
//
// It resolves all symbolic links, extra `/` characters, and
// references to `/./ `and `/../` in [`path`].
//
// If the function fails, it returns an error from errno.
//
// Example:
// ```
// assert fs.real_path("/usr/bin/../local/bin").unwrap() == "/usr/local/bin"
// assert fs.real_path("link_to_file").unwrap() == "/path/to/file"
// ```
pub fn real_path(path string) -> !string {
	mut res := [MAX_PATH_LEN]u16{}
	wide_path := path.to_wide()
	file := winapi.CreateFile(wide_path, winapi.GENERIC_READ, winapi.FILE_SHARE_READ, nil, winapi.OPEN_EXISTING, winapi.FILE_FLAG_SESSION_AWARE, nil)
	if file == winapi.INVALID_HANDLE_VALUE {
		// not a file, try to use GetFullPathName
		len := winapi.GetFullPathName(wide_path, MAX_PATH_LEN, &mut res[0], nil)
		winapi.throw(len != 0, "GetFullPathName failed")!
		return string.from_wide_with_len(&res[0], len)
	}

	len := winapi.GetFinalPathNameByHandle(file, &mut res[0], MAX_PATH_LEN, winapi.VOLUME_NAME_DOS)
	if len == MAX_PATH_LEN {
		// buffer too small, return an error
		winapi.CloseHandle(file)
		winapi.throw(false, "GetFinalPathNameByHandle failed because a path bigger than ${MAX_PATH_LEN}")!
		return path
	}

	// TODO: check for small letters for the drive letter
	winapi.CloseHandle(file)
	return string.from_wide_with_len(&res[0], len)
}
