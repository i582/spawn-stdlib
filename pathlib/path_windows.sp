module pathlib

import sys.winapi

const PATH_SEPARATOR = b`\\`

const MAX_PATH_LEN = 4096 as u32

pub fn is_path_separator(c u8) -> bool {
	// Windows accepts both `/` and `\` as path separators.
	return c == PATH_SEPARATOR || c == b`/`
}

// is_abs reports whether the path is absolute.
pub fn is_abs(path string) -> bool {
	vl := volume_name_len(path)
	if vl == 0 {
		return false
	}
	// If the volume name starts with a double slash, this is an absolute path.
	if is_slash(path[0]) && is_slash(path[1]) {
		return true
	}

	after_vol := path[vl..path.len]
	if after_vol.len == 0 {
		// There is only a volume name.
		// The path is relative to the current directory on the drive.
		return false
	}

	// The path is absolute if the first character after the volume name is a
	// directory separator.
	return is_slash(after_vol[0])
}

// volume_name_len returns length of the leading volume name on Windows.
// On other platforms, it always returns 0.
//
// See: https://learn.microsoft.com/en-us/dotnet/standard/io/file-path-formats
pub fn volume_name_len(path string) -> i32 {
	if path.len < 2 {
		return 0
	}

	// Drive letter followed by a colon.
	dl := path[0]
	if path[1] == b`:` && dl.is_alpha() {
		return 2
	}

	// UNC and DOS device paths start with two slashes.
	if !(is_slash(path[0])) || !(is_slash(path[1])) {
		return 0
	}

	// TODO: Finish when there will be support for returning tuples from functions.
	return 0
}

pub fn is_slash(c u8) -> bool {
	return c == b`/` || c == b`\\`
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
	return join(wd, path)
}

fn get_wd() -> string {
	mut buf := [MAX_PATH_LEN]u16{}
	if winapi._wgetcwd(&mut buf[0], MAX_PATH_LEN) == nil {
		return ''
	}
	return string.from_wide(&buf[0])
}
