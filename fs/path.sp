module fs

// real_path_safe returns the canonicalized absolute pathname
//
// It resolves all symbolic links, extra `/` characters, and
// references to `/./ `and `/../` in [`path`].
//
// If the function fails, it returns the original path.
//
// Example:
// ```
// assert fs.real_path_safe("/usr/bin/../local/bin") == "/usr/local/bin"
// assert fs.real_path_safe("link_to_file") == "/path/to/file"
// ```
pub fn real_path_safe(path string) -> string {
	return real_path(path) or { path }
}
