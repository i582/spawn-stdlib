module fs

import pathlib

// copy copies a file or directory from [`src`] to [`dst`].
//
// If [`src`] is a file and [`dst`] is a directory, the file is copied into that directory.
// If [`src`] is a directory, the entire directory is copied recursively into [`dst`].
//
// If [`overwrite`] is false and the destination file or directory already exists,
// an error is returned.
//
// Example:
//
// Copying a file into a directory:
// ```
// fs.copy("foo.txt", "backup/", false) or {
//     eprintln("Failed to copy: ${err.msg()}")
//     return
// }
// // The file will be copied to backup/foo.txt
// ```
//
// Example:
//
// Copying a directory recursively:
// ```
// fs.copy("src_dir", "backup/src_dir", true) or {
//     eprintln("Failed to copy directory: ${err.msg()}")
//     return
// }
// ```
pub fn copy(src string, dst string, overwrite bool) -> ! {
	real_src := real_path(src)!
	real_dst := real_path_safe(dst)

	if !exists(real_src) {
		return error("'${real_src}' doesn't exists")
	}

	// after `real_path` paths is either file of directory

	if is_file(real_src) {
		copy_file(real_src, real_dst, overwrite)!
		return
	}

	copy_dir_impl(real_src, real_dst, overwrite)!
}

// copy_dir copies the contents of a directory from [`src`] to [`dst`] recursively.
//
// Both [`src`] and [`dst`] should be directories. If [`src`] is not a directory,
// an error is returned.
//
// If [`overwrite`] is false and any file or directory inside the destination already exists,
// an error is returned.
//
// Example:
//
// ```
// fs.copy_dir("src_dir", "backup/src_dir", true) or {
//     eprintln("Failed to copy directory: ${err.msg()}")
//     return
// }
// ```
//
// See [`copy_file`] to copy a file.
pub fn copy_dir(src string, dst string, overwrite bool) -> ! {
	real_src := real_path(src)!
	real_dst := real_path_safe(dst)

	if !exists(real_src) {
		return error("'${real_src}' doesn't exists")
	}

	if !is_dir(real_src) {
		return error("'${real_src}' is not a directory")
	}

	copy_dir_impl(real_src, real_dst, overwrite)!
}

// copy_symlink copies a symbolic link from [`src`] to [`dst`].
//
// The function reads the target of the symbolic link at [`src`] and creates a
// new symbolic link at [`dst`] pointing to the same target.
//
// If [`overwrite`] is false and the destination already exists, an error is returned.
//
// Note: On Windows, this function currently does nothing as symbolic link
// handling is not yet implemented.
//
// Example:
//
// ```
// fs.copy_symlink("link_to_foo", "backup/link_to_foo", false) or {
//     eprintln("Failed to copy symlink: ${err.msg()}")
//     return
// }
// ```
pub fn copy_symlink(src string, dst string, overwrite bool) -> ! {
	comptime if windows {
		// currently readlink is not implemented on Windows
		return
	}

	if exists(dst) && !overwrite {
		return error("'${dst}' is already exist")
	}

	link := readlink(src)!
	symlink(link, dst)!
}

fn copy_dir_impl(real_src string, real_dst string, overwrite bool) -> ! {
	if !exists(real_dst) {
		mkdir(real_dst, 0o777)!
	}

	if !is_dir(real_dst) {
		return error("cannot copy '${real_src}' directory to non-directory '${real_dst}'")
	}

	it := read_dir_iter(real_src)!
	for entry in it {
		src_entry := pathlib.join(real_src, entry.name())
		dst_entry := pathlib.join(real_dst, entry.name())

		src_entry_info := stat(src_entry)!
		filetype := src_entry_info.filetype()
		match filetype {
			.regular => {
				copy_file(src_entry, dst_entry, overwrite)!
			}
			.symbolic_link => {
				copy_symlink(src_entry, dst_entry, overwrite)!
			}
			.directory => {
				copy_dir(src_entry, dst_entry, overwrite)!
			}
			else => {}
		}
	}
}
