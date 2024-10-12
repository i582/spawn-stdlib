module libc

extern {
	#[link_name("stderr")]
	pub const STDERR = nil as *void

	#[link_name("stdout")]
	pub const STDOUT = nil as *void

	#[link_name("stdin")]
	pub const STDIN = nil as *void

	pub const (
		STDIN_FILENO  = 0
		STDOUT_FILENO = 0
		STDERR_FILENO = 0
	)

	pub const (
		EOF = 0
	)

	pub const (
		O_RDONLY = 0
		O_WRONLY = 0
		O_RDWR   = 0
		O_APPEND = 0
		O_CREAT  = 0
		O_EXCL   = 0
		O_SYNC   = 0
		O_TRUNC  = 0
	)

	pub struct FILE {}

	pub fn sprintf(s *u8, format *u8, args ...any) -> i32
	pub fn snprintf(buf *mut u8, size usize, format *u8, args ...any) -> i32
	pub fn eprintf(format *u8, args ...any) -> i32
	pub fn puts(s *u8) -> i32

	pub fn getline(linep *mut *void, linecapp *mut usize, stream *void) -> isize
	pub fn fgetc(file *FILE) -> i32
	pub fn getchar() -> i32
	pub fn getc(file *FILE) -> i32
	pub fn feof(file *FILE) -> i32
	pub fn ferror(file *FILE) -> i32

	pub fn fflush(f *void) -> i32
	pub fn fileno(file *FILE) -> i32

	pub fn write(fd i32, buf *u8, count i32) -> i32

	pub fn strerror(errnum i32) -> *u8

	pub fn remove(path *u8) -> i32
}
