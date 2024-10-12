module os

import fs
import sys.winapi

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
	mut res := [fs.MAX_PATH_LEN]u16{}
	len := winapi.GetModuleFileName(nil, &mut res[0], fs.MAX_PATH_LEN)
	if len == 0 {
		winapi.throw(false, "cannot retrive path to executable, GetModuleFileName failed")!
	}
	return string.from_wide_with_len(res.raw(), len)
}
