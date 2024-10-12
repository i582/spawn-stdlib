module math

pub const (
	UVNAN     = 0x7FF8000000000001 as u64
	UVINF     = 0x7FF0000000000000 as u64
	UVNEG_INF = 0xFFF0000000000000 as u64
	UVONE     = 0x3FF0000000000000 as u64
)

// inf returns positive infinity if sign >= 0, negative infinity otherwise.
pub fn inf(sign i32) -> f64 {
	mut v := 0 as u64
	if sign >= 0 {
		v = UVINF
	} else {
		v = UVNEG_INF
	}
	return f64_frombits(v)
}

// nan returns an IEEE 754 “not-a-number” value.
pub fn nan() -> f64 {
	return f64_frombits(UVNAN)
}

// is_nan reports whether f is an IEEE 754 “not-a-number” value.
pub fn is_nan(f f64) -> bool {
	// IEEE 754 says that only NaNs satisfy f != f.
	return f != f
}

// is_inf reports whether f is an infinity, according to sign.
// If `sign > 0`, `is_inf` reports whether f is positive infinity.
// If `sign < 0`, `is_inf` reports whether f is negative infinity.
// If `sign == 0`, `is_inf` reports whether f is either infinity.
pub fn is_inf(f f64, sign i32) -> bool {
	return (sign >= 0 && f > MAX_F64) || (sign <= 0 && f < -MAX_F64)
}

// f32_frombits returns the floating point number corresponding
// the the IEEE 754 binary representation b.
// `f32_frombits(f32_bits(f)) == f` for all finite f.
#[no_inline]
pub fn f32_frombits(v u32) -> f32 {
	return *((&v) as &f32)
}

// f32_bits returns the IEEE 754 binary representation of f.
// `f32_bits(f32_frombits(v)) == v` for all v.
#[no_inline]
pub fn f32_bits(f f32) -> u32 {
	return *((&f) as &u32)
}

// f64_frombits retursn the floating point number corresponding
// the the IEEE 754 binary representation b.
// `f64_frombits(f64_bits(f)) == f` for all finite f.
#[no_inline]
pub fn f64_frombits(v u64) -> f64 {
	return *((&v) as &f64)
}

// f64_bits returns the IEEE 754 binary representation of f.
// `f64_bits(f64_frombits(v)) == v` for all v.
#[no_inline]
pub fn f64_bits(f f64) -> u64 {
	return *((&f) as &u64)
}

pub fn mul_u64(x u64, y u64) -> (u64, u64) {
	result := x as u128 * y as u128
	lo := (result & ((1 as u128 << 64) - 1)) as u64
	hi := (result >> 64) as u64

	return hi, lo
}

pub fn add_u64(x u64, y u64, carry u64) -> (u64, u64) {
	sum := x.wrapping_add(y).wrapping_add(carry)
	carry_out := ((x & y) | ((x | y) & ~sum)) >> 63

	return sum, carry_out
}
