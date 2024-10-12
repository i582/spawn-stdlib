module rand

// u64_below_max returns a uniformly distributed pseudorandom `u64` number
// in a range `[0, max)` or error if [`max`] is 0.
//
// Example:
// ```
// num := rand.u64_below_max(100).unwrap()
// assert num >= 0 && num < 100
// ```
//
// ```
// err := rand.u64_below_max(0).unwrap_err()
// assert err.msg() == 'max must be bigger than 0'
// ```
//
// NOTE: Using Daniel Lemire's algorithm for fair random number generation
// See https://arxiv.org/abs/1805.10941 and https://lemire.me/blog/2016/06/30/fast-random-shuffling/ links
// to learn more.
pub fn u64_below_max(max u64) -> !u64 {
	if max == 0 {
		return error('max must be bigger than 0')
	}

	mut product := calculate_random_product(max)
	mut low_bits := product.truncate_cast_to_u64()

	if low_bits < max {
		smallest_number := -max % max

		for low_bits < smallest_number {
			product = calculate_random_product(max)
			low_bits = product.truncate_cast_to_u64()
		}
	}

	return (product >> 64) as u64
}

fn calculate_random_product(max u64) -> u128 {
	random_u64 := next_u64()
	return random_u64 as u128 * max as u128
}

// u32_below_max returns a uniformly distributed pseudorandom `u32` number
// in a range `[0, max)` or error if [`max`] is 0.
//
// Example:
// ```
// num := rand.u32_below_max(100).unwrap()
// assert num >= 0 && num < 100
// ```
//
// ```
// err := rand.u32_below_max(0).unwrap_err()
// assert err.msg() == 'max must be bigger than 0'
// ```
pub fn u32_below_max(max u32) -> !u32 {
	// NOTE: because `max` is `u32`, this cast always succeeds.
	return u64_below_max(max)! as u32
}

// u32_in_range returns a uniformly distributed pseudorandom `u32` number
// in a range `[min, max)` or error if [`max`] is less than/equal to [`min`].
//
// Example:
// ```
// num := rand.u32_in_range(1, 100).unwrap()
// assert num >= 0 && num < 100
// ```
//
// ```
// err := rand.u32_in_range(5, 1).unwrap_err()
// assert err.msg() == 'max must be greater than min'
// ```
pub fn u32_in_range(min u32, max u32) -> !u32 {
	if min >= max {
		return error('max must be greater than min')
	}
	return min + u32_below_max(max - min)!
}
