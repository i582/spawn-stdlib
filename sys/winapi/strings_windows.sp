module winapi

extern {
	pub fn wcslen(str *u16) -> usize
	pub fn MultiByteToWideChar(codePage u32, dwFlags u32, lpMultiMyteStr *u8, cbMultiByte i32, lpWideCharStr *mut u16, cchWideChar i32) -> i32
	pub fn WideCharToMultiByte(codePage u32, dwFlags u32, lpWideCharStr *u16, cchWideChar i32, lpMultiByteStr *mut u8, cbMultiByte i32, lpDefaultChar *u8, lpUsedDefaultChar *i32) -> i32
}
