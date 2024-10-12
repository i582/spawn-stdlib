module libc

extern {
	pub fn strncpy(dest *mut u8, src *u8, len usize) -> *u8
	pub fn strcat(dest *mut u8, src *u8) -> *u8
	pub fn strcmp(dest *u8, src *u8) -> i32
	pub fn strncmp(dest *u8, src *u8, size usize) -> i32
	pub fn strlen(s *u8) -> usize
	pub fn atoi(c *u8) -> i32
	pub fn ultoa(num u64, str *u8, radix i32) -> *u8
	pub fn strchr(hs *u8, ch i32) -> *u8
	pub fn memchr(hs *u8, ch i32, size usize) -> *u8

	pub fn strtoll(str *u8, str_end *mut *u8, base i32) -> i64
	pub fn strtoull(str *u8, str_end *mut *u8, base i32) -> u64
	pub fn strtod(str *u8, str_end *mut *u8) -> f64
}
