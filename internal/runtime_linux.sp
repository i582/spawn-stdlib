module internal

import sys.libc

#[include("<sys/syscall.h>")]

extern {
	const SYS_gettid = 0

	fn syscall(num i32) -> i32
	fn getpid() -> i32
}

pub fn get_thread_id() -> u32 {
	return syscall(SYS_gettid) as u32
}

pub fn get_thread_name() -> string {
	if syscall(SYS_gettid) == getpid() {
		return "main"
	}

	comptime if musl {
		// pthread_getname_np is not implemented in musl
		return "<unnamed>"
	}

	thread := libc.pthread_self()
	mut buf := [256]u8{}
	len := libc.pthread_getname_np(thread, &mut buf[0], 256)
	if len == 0 {
		return "<unnamed>"
	}

	return string.view_from_c_str_len(&buf[0], len as usize).clone()
}

pub fn set_thread_name(name string) {
	todo('not implemented yet')
}
