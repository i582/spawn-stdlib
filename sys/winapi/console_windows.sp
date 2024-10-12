module winapi

extern {
	pub const (
		STD_INPUT_HANDLE  = 0 as u32
		STD_OUTPUT_HANDLE = 0 as u32
		STD_ERROR_HANDLE  = 0 as u32
	)

	pub const ENABLE_ECHO_INPUT = 0

	pub const (
		ENABLE_PROCESSED_OUTPUT            = 0
		ENABLE_WRAP_AT_EOL_OUTPUT          = 0
		ENABLE_VIRTUAL_TERMINAL_PROCESSING = 0
		DISABLE_NEWLINE_AUTO_RETURN        = 0
		ENABLE_LVB_GRID_WORLDWIDE          = 0
	)

	pub const (
		ENABLE_EXTENDED_FLAGS = 0
		ENABLE_WINDOW_INPUT   = 0
		ENABLE_MOUSE_INPUT    = 0
	)

	pub fn GetStdHandle(h u32) -> HANDLE
	pub fn ReadConsole(hConsoleInput *void, lpBuffer *void, nNumberOfCharsToRead usize, lpNumberOfCharsRead *mut usize, pInputControl *void) -> bool
	pub fn SetConsoleMode(hConsoleHandle HANDLE, dwMode u32) -> bool
	pub fn GetConsoleMode(hConsoleHandle HANDLE, dwMode *mut u32) -> bool

	#[c_union]
	pub struct uChar {
		UnicodeChar rune
		AsciiChar   u8
	}

	pub struct CHAR_INFO {
		Char       uChar
		Attributes u16
	}

	pub struct COORD {
		X i16
		Y i16
	}

	pub struct SMALL_RECT {
		Left   u16
		Top    u16
		Right  u16
		Bottom u16
	}

	pub struct CONSOLE_SCREEN_BUFFER_INFO {
		dwSize              COORD
		dwCursorPosition    COORD
		wAttributes         u16
		srWindow            SMALL_RECT
		dwMaximumWindowSize COORD
	}

	pub fn GetConsoleScreenBufferInfo(handle HANDLE, info *mut CONSOLE_SCREEN_BUFFER_INFO) -> bool
	pub fn SetConsoleCursorPosition(handle HANDLE, coord COORD) -> bool
	pub fn ScrollConsoleScreenBuffer(output HANDLE, scroll_rect *SMALL_RECT, clip_rect *SMALL_RECT, des COORD, fill *CHAR_INFO) -> bool

	pub fn GetConsoleOutputCP() -> u32
	pub fn SetConsoleOutputCP(wCodePageID u32) -> bool
}
