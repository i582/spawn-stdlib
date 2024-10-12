module pathlib

import strings

// to_slash returns the result of replacing each separator character
// in path with a slash (`/`) character. Multiple separators are
// replaced by multiple slashes.
fn to_slash(path string) -> string {
	if PATH_SEPARATOR == b`/` {
		return path
	}

	return path.replace_u8_with_u8(PATH_SEPARATOR, b`/`)
}

// ext returns the file name extension used by path. The extension is the
// suffix beginning at the final dot in the final slash-separated element of
// path; it is empty if there is no dot.
//
// Example:
// ```
// ext("/foo/bar/baz.js") == ".js"
// ext("/foo/bar/baz") == ""
// ```
pub fn ext(path string) -> string {
	for i := (path.len - 1) as i32; i >= 0 && path[i] != b`/`; i-- {
		if path[i] == b`.` {
			return path.substr(i, path.len)
		}
	}

	return ''
}

// join joins any number of path elements into a single path, adding a
// separator if necessary. Empty elements are ignored. The result is
// cleaned. However, if the argument list is empty or all its elements
// are empty, `join` returns an empty string.
//
// Example:
// ```
// join("a", "b", "c") == "a/b/c"
// join("a", "", "c") == "a/c"
// join("", "", "") == ""
// ```
pub fn join(paths ...string) -> string {
	mut size := 0 as usize
	for path in paths {
		size += path.len
	}
	if size == 0 {
		return ''
	}
	mut result := strings.new_builder(size)
	for path in paths {
		if result.len > 0 || path.len != 0 {
			if result.len > 0 {
				result.write_u8(PATH_SEPARATOR)
			}

			result.write_str(path)
		}
	}

	return clean(result.str_view())
}

// clean returns the shortest path name equivalent to path by purely
// lexical processing. It applies the following rules iteratively until
// no further processing can be done:
//
//  1. Replace multiple slashes with a single slash.
//  2. Eliminate each `.` path name element (the current directory).
//  3. Eliminate each inner `..` path name element (the parent directory)
//     along with the non-`..` element that precedes it.
//  4. Eliminate `..` elements that begin a rooted path:
//     that is, replace `/..` by `/` at the beginning of a path.
//
// The returned path ends in a slash only if it is the root `/`.
//
// If the result of this process is an empty string, Clean
// returns the string `.`.
//
// See also Rob Pike, “Lexical File Names in Plan 9 or Getting Dot-Dot Right,”
// https://9p.io/sys/doc/lexnames.html
//
// TODO: make this work on Windows
pub fn clean(path string) -> string {
	if path.len == 0 {
		return '.'
	}

	is_root := is_path_separator(path[0])
	n := path.len

	mut out := strings.new_builder(n + 1)
	mut r := 0 as usize
	mut dotdot := 0 as usize

	if is_root {
		out.write_u8(PATH_SEPARATOR)
		r = 1
		dotdot = 1
	}

	for r < n {
		if is_path_separator(path[r]) {
			// empty path element
			r++
		} else if path[r] == b`.` && (r + 1 == n || is_path_separator(path[r + 1])) {
			// . element
			r++
		} else if path[r] == b`.` && path[r + 1] == b`.` && (r + 2 == n || is_path_separator(path[r + 2])) {
			// .. element: remove to last /
			r += 2
			if out.len > dotdot {
				// can backtrack
				out.trim(1)
				for out.len > dotdot && !is_path_separator(out.at(out.len - 1)) {
					out.trim(1)
				}
			} else if !is_root {
				// cannot backtrack, but not rooted, so append .. element.
				if out.len > 0 {
					out.write_u8(PATH_SEPARATOR)
				}

				out.write_u8(b`.`)
				out.write_u8(b`.`)
				dotdot = out.len
			}
		} else {
			// real path element.
			// add slash if needed
			if (is_root && out.len != 1) || (!is_root && out.len != 0) {
				out.write_u8(PATH_SEPARATOR)
			}

			// copy element
			for ; r < n && !is_path_separator(path[r]); r++ {
				out.write_u8(path[r])
			}
		}
	}

	// turn empty string into "."
	if out.len == 0 {
		return '.'
	}

	return out.str_view()
}

// from_slash returns the result of replacing each slash (`/`) character
// in path with a separator character. Multiple slashes are replaced by
// multiple separators.
pub fn from_slash(path string) -> string {
	if PATH_SEPARATOR == b`/` {
		return path
	}

	return path.replace_u8_with_u8(b`/`, PATH_SEPARATOR)
}

// relative returns a relative path that is equivalent to target when
// joined to base. If target is not relative to base, relative returns
// target unchanged. Otherwise, the returned path does not begin with
// `../`.
//
// Example:
// ```
// relative("/a/b", "/a/b/c") == "c"
// relative("/a/b", "/a/b") == "."
// relative("/a/b", "/a/b/") == "."
// relative("/a/b", "/a/b/c/d") == "c/d"
// ```
pub fn relative(mut base string, mut target string) -> string {
	base = clean(base)
	target = clean(target)

	if base == target {
		return '.'
	}

	if !target.starts_with(base) {
		return target
	}

	if target.len == base.len {
		return '.'
	}

	if target[base.len] == PATH_SEPARATOR {
		return target[base.len + 1..]
	}

	return target[base.len..]
}

// base returns the last element of path. Trailing path separators are removed
// before extracting the last element. If the path is empty, base returns ".".
// If the path consists entirely of separators, base returns a single separator.
//
// Example:
// ```
// assert base("/foo/bar/baz") == "baz"
// assert base("/foo/bar/baz/") == "baz"
// assert base("/foo") == "foo"
// assert base("foo") == "foo"
// assert base("") == "."
// ```
pub fn base(path string) -> string {
	if path.len == 0 {
		return '.'
	}

	clean_path := clean(path)
	for i := (clean_path.len - 1) as i32; i >= 0; i-- {
		if clean_path[i] == PATH_SEPARATOR {
			return clean_path.substr(i + 1, clean_path.len)
		}
	}

	return clean_path
}

// file_name returns the last element of path, typically the file name.
// Trailing path separators are removed before extracting the last element.
// If the path is empty, file_name returns ".". If the path consists entirely
// of separators, file_name returns a single separator.
//
// Example:
// ```
// assert file_name("/foo/bar/baz") == "baz"
// assert file_name("/foo/bar/baz/") == "baz"
// assert file_name("/foo") == "foo"
// assert file_name("foo") == "foo"
// assert file_name("") == "."
// ```
pub fn file_name(path string) -> string {
	return base(path)
}

// dir returns the leading directory component of path. Trailing slashes are removed.
// If path is empty, dir returns ".". If path is the root directory, dir returns "/".
//
// Example:
// ```
// assert dir("/foo/bar/baz") == "/foo/bar"
// assert dir("/foo/bar/baz/") == "/foo/bar"
// assert dir("/foo") == "/"
// assert dir("foo") == "."
// ```
pub fn dir(path string) -> string {
	if path.len == 0 {
		return '.'
	}

	clean_path := clean(path)
	for i := (clean_path.len - 1) as i32; i >= 0; i-- {
		if clean_path[i] == PATH_SEPARATOR {
			return clean_path.substr(0, i + 1)
		}
	}

	return '.'
}
