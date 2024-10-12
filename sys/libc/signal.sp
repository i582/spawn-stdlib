module libc

pub type sighandler_t = usize

extern {
	pub const (
		SIGSEGV = 0
		SIGUSR1 = 0
		SIGUSR2 = 0
	)

	pub const (
		SIG_DFL = 0 as sighandler_t
		SIG_IGN = 0 as sighandler_t
		SIG_ERR = 0 as sighandler_t
	)

	pub fn signal(sig i32, handler sighandler_t) -> sighandler_t
}
