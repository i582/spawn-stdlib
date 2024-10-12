module net

const MAX_UNIX_PATH = 104

#[align(1)]
pub struct Ip6 {
	port      u16
	flow_info u32
	addr      [16]u8
	scope_id  u32
}

#[align(1)]
pub struct Ip {
	port    u16
	addr    [4]u8
	sin_pad [8]u8
}

pub struct Unix {
	path [104]u8
}

#[align(1)] // we need this struct to be packed
pub struct Addr {
	len  u8
	f    u8
	addr AddrData
}
