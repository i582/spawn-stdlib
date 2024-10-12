module wyhash

// wyhash64 is ideal 64-bit hash function
//
// Port of C function from:
// https://github.com/wangyi-fudan/wyhash?tab=readme-ov-file
pub fn wyhash64(mut a u64, mut b u64) -> u64 {
	a ^= 0x2d358dccaa6c78a5 as u64
	b ^= 0x8bb84b93962eacc9 as u64
	wymum(&mut a, &mut b)
	return wymix(a ^ 0x2d358dccaa6c78a5 as u64, b ^ 0x8bb84b93962eacc9 as u64)
}

fn wymum(a &mut u64, b &mut u64) {
	mut r := *a as u128
	r *= *b as u128
	*a = r as u64
	*b = (r >> 64) as u64
}

fn wymix(first u64, second u64) -> u64 {
	lo, hi := wymul(first, second)
	return lo ^ hi
}

fn wymul(first u64, second u64) -> (u64, u64) {
	total := (first as u128) * second as u128
	return total as u64, (total >> 64) as u64
}
