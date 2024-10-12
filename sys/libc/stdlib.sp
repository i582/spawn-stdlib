module libc

extern {
	pub fn exit(code i32) -> never
	pub fn _Exit(code i32) -> never
	pub fn atexit(f fn ()) -> i32

	pub fn realpath(path *u8, resolved *u8) -> *u8

	pub fn gethostname(name *u8, len usize) -> i32
}
