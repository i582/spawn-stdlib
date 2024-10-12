module libc

extern {
	pub type pthread_t = *void

	pub fn pthread_mach_thread_np(t pthread_t) -> u32
	pub fn pthread_main_np() -> i32
	pub fn pthread_setname_np(name *u8) -> i32
}
