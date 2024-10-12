module libc

extern {
	pub var environ = nil as **u8

	pub fn getenv(name *u8) -> *u8
	pub fn setenv(name *u8, value *u8, overwrite i32) -> i32
	pub fn unsetenv(name *u8) -> i32
}
