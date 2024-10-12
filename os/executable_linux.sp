module os

import sys.libc
import sys.darwin.libproc
import fs

// executable returns the path name for the executable that started
// the current process. There is no guarantee that the path is still
// pointing to the correct executable. If a symlink was used to start
// the process, depending on the operating system, the result might
// be the symlink or the path it pointed to.
//
// [`executable`] returns an absolute path unless an error occurred.
//
// The main use case is finding resources located relative to an
// executable.
pub fn executable() -> !string {
	mut res := [fs.MAX_PATH_LEN]u8{}
	len := libc.readlink(c'/proc/self/exe', &mut res[0], fs.MAX_PATH_LEN as u32)
	if len <= 0 {
		return error("cannot retrive path to executable, readlink of '/proc/self/exe' failed")
	}
	return string.view_from_c_str_len(res.raw(), len).clone()
}
