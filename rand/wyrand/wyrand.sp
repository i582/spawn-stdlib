module wyrand

const (
	WYO = 0xa076_1d64_78bd_642f as u64
	WYI = 0xe703_7ed1_a0b4_28db as u64
)

pub struct WyRand {
	state u64
}

pub fn WyRand.new(seed u64) -> WyRand {
	return WyRand{ state: seed }
}

pub fn (r &mut WyRand) u8() -> u8 {
	return (r.rand() & 0xFF) as u8
}

pub fn (r &mut WyRand) u16() -> u16 {
	return (r.rand() & 0xFFFF) as u16
}

pub fn (r &mut WyRand) u32() -> u32 {
	return (r.rand() & 0xFFFF_FFFF as u32) as u32
}

pub fn (r &mut WyRand) u64() -> u64 {
	return r.rand()
}

pub fn (r &mut WyRand) rand() -> u64 {
	value, state := WyRand.next_u64(r.state)
	r.state = state
	return value
}

pub fn WyRand.next_u64(seed u64) -> (u64, u64) {
	new_seed := seed.wrapping_add(WYO)
	return wymix(new_seed, new_seed ^ WYI), new_seed
}
