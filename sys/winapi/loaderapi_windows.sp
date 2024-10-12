module winapi

extern {
	pub fn GetModuleFileName(hModule HMODULE, lpFilename *u16, nSize u32) -> u32
}
