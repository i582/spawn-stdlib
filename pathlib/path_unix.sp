module pathlib

import sys.libc

const PATH_SEPARATOR = b`/`

const MAX_PATH_LEN = 4096 as usize

pub fn is_path_separator(c u8) -> bool {
	return c == PATH_SEPARATOR
}

// volume_name_len returns length of the leading volume name on Windows.
// On other platforms, it always returns 0.
pub fn volume_name_len(path string) -> i32 {
	return 0
}

// is_abs reports whether the path is absolute.
pub fn is_abs(path string) -> bool {
	return path.starts_with('/')
}

// abs returns an absolute representation of path.
//
// If the path is not absolute it will be joined with the current
// working directory to turn it into an absolute path. The absolute
// path name for a file is not guaranteed to be unique. [`abs`] calls
// [`clean`] on the result.
pub fn abs(path string) -> string {
	if is_abs(path) {
		return clean(path)
	}
	wd := get_wd()
	if wd == '' {
		return path
	}
	return clean(join(wd, path))
}

fn get_wd() -> string {
	mut buf := [MAX_PATH_LEN]u8{}
	if libc.getcwd(&mut buf[0], MAX_PATH_LEN) == nil {
		return ''
	}
	return string.from_c_str(&buf[0])
}
