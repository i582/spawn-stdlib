module winapi

extern {
	pub fn _wgetenv(name *u16) -> *u16
	pub fn _putenv(key_value *u8) -> i32

	pub fn GetEnvironmentStringsW() -> *u16
	pub fn FreeEnvironmentStringsW(ptr *u16) -> i32
}
