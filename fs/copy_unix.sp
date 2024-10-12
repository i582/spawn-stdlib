module fs

import io
import pathlib
import sys.libc

// copy_file copies a file from [`src`] to [`dst`].
//
// If the destination is a directory, the source file will be copied into that directory.
// The file permissions (mode) of the source file are preserved.
//
// If [`overwrite`] is false and the destination file already exists, an error is returned.
//
// Example:
//
// Copying a file to a different location with overwrite enabled.
// ```
// fs.copy_file("foo.txt", "backup/foo.txt", overwrite: true) or {
//     eprintln("Failed to copy file: ${err.msg()}")
//     return
// }
// ```
//
// Example:
//
// Copying a file into a directory.
// ```
// fs.copy_file("foo.txt", "backup/", overwrite: false) or {
//     eprintln("Failed to copy file: ${err.msg()}")
//     return
// }
// // The file will be copied to backup/foo.txt
// ```
//
// See [`copy_dir`] to copy a directory.
pub fn copy_file(src string, dst string, overwrite bool) -> ! {
	src_stat := stat(src)!
	if src_stat.filetype() == .directory {
		return error("'${src}' is a directory")
	}
	if src_stat.filetype() != .regular {
		return error("'${src}' is not a regular file")
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
		return error("'${final_dst}' is already exist")
	}

	mut src_file := open_file(src, "r") or {
		return error("cannot copy file '${src}': ${err.num.desc()}")
	}
	mut dst_file := open_file(final_dst, "w") or {
		src_file.close()!
		return error("cannot copy file to '${final_dst}': ${err.num.desc()}")
	}

	io.copy(dst_file, src_file)!

	// copy mode
	chmod(final_dst, src_stat.mode)!

	src_file.close()!
	dst_file.close()!
}
