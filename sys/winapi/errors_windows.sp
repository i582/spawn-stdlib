module winapi

extern {
	// See https://learn.microsoft.com/ru-ru/windows/win32/api/winbase/nf-winbase-formatmessagew
	pub const (
		FORMAT_MESSAGE_ALLOCATE_BUFFER = 0
		FORMAT_MESSAGE_ARGUMENT_ARRAY  = 0
		FORMAT_MESSAGE_FROM_HMODULE    = 0
		FORMAT_MESSAGE_FROM_STRING     = 0
		FORMAT_MESSAGE_FROM_SYSTEM     = 0
		FORMAT_MESSAGE_IGNORE_INSERTS  = 0
		FORMAT_MESSAGE_MAX_WIDTH_MASK  = 0
	)

	pub fn FormatMessageW(dwFlags u32, lpSource *void, dwMessageId u32, dwLanguageId u32, lpBuffer *mut *u16, nSize u32, args ...any) -> u32
	pub fn LocalFree(hMem *void) -> *void
}

// See https://docs.microsoft.com/en-us/windows/win32/debug/system-error-codes--12000-15999-
pub const (
	MAX_ERROR_CODE = 15841
)

pub struct WinError {
	context string
	code    u32
	msg     string
}

pub fn (w WinError) with_context(context string) -> WinError {
	return WinError{ context: context, code: w.code, msg: w.msg }
}

pub fn (w WinError) msg() -> string {
	if w.context != "" {
		return "${w.context}: ${w.msg} (code: ${w.code})"
	}
	return "${w.msg} (code: ${w.code})"
}

// last_error returns the last error as a [`WinError`] struct.
// If there is no error, it returns `none`.
pub fn last_error() -> ?WinError {
	num := GetLastError()
	if num == 0 || num > MAX_ERROR_CODE {
		return none
	}

	mut buf := nil as *mut u16
	size := FormatMessageW(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS, nil, num, 0, &mut buf, 0, nil)

	if size == 0 {
		return none
	}

	msg := string.from_wide_with_len(buf, size).trim_spaces()

	// FORMAT_MESSAGE_ALLOCATE_BUFFER allocated the buffer, so we need to free it
	LocalFree(buf)

	return WinError{ code: num, msg: msg }
}

pub fn throw(res bool, context string) -> ! {
	if res {
		return
	}

	err := last_error() or { return }
	return error(err.with_context(context))
}
