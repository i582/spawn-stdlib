module internal

import sys.libc

pub fn get_thread_id() -> u32 {
	return libc.pthread_mach_thread_np(libc.pthread_self())
}

pub fn get_thread_name() -> string {
	if libc.pthread_main_np() != 0 {
		return "main"
	}

	thread := libc.pthread_self()
	mut buf := [256]u8{}
	ok := libc.pthread_getname_np(thread, &mut buf[0], 256)
	if ok != 0 || buf[0] == 0 {
		return "<unnamed>"
	}

	return string.view_from_c_str(&buf[0]).clone()
}

pub fn set_thread_name(name string) {
	libc.pthread_setname_np(name.c_str())
}
