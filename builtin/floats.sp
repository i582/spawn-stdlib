module builtin

import strconv
import intrinsics

#[include('<math.h>')]
#[include('<float.h>')]

extern const (
	FLT_EPSILON = 0.0 as f32
	DBL_EPSILON = 0.0
)

// f32 is the set of all IEEE-754 32-bit floating-point numbers.
pub type f32 = f32

// f64 is the set of all IEEE-754 64-bit floating-point numbers.
pub type f64 = f64

// str returns the string representation of the floating-point number `f`.
//
// Example:
// ```
// num := 3.141592653589793 as f32
// num.str() == '3.141593'
// ```
pub fn (f f32) str() -> string {
	return strconv.float_to_str(f as f64, 6, 512)
}

// str_sci returns the string representation of the floating-point number `f`
// in scientific notation.
//
// Example:
// ```
// num := 3.141592653589793 as f32
// num.str_sci() == '3.141593e+00'
// ```
pub fn (f f32) str_sci() -> string {
	return strconv.float_to_str_scientific(f as f64, 512)
}

// str_g returns the string representation of the floating-point number `f`
// in the format specified by the `g` format specifier.
//
// Example:
// ```
// num := 3.141592653589793 as f32
// num.str_g() == '3.141593'
// ```
pub fn (f f32) str_g() -> string {
	return strconv.float_to_str_g(f as f64, 512)
}

// min returns the smaller of `f` or `other`.
//
// Example:
// ```
// num := 3.141592653589793 as f32
// num.min(2.718281828459045 as f32) == 2.718281828459045
// ```
pub fn (f f32) min(other f32) -> f32 {
	if f < other {
		return f
	}
	return other
}

// max returns the larger of `f` or `other`.
//
// Example:
// ```
// num := 3.141592653589793 as f32
// num.max(2.718281828459045 as f32) == 3.141592653589793
// ```
pub fn (f f32) max(other f32) -> f32 {
	if f > other {
		return f
	}
	return other
}

// eq_epsilon returns whether [`f`] and [`other`] are equal using an epsilon of typically 1E-5
// or higher (backend/compiler dependent).
//
// Example:
// ```
// num := 2.0 as f32
// num.eq_epsilon(2.0 as f32) == true
// ```
pub fn (f f32) eq_epsilon(other f32) -> bool {
	hi := f.abs().max(other.abs())
	delta := (f - other).abs()
	if hi > 1.0 {
		return delta <= hi * (4 * FLT_EPSILON)
	}
	return (1 / (4 * FLT_EPSILON) * delta <= hi)
}

// signnum returns a number that represents the sign of `x`.
pub fn (f f32) signnum() -> f32 {
	if f < 0 {
		return -1
	}
	if f > 0 {
		return 1
	}
	return 0
}

// abs returns the absolute value of `f`.
//
// Example:
// ```
// num := -1.0 as f32
// num.abs() == 1.0
// ```
pub fn (f f32) abs() -> f32 {
	if f < 0 {
		return -f
	}
	return f
}

// sqrt returns the square root of `f`.
//
// Example:
// ```
// num := 3.141592653589793 as f32
// num.sqrt() == 1.7724538509055159
// ```
pub fn (f f32) sqrt() -> f32 {
	return intrinsics.sqrtf32(f)
}

// ln returns the natural logarithm of `f`.
//
// Example:
// ```
// num := 3.141592653589793 as f32
// num.ln() == 1.1447298858494002
// ```
pub fn (f f32) ln() -> f32 {
	return intrinsics.logf32(f)
}

// log2 returns the base 2 logarithm of `f`.
//
// Example:
// ```
// num := 3.141592653589793 as f32
// num.log2() == 1.6514961294723188
// ```
pub fn (f f32) log2() -> f32 {
	return intrinsics.log2f32(f)
}

