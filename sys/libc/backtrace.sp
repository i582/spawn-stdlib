module libc

extern {
	pub fn backtrace(a *mut *void, size i32) -> i32
	pub fn backtrace_symbols(a *mut *void, size i32) -> **u8
	pub fn backtrace_symbols_fd(a *mut *void, size i32, fd i32)
}
