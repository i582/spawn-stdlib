module winapi

extern {
	pub const (
		INVALID_FILE_ATTRIBUTES      = 0
		FILE_ATTRIBUTE_DIRECTORY     = 0
		FILE_ATTRIBUTE_REPARSE_POINT = 0
	)

	pub const (
		SYMBOLIC_LINK_FLAG_DIRECTORY                 = 0
		SYMBOLIC_LINK_FLAG_ALLOW_UNPRIVILEGED_CREATE = 0
	)

	pub struct WIN32_FIND_DATA {
		dwFileAttributes   u32
		ftCreationTime     FILETIME
		ftLastAccessTime   FILETIME
		ftLastWriteTime    FILETIME
		nFileSizeHigh      u32
		nFileSizeLow       u32
		dwReserved0        u32
		dwReserved1        u32
		cFileName          *u16     // [MAX_PATH]u16
		cAlternateFileName u32      // [14]u16
	}

	pub fn CopyFileW(lpExistingFileName *u16, lpNewFileName *u16, bFailIfExists bool) -> bool
	pub fn GetFileAttributesW(lpFileName *u16) -> u32
	pub fn SetFileAttributesW(lpFileName *u16, dwFileAttributes u32) -> bool
	pub fn CreateDirectoryW(lpPathName *u16, lpSecurityAttributes *SECURITY_ATTRIBUTES) -> bool
	pub fn RemoveDirectoryW(lpPathName *u16) -> bool
	pub fn CreateSymbolicLinkW(lpSymlinkFileName *u16, lpTargetFileName *u16, dwFlags u32) -> bool
	pub fn CreateHardLinkW(lpFileName *u16, lpExistingFileName *u16, lpSecurityAttributes *SECURITY_ATTRIBUTES) -> bool
	pub fn FindFirstFileW(lpFileName *u16, lpFindFileData *WIN32_FIND_DATA) -> HANDLE
	pub fn FindNextFileW(hFindFile HANDLE, lpFindFileData *WIN32_FIND_DATA) -> i32
	pub fn FindClose(hFindFile HANDLE)
	pub fn _get_osfhandle(fd i32) -> *mut void
	pub fn _wgetcwd(buf *mut u16, size usize) -> *u8
	pub fn _wchdir(path *u16) -> i32
	pub fn _waccess(path *u16, amode i32) -> i32
	pub fn _wremove(path *u16) -> i32
}