// log10 returns the base 10 logarithm of `f`.
//
// Example:
// ```
// num := 3.141592653589793 as f32
// num.log10() == 0.49714987269413385
// ```
pub fn (f f32) log10() -> f32 {
	return intrinsics.log10f32(f)
}

// powf returns `f` to the power of `y`.
//
// Example:
// ```
// num := 3.141592653589793 as f32
// num.powf(2.0 as f32) == 9.869604401089358
// ```
pub fn (f f32) powf(y f32) -> f32 {
	return intrinsics.powf32(f, y)
}

// ceil returns the smallest integer value greater than or equal to `f`.
//
// Example:
// ```
// num := 3.141592653589793 as f32
// num.ceil() == 4.0
// ```
pub fn (f f32) ceil() -> f32 {
	return intrinsics.ceilf32(f)
}

// floor returns the largest integer value less than or equal to `f`.
//
// Example:
// ```
// num := 3.141592653589793 as f32
// num.floor() == 3.0
// ```
pub fn (f f32) floor() -> f32 {
	return intrinsics.floorf32(f)
}

// round returns the nearest integer value to `f`.
//
// Example:
// ```
// f1 := 3.3 as f32
// f2 := 3.5 as f32
// f3 := 3.7 as f32
// f1.round() == 3.0
// f2.round() == 4.0
// f3.round() == 4.0
// ```
pub fn (f f32) round() -> f32 {
	return intrinsics.roundf32(f)
}

// trunc returns the nearest integer value not greater in magnitude than `f`.
//
// Example:
// ```
// f1 := 3.3 as f32
// f2 := 3.5 as f32
// f3 := 3.7 as f32
// f1.trunc() == 3.0
// f2.trunc() == 3.0
// f3.trunc() == 3.0
// ```
pub fn (f f32) trunc() -> f32 {
	return intrinsics.truncf32(f)
}

// sin returns the sine of `f` (expressed in radians).
//
// Example:
// ```
// num := 10.0 as f32
// num.sin() == -0.5440211294671393
// ```
pub fn (f f32) sin() -> f32 {
	return intrinsics.sinf32(f)
}

// cos returns the cosine of `f` (expressed in radians).
//
// Example:
// ```
// num := 10.0 as f32
// num.cos() == -0.8390715290764524
// ```
pub fn (f f32) cos() -> f32 {
	return intrinsics.cosf32(f)
}

// tan returns the tangent of `f` (expressed in radians).
//
// Example:
// ```
// num := 10.0 as f32
// num.tan() == 0.6483608274590866
// ```
pub fn (f f32) tan() -> f32 {
	return intrinsics.tanf32(f)
}

// asin returns the arcsine of `f` (expressed in radians).
//
// Example:
// ```
// num := 0.5 as f32
// num.asin() == 0.5235987901687622
// ```
pub fn (f f32) asin() -> f32 {
	return intrinsics.asinf32(f)
}

// acos returns the arccosine of `f` (expressed in radians).
//
// Example:
// ```
// num := 0.5 as f32
// num.acos() == 1.0471975511965976
// ```
pub fn (f f32) acos() -> f32 {
	return intrinsics.acosf32(f)
}

// atan returns the arctangent of `f` (expressed in radians).
//
// Example:
// ```
// num := 0.5 as f32
// num.atan() == 0.4636476090008061
// ```
pub fn (f f32) atan() -> f32 {
	return intrinsics.atanf32(f)
}

// exp returns the exponential of `f`.
//
// Example:
// ```
// num := 0.5 as f32
// num.exp() == 1.6487212707001282
// ```
pub fn (f f32) exp() -> f32 {
	return intrinsics.expf32(f)
}

// exp2 returns 2 raised to the power of `f`.
//
// Example:
// ```
// num := 0.5 as f32
// num.exp2() == 1.4142135623730951
// ```
pub fn (f f32) exp2() -> f32 {
	return intrinsics.exp2f32(f)
}

