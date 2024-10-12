module builtin

import strconv

// i128 is the set of all signed 128-bit integers.
// Range: -170_141_183_460_469_231_731_687_303_715_884_105_728 through 170_141_183_460_469_231_731_687_303_715_884_105_727.
pub type i128 = i128

// str returns a string containing the number represented in base 10.
//
// Example:
// ```
// num := 12444 as i128
// num.str() == '12444'
// ```
pub fn (i i128) str() -> string {
	mut buf := [50]u8{}
	len := strconv.sprint_i128(&mut buf[0], 0, i)
	if len < 0 {
		return ''
	}
	return string.view_from_c_str_len(&buf[0], len as usize).clone()
}

// hash returns the hash code for the number.
pub fn (u i128) hash() -> u64 {
	high := (u >> 64) as u64
	low := u as u64
	return wyhash64_(high, low)
}

// max returns the larger of x or y.
//
// Example:
// ```
// assert (100 as i128).max(56 as i128) == 100
// ```
pub fn (x i128) max(y i128) -> i128 {
	if x > y {
		return x
	}
	return y
}

// min returns the smaller of x or y.
//
// Example:
// ```
// assert (100 as i128).min(56 as i128) == 56
// ```
pub fn (x i128) min(y i128) -> i128 {
	if x < y {
		return x
	}
	return y
}

// clone returns the number itself.
//
// Example:
// ```
// num := 100 as i128
// assert num.clone() == 100
// ```
pub fn (x i128) clone() -> u128 {
	return x
}

// cmp compares two values and returns an [`Ordering`] value.
pub fn (s i128) cmp(b i128) -> Ordering {
	return if s < b { .less } else if s > b { .greater } else { .equal }
}

// u128 is the set of all unsigned 128-bit integers.
// Range: 0 through 340_282_366_920_938_463_463_374_607_431_768_211_455.
pub type u128 = u128

// str returns a string containing the number represented in base 10.
//
// Example:
// ```
// num := 12444 as u128
// num.str() == '12444'
// ```
pub fn (i u128) str() -> string {
	mut buf := [50]u8{}
	len := strconv.sprint_u128(&mut buf[0], 0, i)
	if len < 0 {
		return ''
	}
	return string.view_from_c_str_len(&buf[0], len as usize).clone()
}

// hash returns the hash code for the number.
pub fn (u u128) hash() -> u64 {
	high := (u >> 64) as u64
	low := u as u64
	return wyhash64_(high, low)
}

// max returns the larger of x or y.
//
// Example:
// ```
// assert (100 as u128).max(56 as u128) == 100
// ```
pub fn (x u128) max(y i128) -> i128 {
	if x > y {
		return x
	}
	return y
}

// min returns the smaller of x or y.
//
// Example:
// ```
// assert (100 as u128).min(56 as u128) == 56
// ```
pub fn (x u128) min(y i128) -> i128 {
	if x < y {
		return x
	}
	return y
}

// clone returns the number itself.
//
// Example:
// ```
// num := 100 as u128
// assert num.clone() == 100
// ```
pub fn (x u128) clone() -> u128 {
	return x
}

// cmp compares two values and returns an [`Ordering`] value.
pub fn (s u128) cmp(b u128) -> Ordering {
	return if s < b { .less } else if s > b { .greater } else { .equal }
}
