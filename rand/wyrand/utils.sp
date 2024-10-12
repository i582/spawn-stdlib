module wyrand

fn wymix(first u64, second u64) -> u64 {
	lo, hi := wymul(first, second)
	return lo ^ hi
}

fn wymul(first u64, second u64) -> (u64, u64) {
	total := (first as u128) * second as u128
	return total as u64, (total >> 64) as u64
}
