module winapi

extern {
	pub const (
		_O_BINARY = 0
	)

	pub fn _setmode(fd i32, mode i32) -> i32
	pub fn _fileno(file *void) -> i32
}
