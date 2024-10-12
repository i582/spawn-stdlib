module winapi

extern {
	pub const (
		INVALID_HANDLE_VALUE = -1 as HANDLE
	)

	pub type HANDLE = *mut void
	pub type HMODULE = *mut void

	pub const (
		EINVAL    = 0
		EAGAIN    = 0
		ETIMEDOUT = 0
	)

	pub const (
		WAIT_OBJECT_0 = 0
		WAIT_TIMEOUT  = 0
		WAIT_FAILED   = 0
	)

	pub fn WaitForSingleObject(hHandle HANDLE, dwMilliseconds u32) -> u32
	pub fn CloseHandle(hObject HANDLE) -> i32
}
