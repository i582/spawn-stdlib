module fs

// mkdir_all will create a valid full path of all directories given in `path`.
pub fn mkdir_all(opath string, mode u32) -> ! {
	if exists(opath) {
		if is_dir(opath) {
			return
		}
		return error('path `${opath}` already exists, and is not a folder')
	}
	other_separator := if PATH_SEPARATOR == b`/` { '\\' } else { '/' }
	path := opath.replace(other_separator, PATH_SEPARATOR_STRING)
	mut p := if path.starts_with(PATH_SEPARATOR_STRING) { PATH_SEPARATOR_STRING } else { '' }
	for subdir in path.trim_start(PATH_SEPARATOR_STRING).split_iter(PATH_SEPARATOR_STRING) {
		p = p + subdir + PATH_SEPARATOR_STRING
		if exists(p) && is_dir(p) {
			continue
		}
		mkdir(p, mode) or { return error('folder: ${p}, error: ${err}') }
	}
}

// read_dir returns a list of all files and directories in the specified path.
// The returned list does not include the current directory (`.`) or the parent
// directory (`..`) entries.
//
// If the directory cannot be opened, function returns an error.
//
// Example:
// ```
// files := fs.read_dir('/tmp') or { [] }
// for file in files {
//    println(file)
// }
// ```
//
// See also [`read_dir_iter`] to get an iterator.
pub fn read_dir(path string) -> ![]string {
	return read_dir_iter(path)!.collect(abs_paths: false)
}
