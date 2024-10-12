module libc

extern {
	pub type pthread_t = *void

	pub fn pthread_main_np() -> i32
}
