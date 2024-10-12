module libc

#[cflags("-lpthread")]

extern {
	pub type pthread_t = *void
}
