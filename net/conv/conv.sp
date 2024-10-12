module conv

pub fn hton16(host u16) -> u16 {
	return (host >> 8) | (host << 8)
}
