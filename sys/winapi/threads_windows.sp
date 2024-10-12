module winapi

extern {
	pub fn CreateThread(lpThreadAttributes *void, dwStackSize u32, lpStartAddress *void, lpParameter *void, dwCreationFlags u32, lpThreadId *u32) -> HANDLE
	pub fn TerminateThread(hThread HANDLE, dwExitCode u32) -> u32
	pub fn GetCurrentThreadId() -> u32
}
