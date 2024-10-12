module builtin

import sys.libc
import sys.winapi

var original_code_page = 0

fn restore_codepage() {
	winapi.SetConsoleOutputCP(original_code_page)
}

// is_terminal_mode returns 1 if the [`fd`] file descriptor is open and refers to a terminal
//
// This function is copy of [`fs.is_atty`] vendored here to avoid
// depending on the FS module
fn is_terminal_mode(fd i32) -> i32 {
	mut mode := 0 as u32
	osfh := winapi._get_osfhandle(fd)
	winapi.GetConsoleMode(osfh, &mut mode)
	return mode as i32
}

pub fn builtin_init() {
	// we need to restore the previous code page so as not
	// to change anything outside the current process
	original_code_page = winapi.GetConsoleOutputCP()
	winapi.SetConsoleOutputCP(65001)

	// call atexit directly to avoid depending on the OS module
	libc.atexit(restore_codepage)

	if is_terminal_mode(fd: 1) > 0 {
		stdout_handle := winapi.GetStdHandle(winapi.STD_OUTPUT_HANDLE)
		stderr_handle := winapi.GetStdHandle(winapi.STD_ERROR_HANDLE)

		mode := winapi.ENABLE_PROCESSED_OUTPUT | winapi.ENABLE_WRAP_AT_EOL_OUTPUT | winapi.ENABLE_VIRTUAL_TERMINAL_PROCESSING
		winapi.SetConsoleMode(stdout_handle, mode)
		winapi.SetConsoleMode(stderr_handle, mode)
	}
}
