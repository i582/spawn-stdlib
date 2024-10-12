module bits

pub fn add64(x u64, y u64, carry u64) -> (u64, u64) {
	sum := x.wrapping_add(y).wrapping_add(carry)

	// The sum will overflow if both top bits are set (x & y) or if one of them
	// is (x | y), and a carry from the lower place happened. If such a carry
	// happens, the top bit will be 1 + 0 + 1 = 0 (&^ sum).
	carry_out := ((x & y) | ((x | y) & ~sum)) >> 63
	return sum, carry_out
}

pub fn sub64(x u64, y u64, borrow u64) -> (u64, u64) {
	diff := x.wrapping_sub(y).wrapping_sub(borrow)

	// The difference will underflow if the top bit of x is not set and the top
	// bit of y is set (^x & y) or if they are the same (^(x ^ y)) and a borrow
	// from the lower place happens. If that borrow happens, the result will be
	// 1 - 1 - 1 = 0 - 0 - 1 = 1 (& diff).
	borrow_out := ((~x & y) | (~(x ^ y) & diff)) >> 63
	return diff, borrow_out
}
