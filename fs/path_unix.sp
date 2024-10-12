module fs

import sys.libc

pub const (
	PATH_SEPARATOR        = b`/`
	PATH_SEPARATOR_STRING = '/'
	PATH_DELIMITER        = b`:`
	PATH_DELIMITER_STRING = ':'
)

pub const (
	MAX_PATH_LEN = 4096 as usize
)

pub fn is_path_separator(c u8) -> bool {
	return c == PATH_SEPARATOR
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
	mut res := [MAX_PATH_LEN]u8{}
	ret := libc.realpath(path.c_str(), &mut res[0])
	if ret == nil {
		return error(FsError.from_errno('real_path failed for "${path}": '))
	}
	return string.view_from_c_str(ret).clone()
}
