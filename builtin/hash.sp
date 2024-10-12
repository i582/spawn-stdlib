module builtin

// wyhash64_ is ideal 64-bit hash function
//
// Port of C function from:
// https://github.com/wangyi-fudan/wyhash?tab=readme-ov-file
//
// In user code use `hash.wyhash` module instead of this function.
// This is copied here so as not to depend on the additional module in the builtin.
fn wyhash64_(mut a u64, mut b u64) -> u64 {
	a ^= 0x2d358dccaa6c78a5 as u64
	b ^= 0x8bb84b93962eacc9 as u64
	wymum_(&mut a, &mut b)
	return wymix_(a ^ 0x2d358dccaa6c78a5 as u64, b ^ 0x8bb84b93962eacc9 as u64)
}

fn wymum_(a &mut u64, b &mut u64) {
	mut r := *a as u128
	r *= *b as u128
	*a = r as u64
	*b = (r >> 64) as u64
}

fn wymix_(first u64, second u64) -> u64 {
	lo, hi := wymul_(first, second)
	return lo ^ hi
}

fn wymul_(first u64, second u64) -> (u64, u64) {
	total := (first as u128) * second as u128
	return total as u64, (total >> 64) as u64
}
