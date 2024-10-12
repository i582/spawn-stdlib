module winapi

extern {
	pub const (
		HANDLE_FLAG_INHERIT = 0
	)

	pub const (
		STARTF_USESTDHANDLES = 0 as u32
	)

	pub struct SECURITY_ATTRIBUTES {
		nLength              u32
		lpSecurityDescriptor *void
		bInheritHandle       bool
	}

	pub struct PROCESS_INFORMATION {
		hProcess    HANDLE
		hThread     HANDLE
		dwProcessId u32
		dwThreadId  u32
	}

	pub struct STARTUPINFOA {
		cb              u32
		lpReserved      *u8
		lpDesktop       *u8
		lpTitle         *u8
		dwX             u32
		dwY             u32
		dwXSize         u32
		dwYSize         u32
		dwXCountChars   u32
		dwYCountChars   u32
		dwFillAttribute u32
		dwFlags         u32
		wShowWindow     u16
		cbReserved2     u16
		lpReserved2     *u8
		hStdInput       HANDLE
		hStdOutput      HANDLE
		hStdError       HANDLE
	}

	pub fn CreatePipe(hReadPipe *mut HANDLE, hWritePipe *mut HANDLE, lpPipeAttributes *SECURITY_ATTRIBUTES, nSize u32) -> bool
	pub fn SetHandleInformation(hObject HANDLE, dwMask u32, dw_flags u32) -> bool
	pub fn ExpandEnvironmentStringsW(lpSrc *u16, lpDst *mut u16, nSize u32) -> u32
	pub fn CreateProcessW(lpApplicationName *u16, lpCommandLine *u16, lpProcessAttributes *SECURITY_ATTRIBUTES, lpThreadAttributes *SECURITY_ATTRIBUTES, bInheritHandles bool, dwCreationFlags u32, lpEnvironment *void, lpCurrentDirectory *u16, lpStartupInfo *void, lpProcessInformation *PROCESS_INFORMATION) -> bool
	pub fn GetExitCodeProcess(hProcess HANDLE, lpExitCode *mut u32) -> bool
}
