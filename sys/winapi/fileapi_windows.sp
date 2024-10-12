module winapi

extern {
	pub const (
		GENERIC_READ = 0
	)

	pub const (
		FILE_SHARE_READ = 0
	)

	pub const (
		OPEN_EXISTING = 0
	)

	pub const (
		FILE_FLAG_SESSION_AWARE    = 0
		FILE_FLAG_BACKUP_SEMANTICS = 0
	)

	pub fn CreateFile(lpFileName *u16, dwDesiredAccess u32, dwShareMode u32, lpSecurityAttributes *void, dwCreationDisposition u32, dwFlagsAndAttributes u32, hTemplateFile HANDLE) -> HANDLE
	pub fn ReadFile(hFile HANDLE, lpBuffer *void, nNumberOfBytesToRead u32, lpNumberOfBytesRead *mut u32, lpOverlapped *void) -> bool
	pub fn GetFullPathName(lpFileName *u16, nBufferLength u32, lpBuffer *mut u16, lpFilePart *mut *u16) -> u32

	pub const (
		VOLUME_NAME_DOS = 0
	)

	pub fn GetFinalPathNameByHandle(hFile HANDLE, lpszFilePath *mut u16, cchFilePath u32, dwFlags u32) -> u32

	pub struct BY_HANDLE_FILE_INFORMATION {
		dwFileAttributes u32
	}

	pub fn GetFileInformationByHandle(hFile HANDLE, lpFileInformation *mut BY_HANDLE_FILE_INFORMATION) -> bool
	pub fn GetTempPath(nBufferLength u32, lpBuffer *mut u16) -> u32
}
