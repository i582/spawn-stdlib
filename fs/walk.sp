module fs

import time
import fs.glob
import pathlib

// walk_iter creates a new recursive directory iterator
// starting from the given [`root`].
//
// If the [`root`] is a directory, then it is first yielded
// and then its contents are yielded recursively. If the
// [`root`] is a file, then it is yielded and the iterator
// ends.
//
// Example:
// ```
// for entry in fs.walk_iter("path/to/dir") {
//     println(entry.path)
// }
// ```
//
// See also [`read_dir_iter`] for traversing the current directory only.
//
// By default [`walk_iter`] yields directories as well as files.
// You can change this behavior by using
// the [`WalkIterator.only_files`]
// and [`WalkIterator.only_dirs`] methods.
//
// ## Skip directories
//
// You can skip directories by providing a list of glob
// patterns to the [`WalkIterator.skip_dirs`] method. If the
// directory name matches any of the provided patterns, then
// it is skipped and all its contents are not yielded.
//
// ```
// // print all files in the directory except for `node_modules` and `target`
// for entry in fs.walk_iter("path/to/dir").skip_dirs("*/node_modules", "*/target") {
//     println(entry.path)
// }
// ```
//
// ## Traverse only files matching a pattern
//
// You can traverse only files matching a pattern by providing
// a list of glob patterns to the [`WalkIterator.only_files`] method.
// If the file name does not match any of the provided patterns,
// then it is skipped.
// If no patterns are provided, then only files are traversed, any
// directories are skipped.
//
// ```
// // print all `.sp` files in the directory
// for entry in fs.walk_iter("path/to/dir").only_files("*.sp") {
//     println(entry.path)
// }
// ```
//
// ## Traverse only directories
//
// You can traverse only directories by using the [`WalkIterator.only_dirs`]
// method. This will skip all files and only yield directories.
//
// ```
// // print all directories in the directory
// for entry in fs.walk_iter("path/to/dir").only_dirs() {
//     println(entry.path)
// }
// ```
//
// ## Sorting
//
// By default the iterator does not sort the entries and yields
// them in the order they are found. You can change this behavior
// by using the [`WalkIterator.sort_by`] method. You can provide
// a custom sorting function that will be used to sort the entries.
//
// [`WalkIterator.sort_by_filename`] is a helper method that sorts
// the entries by their file name in ascending order.
//
// ```
// // print all files in the directory sorted by their name
// for entry in fs.walk_iter("path/to/dir").sort_by_filename() {
//     println(entry.path)
// }
// ```
//
// ## Skip current directory
//
// [`WalkIterator.skip_dirs`] is not always enough to skip all the
// nessary directories. In some cases you may want to skip the directory
// by some complex condition. You can do this by using the [`WalkEntry.skip_this_dir`]
// method.
//
// ```
// for entry in fs.walk_iter("path/to/dir") {
//     some_complex_condition := true
//     if entry.is_dir() && some_complex_condition {
//         entry.skip_this_dir()
//         continue
//     }
//
//     println(entry.path)
// }
// ```
//
// In this example, if the current entry is a directory and it matches
// some complex condition, then it is skipped and all its contents are
// not yielded.
pub fn walk_iter(root string) -> WalkIterator {
	return WalkIterator{ root: root, remaining: [root] }
}

// WalkIterator is a recursive directory iterator.
//
// See [`walk_iter`] for more information.
pub struct WalkIterator {
	root  string
	globs []string

	sorter ?fn (a &string, b &string) -> i32
	filter ?fn (entry &WalkEntry) -> bool

	only_files       bool
	only_files_globs []string
	skip_hidden_dirs bool

	only_dirs bool

	remaining []string
	dir_stack []string
}

// skip_dirs skips directories that match any of the provided glob patterns.
//
// Example:
// ```
// // print all files in the directory except for `node_modules` and `target`
// for entry in fs.walk_iter("path/to/dir").skip_dirs("*/node_modules", "*/target") {
//     println(entry.path)
// }
// ```
pub fn (it WalkIterator) skip_dirs(globs ...string) -> WalkIterator {
	return WalkIterator{
		...it
		globs: globs
	}
}

