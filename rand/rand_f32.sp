module rand

import math
import intrinsics

const (
	STARTING_EXPONENT         = 126 as u32
	STARTING_MASK             = (1 as u32) << 31
	EXPONENT_FOR_O_RANDOM_U32 = STARTING_EXPONENT - 31
	F32_EXPONENT_BITS         = 8
	MIN_EXPONENT              = STARTING_EXPONENT - F32_EXPONENT_BITS
	F32_MANTISSA_BITS         = 23
	IEEE754_MANTISSA_F32_MASK = ((1 as u32) << F32_MANTISSA_BITS) - 1
)

// next_f32 returns a pseudorandom `f32` value in range `[0, 1)` with full precision
// (mantissa random between 0 and 1 and the exponent varies as well).
//
// See https://allendowney.com/research/rand/ for background of the method.
//
// Example:
// ```
// random_number := rand.next_f32()
// assert random_number >= 0 && random_number < 1
// ```
pub fn next_f32() -> f32 {
	mut random_u32 := next_u32()
	mut exponent := STARTING_EXPONENT

	// check if prng returns 0; rare but keep looking for precision
	if intrinsics.unlikely(random_u32 == 0) {
		random_u32 = next_u32()
		exponent = EXPONENT_FOR_O_RANDOM_U32
	}

	mut mask := STARTING_MASK

	// count leading one bits and scale exponent accordingly
	for random_u32 & mask != 0 {
		mask >>= 1
		exponent -= 1
	}

	// if we used any high-order mantissa bits; replace x
	if exponent < MIN_EXPONENT {
		random_u32 = next_u32()
	}

	// Assumes little-endian IEEE floating point.
	random_f32_bits := (exponent << F32_MANTISSA_BITS) | (random_u32 >> F32_EXPONENT_BITS) & IEEE754_MANTISSA_F32_MASK

	return math.f32_frombits(random_f32_bits)
}
