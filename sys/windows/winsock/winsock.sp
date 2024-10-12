module winsock

#[cflags("ws2_32")]
#[include("<winsock2.h>")]
#[include("<ws2tcpip.h>")]

extern {
	#[typedef]
	pub struct WSAData {
		wVersion       u16
		wHighVersion   u16
		szDescription  [257]u8
		szSystemStatus [129]u8
		iMaxSockets    u16
		iMaxUdpDg      u16
		lpVendorInfo   *u8
	}

	pub fn WSAStartup(wVersionRequired u16, lpWSAData *mut WSAData) -> i32
	pub fn WSAGetLastError() -> i32
}
