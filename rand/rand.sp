module rand

import time
import rand.wyrand

var default_rng = wyrand.WyRand.new(time.system_now().unix_nanos())

pub fn create_generator(seed u64) {
	default_rng = wyrand.WyRand.new(seed)
}

pub fn next_u32() -> u32 {
	return default_rng.u32()
}

pub fn next_u64() -> u64 {
	return default_rng.u64()
}

pub fn next_usize() -> usize {
	return default_rng.u64() as usize
}
