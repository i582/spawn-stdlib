module internal

import sys.libc
import sys.winapi

pub fn segfault_handler(signal i32) {
	mut buf := [200]u8{}
	libc.snprintf(&mut buf[0], 200, c"fatal error: invalid memory address or nil pointer dereference
[signal: %d: segmentation fault]", signal)
	panic(string.view_from_c_str(&buf[0]))
}

pub fn setup_segfault_handler() {
	libc.signal(libc.SIGSEGV, segfault_handler as libc.sighandler_t)
}

pub fn get_thread_id() -> u32 {
	return winapi.GetCurrentThreadId()
}

pub fn get_thread_name() -> string {
	return '<unnamed>'
}

pub fn set_thread_name(name string) {
	todo('not implemented yet')
}
