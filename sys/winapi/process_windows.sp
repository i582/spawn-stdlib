module winapi

extern {
	pub const (
		CREATE_UNICODE_ENVIRONMENT = 0
	)

	pub fn CreateProcess(lpApplicationName *u16, lpCommandLine *u16, lpProcessAttributes *void, lpThreadAttributes *void, bInheritHandles bool, dwCreationFlags u32, lpEnvironment *void, lpCurrentDirectory *u16, lpStartupInfo *void, lpProcessInformation *void) -> bool
}