// skip_hidden_dirs skips hidden directories.
//
// Hidden directories are the directories that start with a dot.
//
// Example:
// ```
// // print all files in the directory except for hidden directories
// // for example `.git` or `.vscode`
// for entry in fs.walk_iter("path/to/dir").skip_hidden_dirs() {
//     println(entry.path)
// }
// ```
pub fn (it WalkIterator) skip_hidden_dirs() -> WalkIterator {
	return WalkIterator{
		...it
		skip_hidden_dirs: true
	}
}

// filter_entries filters the entries using the provided filter function.
//
// If the filter function returns `true`, then the entry is yielded and
// skipped otherwise.
//
// Example:
// ```
// import time
//
// fn main() {
//     // collect all files modified in the last 24 hours
//     files := fs.walk_iter(".").
//           filter_entries(|entry| entry.last_modified().after(time.now().sub(24 * time.HOUR))).
//           collect()
// }
// ```
pub fn (it WalkIterator) filter_entries(filter fn (entry &WalkEntry) -> bool) -> WalkIterator {
	return WalkIterator{
		...it
		filter: filter
	}
}

// only_files traverses only files that match any of the provided glob patterns.
// If no patterns are provided, then only files are traversed, any directories are skipped.
//
// Example:
// ```
// // print all `.sp` files in the directory
// for entry in fs.walk_iter("path/to/dir").only_files("*.sp") {
//     println(entry.path)
// }
// ```
//
// ```
// // print all files in the directory
// for entry in fs.walk_iter("path/to/dir").only_files() {
//     println(entry.path)
// }
// ```
pub fn (it WalkIterator) only_files(globs ...string) -> WalkIterator {
	return WalkIterator{
		...it
		only_files: true
		only_files_globs: globs
	}
}

// only_dirs traverses only directories.
// This will skip all files and only yield directories.
//
// Example:
// ```
// // print all directories in the directory
// for entry in fs.walk_iter("path/to/dir").only_dirs() {
//     println(entry.path)
// }
// ```
pub fn (it WalkIterator) only_dirs() -> WalkIterator {
	return WalkIterator{
		...it
		only_dirs: true
	}
}

// sort_by sorts the entries using the provided sorting function.
//
// See [`sort_by_filename`] for a helper method that sorts the entries
// by their file name in ascending order.
//
// Example:
// ```
// // print all files in the directory sorted by their name
// it := fs.walk_iter("path/to/dir").sort_by(|a, b| if a < b { -1 } else if a > b { 1 } else { 0 })
// for entry in it {
//     println(entry.path)
// }
// ```
pub fn (it WalkIterator) sort_by(sorter fn (a &string, b &string) -> i32) -> WalkIterator {
	return WalkIterator{
		...it
		sorter: sorter
	}
}

// sort_by_filename sorts the entries by their file name in ascending order.
//
// Example:
// ```
// // print all files in the directory sorted by their name
// for entry in fs.walk_iter("path/to/dir").sort_by_filename() {
//     println(entry.path)
// }
// ```
pub fn (it WalkIterator) sort_by_filename() -> WalkIterator {
	return WalkIterator{
		...it
		sorter: fn (a &string, b &string) -> i32 {
			if *a < *b {
				return -1
			}
			if *a > *b {
				return 1
			}
			return 0
		}
	}
}

// skip_current_dir skips the current directory and moves to the next one.
//
// This method is useful when you want to skip the current directory
// based on some complex condition.
//
// Example:
// ```
// it := fs.walk_iter("path/to/dir")
// for entry in it {
//     some_complex_condition := true
//     if entry.is_dir() && some_complex_condition {
//         entry.skip_this_dir()
//         continue
//     }
//
//     println(entry.path)
// }
// ```
//
// See [`WalkEntry.skip_this_dir`] for more handy way to skip the current directory.
fn (it &mut WalkIterator) skip_current_dir() {
	if it.dir_stack.len == 0 {
		return
	}

	it.dir_stack.pop()
}

fn (it &mut WalkIterator) need_process(path string) -> bool {
	if it.globs.len == 0 {
		return true
	}

	for pattern in it.globs {
		if glob.matches_safe(pattern, path) {
			return false
		}
	}

	return true
}

fn (it &mut WalkIterator) need_process_file(path string) -> bool {
	if it.only_files_globs.len == 0 {
		return true
	}

	for pattern in it.only_files_globs {
		if glob.matches_safe(pattern, path) {
			return true
		}
	}

	return false
}

