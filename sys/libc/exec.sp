module libc

extern {
	pub fn popen(c *u8, t *u8) -> *void
	pub fn pclose(stream *FILE) -> i32
	pub fn read(fd i32, buf *void, count usize) -> i32
}