// hash returns the hash code for the number (same as the number itself).
pub fn (f f32) hash() -> u64 {
	// same as math.f32_bits
	return *((&f) as &u32)
}

// clone returns a copy of the float.
pub fn (f f32) clone() -> f32 {
	return f
}

// cmp compares two floats and returns an [`Ordering`] value.
pub fn (s f32) cmp(b f32) -> Ordering {
	return if s < b { .less } else if s > b { .greater } else { .equal }
}

// str returns the string representation of the floating-point number `f`.
//
// Example:
// ```
// num := 3.141592653589793
// num.str() == '3.141593'
// ```
pub fn (f f64) str() -> string {
	return strconv.float_to_str(f, 6, 512)
}

// str_sci returns the string representation of the floating-point number `f`
// in scientific notation.
//
// Example:
// ```
// num := 3.141592653589793
// num.str_sci() == '3.141593e+00'
// ```
pub fn (f f64) str_sci() -> string {
	return strconv.float_to_str_scientific(f, 512)
}

// str_g returns the string representation of the floating-point number `f`
// in the format specified by the `g` format specifier.
//
// Example:
// ```
// num := 3.141592653589793
// num.str_g() == '3.141593'
// ```
pub fn (f f64) str_g() -> string {
	return strconv.float_to_str_g(f, 512)
}

// min returns the smaller of `f` or `other`.
//
// Example:
// ```
// num := 3.141592653589793
// num.min(2.718281828459045) == 2.718281828459045
// ```
pub fn (f f64) min(other f64) -> f64 {
	if f < other {
		return f
	}
	return other
}

// max returns the larger of `f` or `other`.
//
// Example:
// ```
// num := 3.141592653589793
// num.max(2.718281828459045) == 3.141592653589793
// ```
pub fn (f f64) max(other f64) -> f64 {
	if f > other {
		return f
	}
	return other
}

// eq_epsilon returns whether [`f`] and [`other`] are equal using an epsilon of typically 1E-9
// or higher (backend/compiler dependent).
//
// Example:
// ```
// num := 2.0
// num.eq_epsilon(2.0) == true
// ```
pub fn (f f64) eq_epsilon(other f64) -> bool {
	hi := f.abs().max(other.abs())
	delta := (f - other).abs()
	if hi > 1.0 {
		return delta <= hi * (4 * DBL_EPSILON)
	}
	return (1 / (4 * DBL_EPSILON) * delta <= hi)
}

// signnum returns a number that represents the sign of `x`.
pub fn (f f64) signnum() -> f64 {
	if f < 0 {
		return -1
	}
	if f > 0 {
		return 1
	}
	return 0
}

// abs returns the absolute value of `f`.
//
// Example:
// ```
// num := -1.0
// num.abs() == 1.0
// ```
pub fn (f f64) abs() -> f64 {
	if f < 0 {
		return -f
	}
	return f
}

// sqrt returns the square root of `f`.
//
// Example:
// ```
// num := 3.141592653589793
// num.sqrt() == 1.7724538509055159
// ```
pub fn (f f64) sqrt() -> f64 {
	return intrinsics.sqrtf64(f)
}

// ln returns the natural logarithm of `f`.
//
// Example:
// ```
// num := 3.141592653589793
// num.ln() == 1.1447298858494002
// ```
pub fn (f f64) ln() -> f64 {
	return intrinsics.logf64(f)
}

// log2 returns the base 2 logarithm of `f`.
//
// Example:
// ```
// num := 3.141592653589793
// num.log2() == 1.6514961294723188
// ```
pub fn (f f64) log2() -> f64 {
	return intrinsics.log2f64(f)
}

// log10 returns the base 10 logarithm of `f`.
//
// Example:
// ```
// num := 3.141592653589793
// num.log10() == 0.49714987269413385
// ```
pub fn (f f64) log10() -> f64 {
	return intrinsics.log10f64(f)
}

