module builtin

import mem
import sys.winapi

const CP_UTF8 = 65001

// to_wide converts a string to UTF-16 encoded string that can be used for
// Windows API calls.
pub fn (s string) to_wide() -> &u16 {
	utf8_len := winapi.MultiByteToWideChar(CP_UTF8, 0, s.data, s.len as i32, nil, 0) as usize
	mut ptr := mem.alloc((utf8_len + 1) * mem.size_of[u16]()) as *mut u16
	winapi.MultiByteToWideChar(CP_UTF8, 0, s.data, s.len as i32, ptr, utf8_len as i32)
	unsafe {
		// SAFETY: we know that the memory is valid for `utf8_len + 1` bytes
		// so it's safe to write a null terminator.
		ptr[utf8_len] = 0
	}
	return mem.assume_safe(ptr)
}

// from_wide converts a UTF-16 encoded string to a UTF-8 string.
//
// For known length of the string, use more efficient [`string.from_wide_with_len`]
// instead.
// The passed [`str`] must be null-terminated, otherwise the behavior is undefined.
pub fn string.from_wide(str *u16) -> string {
	if str == nil {
		return ""
	}

	len := winapi.wcslen(str)
	return string.from_wide_with_len(str, len)
}

// from_wide_with_len converts a UTF-16 encoded string to a UTF-8 string.
pub fn string.from_wide_with_len(str *u16, len usize) -> string {
	if str == nil {
		return ""
	}

	utf8_len := winapi.WideCharToMultiByte(CP_UTF8, 0, str, len as i32, nil, 0, nil, nil) as usize
	mut ptr := mem.alloc(utf8_len + 1) as *mut u8
	winapi.WideCharToMultiByte(CP_UTF8, 0, str, len as i32, ptr, utf8_len as i32, nil, nil)
	unsafe {
		// SAFETY: we know that the memory is valid for `utf8_len + 1` bytes
		//         so it's safe to write a null terminator.
		ptr[utf8_len] = 0
	}
	return string.view_from_c_str_len(ptr, utf8_len)
}
