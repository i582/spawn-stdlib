module winapi

pub const (
	MAX_COMPUTERNAME_LENGTH = 255
)

extern {
	pub fn GetComputerNameW(lpBuffer *mut u16, nSize *u32) -> bool
}