// powf returns `f` to the power of `y`.
//
// Example:
// ```
// num := 3.141592653589793
// num.powf(2.0) == 9.869604401089358
// ```
pub fn (f f64) powf(y f64) -> f64 {
	return intrinsics.powf64(f, y)
}

// ceil returns the smallest integer value greater than or equal to `f`.
//
// Example:
// ```
// num := 3.141592653589793
// num.ceil() == 4.0
// ```
pub fn (f f64) ceil() -> f64 {
	return intrinsics.ceilf64(f)
}

// floor returns the largest integer value less than or equal to `f`.
//
// Example:
// ```
// num := 3.141592653589793
// num.floor() == 3.0
// ```
pub fn (f f64) floor() -> f64 {
	return intrinsics.floorf64(f)
}

// round returns the nearest integer value to `f`.
//
// Example:
// ```
// f1 := 3.3
// f2 := 3.5
// f3 := 3.7
// f1.round() == 3.0
// f2.round() == 4.0
// f3.round() == 4.0
// ```
pub fn (f f64) round() -> f64 {
	return intrinsics.roundf64(f)
}

// trunc returns the nearest integer value not greater in magnitude than `f`.
//
// Example:
// ```
// f1 := 3.3
// f2 := 3.5
// f3 := 3.7
// f1.trunc() == 3.0
// f2.trunc() == 3.0
// f3.trunc() == 3.0
// ```
pub fn (f f64) trunc() -> f64 {
	return intrinsics.truncf64(f)
}

// sin returns the sine of `f` (expressed in radians).
//
// Example:
// ```
// num := 10.0
// num.sin() == -0.5440211294671393
// ```
pub fn (f f64) sin() -> f64 {
	return intrinsics.sinf64(f)
}

// cos returns the cosine of `f` (expressed in radians).
//
// Example:
// ```
// num := 10.0
// num.cos() == -0.8390715290764524
// ```
pub fn (f f64) cos() -> f64 {
	return intrinsics.cosf64(f)
}

// tan returns the tangent of `f` (expressed in radians).
//
// Example:
// ```
// num := 10.0
// num.tan() == 0.6483608274590866
// ```
pub fn (f f64) tan() -> f64 {
	return intrinsics.tanf64(f)
}

// asin returns the arcsine of `f` (expressed in radians).
//
// Example:
// ```
// num := 0.5
// num.asin() == 0.5235987901687622
// ```
pub fn (f f64) asin() -> f64 {
	return intrinsics.asinf64(f)
}

// acos returns the arccosine of `f` (expressed in radians).
//
// Example:
// ```
// num := 0.5
// num.acos() == 1.0471975511965976
// ```
pub fn (f f64) acos() -> f64 {
	return intrinsics.acosf64(f)
}

// atan returns the arctangent of `f` (expressed in radians).
//
// Example:
// ```
// num := 0.5
// num.atan() == 0.4636476090008061
// ```
pub fn (f f64) atan() -> f64 {
	return intrinsics.atanf64(f)
}

// exp returns the exponential of `f`.
//
// Example:
// ```
// num := 0.5
// num.exp() == 1.6487212707001282
// ```
pub fn (f f64) exp() -> f64 {
	return intrinsics.expf64(f)
}

// exp2 returns 2 raised to the power of `f`.
//
// Example:
// ```
// num := 0.5
// num.exp2() == 1.4142135623730951
// ```
pub fn (f f64) exp2() -> f64 {
	return intrinsics.exp2f64(f)
}

// hash returns the hash code for the number (same as the number itself).
pub fn (f f64) hash() -> u64 {
	// same as math.f64_bits
	return *((&f) as &u64)
}

// clone returns a copy of the float.
pub fn (f f64) clone() -> f64 {
	return f
}

// cmp compares two floats and returns an [`Ordering`] value.
pub fn (s f64) cmp(b f64) -> Ordering {
	return if s < b { .less } else if s > b { .greater } else { .equal }
}