// next returns the next entry in the iterator.
//
// If the iterator is exhausted, then it returns `none`.
pub fn (it &mut WalkIterator) next() -> ?WalkEntry {
	if it.remaining.len == 0 && it.dir_stack.len == 0 {
		return none
	}

	if it.root.len == 0 {
		return none
	}

	for {
		if latest_dir := it.dir_stack.pop() {
			// if last walk was a directory, we need to process it

			// TODO: we may wont to pass globs for directories to read_dir
			//       to avoid reading all files and then filtering them
			mut files := read_dir(latest_dir) or { return none }
			if it.sorter != none {
				files.sort(it.sorter)
			}

			for idx := files.len as i64 - 1; idx >= 0; idx-- {
				filename := files.fast_get(idx)
				if it.skip_hidden_dirs && filename.starts_with(".") {
					continue
				}

				path := '${latest_dir}${PATH_SEPARATOR_STRING}${filename}'
				it.remaining.push(path)
			}
		}

		cpath := it.remaining.pop() or { return none }

		stat_info := stat(cpath) or { return none }
		if stat_info.filetype() == .directory {
			if !it.need_process(cpath) {
				continue
			}

			it.dir_stack.push(cpath)

			if it.only_files {
				// skip directory and move to next
				continue
			}
		} else if it.only_dirs {
			// skip file and move to next
			continue
		} else if it.only_files {
			name := pathlib.file_name(cpath)
			if !it.need_process_file(name) {
				continue
			}
		}

		entry := WalkEntry{ path: cpath, stat: stat_info, it: it }
		if it.filter != none && !it.filter(&entry) {
			continue
		}

		return entry
	}
}

// collect returns all entries in the iterator.
//
// Exanple:
// ```
// entries := fs.walk_iter("path/to/dir").collect()
// println(entries)
// ```
pub fn (it &mut WalkIterator) collect() -> []string {
	mut result := []string{cap: 20}
	for entry in it {
		result.push(entry.path)
	}
	return result
}

// WalkEntry is a single entry in the recursive directory iterator.
pub struct WalkEntry {
	path string
	stat Stat

	it &mut WalkIterator
}

// path returns the path of the entry.
pub fn (e &WalkEntry) path() -> string {
	return e.path
}

// name returns the name of the entry.
//
// Example:
// ```
// // print all file names in the directory
// for entry in fs.walk_iter("path/to/dir") {
//     println(entry.name())
// }
// ```
pub fn (e &WalkEntry) name() -> string {
	return pathlib.file_name(e.path)
}

// size returns the size of the entry.
//
// If the entry is a directory, then the size is `0`.
pub fn (e &WalkEntry) size() -> u64 {
	return e.stat.size
}

// last_modified returns the last modified time of the entry.
pub fn (e &WalkEntry) last_modified() -> time.Time {
	return time.Time.from_nanos(e.stat.mtime, 0)
}

// last_accessed returns the last accessed time of the entry.
pub fn (e &WalkEntry) last_accessed() -> time.Time {
	return time.Time.from_nanos(e.stat.atime, 0)
}

// is_dir returns `true` if the entry is a directory.
pub fn (e &WalkEntry) is_dir() -> bool {
	return e.stat.filetype() == .directory
}

// is_file returns `true` if the entry is a regular file.
pub fn (e &WalkEntry) is_file() -> bool {
	return e.stat.filetype() == .regular
}

// is_symlink returns `true` if the entry is a symbolic link.
pub fn (e &WalkEntry) is_symlink() -> bool {
	return e.stat.filetype() == .symbolic_link
}

// skip_this_dir skips the current directory and moves to the next one.
//
// This method is useful when you want to skip the current directory
// based on some complex condition.
//
// Example:
// ```
// for entry in fs.walk_iter("path/to/dir") {
//     some_complex_condition := true
//     if entry.is_dir() && some_complex_condition {
//         entry.skip_this_dir()
//         continue
//     }
//     println(entry.path)
// }
// ```
pub fn (e &WalkEntry) skip_this_dir() {
	if !e.is_dir() {
		return
	}

	mut it := e.it
	it.skip_current_dir()
}
