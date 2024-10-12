module fs

import pathlib

// read_dir_iter creates a new directory iterator for the given [`path`] directory.
// This iterator yelds all entries (except `.` and `..`) from the given [`path`]
// directory in system-defined order.
//
// Example:
// ```
// for entry in fs.read_dir_iter("path/to/dir").unwrap() {
//     println(entry.path())
// }
// ```
//
// If the given [`path`] is not a directory or cannot be opened, the function will
// return an error.
//
// If you want to recursively walk all files and directories, use the [`walk_iter`] function.
//
// Note that if you don't use the all iterator, you need to explicitly call
// [`DirIterator.close`] to avoid resource leaks.
//
// ```
// mut it := fs.read_dir_iter("path/to/dir").unwrap()
// first_file := it.next().unwrap()
// println(first_file.path())
// it.close()
// ```
pub fn read_dir_iter(path string) -> !DirIterator {
	if !is_dir(path) {
		return error('path is not a directory "${path}"')
	}
	return DirIterator.new(path)
}

// DirIterator is a directory iterator.
//
// See [`read_dir_iter`] for more information.
pub struct DirIterator {
	path       string
	handle     DirHandle
	first_file string
}

// next returns the next entry in the iterator.
//
// If the iterator is exhausted, then it returns `none` and closes inner handle.
//
// Example
// ```
// mut it := fs.read_dir_iter("path/to/dir").unwrap()
// first_file := it.next().unwrap()
// it.close()
// ```
pub fn (it &mut DirIterator) next() -> ?DirEntry {
	name := it.next_impl()?
	return DirEntry{ root: it.path, name: name }
}

// collect returns all entries in the iterator.
//
// Exanple:
// ```
// entries := fs.read_dir_iter("path/to/dir").unwrap().collect(abs_paths: false)
// println(entries)
// ```
pub fn (it &mut DirIterator) collect(abs_paths bool) -> []string {
	mut result := []string{cap: 20}
	for entry in it {
		result.push(if abs_paths { entry.path() } else { entry.name() })
	}
	return result
}

// DirEntry is a single entry in the directory iterator.
pub struct DirEntry {
	root string
	name string
}

// name returns the name of the entry.
//
// Example:
// ```
// // print all file names in the directory
// for entry in fs.read_dir_iter("path/to/dir").unwrap() {
//     println(entry.name())
// }
// ```
pub fn (e &DirEntry) name() -> string {
	return e.name
}

// path returns the absolute path of the entry.
//
// Example:
// ```
// // print all absolute file paths in the directory
// for entry in fs.read_dir_iter("path/to/dir").unwrap() {
//     println(entry.path())
// }
// ```
pub fn (e &DirEntry) path() -> string {
	return pathlib.abs(pathlib.join(e.root, e.name))
}
