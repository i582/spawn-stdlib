module fs

import pathlib
import sys.winapi

// copy_file copies a file from [`src`] to [`dst`].
//
// If the destination is a directory, the source file will be copied into that directory.
// The file attributes of the source file are preserved.
//
// If [`overwrite`] is false and the destination file already exists, an error is returned.
//
// Example:
//
// Copying a file to a different location with overwrite enabled.
// ```
// fs.copy_file("foo.txt", "backup\\foo.txt", overwrite: true) or {
//     eprintln("Failed to copy file: ${err.msg()}")
//     return
// }
// ```
//
// Example:
//
// Copying a file into a directory.
// ```
// fs.copy_file("foo.txt", "backup\\", overwrite: false) or {
//     eprintln("Failed to copy file: ${err.msg()}")
//     return
// }
// // The file will be copied to backup\\foo.txt
// ```
//
// See [`copy_dir`] to copy a directory.
pub fn copy_file(src string, dst string, overwrite bool) -> ! {
	if !is_file(src) {
		return error("'${src}' is not a file")
	}

	final_dst := if is_dir(dst) {
		// copy foo.txt to bar/
		filename := pathlib.file_name(src)
		// bar/foo.txt
		pathlib.join(dst, filename)
	} else {
		dst
	}

	if exists(final_dst) && !overwrite {
		return error("'${final_dst}' already exists")
	}

	if !exists(src) {
		return error("'${src}' doesn't exists")
	}

	src_wide := src.to_wide()
	dst_wide := final_dst.to_wide()

	if !winapi.CopyFileW(src_wide, dst_wide, !overwrite) {
		winapi.throw(false, "failed to copy '${src}' to '${final_dst}'")!
	}

	// From documentation:
	//   File attributes for the existing file are copied to the new file
}
