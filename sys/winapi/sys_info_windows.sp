module winapi

extern {
	pub const (
		PROCESSOR_ARCHITECTURE_AMD64   = 0
		PROCESSOR_ARCHITECTURE_ARM     = 0
		PROCESSOR_ARCHITECTURE_ARM64   = 0
		PROCESSOR_ARCHITECTURE_IA64    = 0
		PROCESSOR_ARCHITECTURE_INTEL   = 0
		PROCESSOR_ARCHITECTURE_UNKNOWN = 0
	)

	pub struct SYSTEM_INFO {
		wProcessorArchitecture u16
		dwNumberOfProcessors   u32
		dwPageSize             u32
	}

	pub fn GetSystemInfo(info *mut SYSTEM_INFO)

	pub fn GetSystemDirectoryW(lpBuffer *mut u16, uSize u32) -> u32
}

// processor_arch_to_string converts a processor architecture constant to a string.
pub fn processor_arch_to_string(arch u16) -> string {
	return match arch {
		PROCESSOR_ARCHITECTURE_AMD64 => "AMD64"
		PROCESSOR_ARCHITECTURE_ARM => "ARM"
		PROCESSOR_ARCHITECTURE_ARM64 => "ARM64"
		PROCESSOR_ARCHITECTURE_IA64 => "IA64"
		PROCESSOR_ARCHITECTURE_INTEL => "INTEL"
		PROCESSOR_ARCHITECTURE_UNKNOWN => "UNKNOWN"
		else => "UNKNOWN"
	}
}
