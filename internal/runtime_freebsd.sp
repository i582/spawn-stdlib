module internal

import sys.libc

pub fn get_thread_id() -> u32 {
	// TODO: support
	return 0
}

pub fn get_thread_name() -> string {
	thread := libc.pthread_self()
	mut buf := [256]u8{}
	len := libc.pthread_getname_np(thread, &mut buf[0], 256)
	if len == 0 {
		return "<unnamed>"
	}

	return string.view_from_c_str_len(&buf[0], len).clone()
}

pub fn set_thread_name(name string) {
	todo('not implemented yet')
}
