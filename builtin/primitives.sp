module builtin

import strconv

// u16 is the set of all unsigned 16-bit integers.
// Range: 0 through 65535.
pub type u16 = u16

// str returns a string containing the number represented in base 10.
//
// Example:
// ```
// num := 12444 as u16
// num.str() == '12444'
// ```
pub fn (u u16) str() -> string {
	return strconv.uint_to_str(u, 6)
}

// hex returns a string containing the number represented in base 16.
//
// Note: to get hexadecimal representation with `0x` prefix, use `hex_prefixed()` function.
//
// Example:
// ```
// num := 106 as u16
// num.hex() == '6a'
// ```
pub fn (u u16) hex() -> string {
	return strconv.uint_to_hex(u as u64, 6, false)
}

// hex_prefixed returns a string containing the number represented in base 16 with `0x` prefix.
//
// Note: to get hexadecimal representation without `0x` prefix, use `hex()` function.
//
// Example:
// ```
// num := 106 as u16
// num.hex_prefixed() == '0x6a'
// ```
pub fn (u u16) hex_prefixed() -> string {
	return strconv.uint_to_hex(u as u64, 6, true)
}

// hash returns the hash code for the number.
pub fn (u u16) hash() -> u64 {
	return wyhash64_(u, 0)
}

// cmp compares two values and returns an [`Ordering`] value.
pub fn (s u16) cmp(b u16) -> Ordering {
	return if s < b { .less } else if s > b { .greater } else { .equal }
}

// u32 is the set of all unsigned 32-bit integers.
// Range: 0 through 4294967295.
pub type u32 = u32

// str returns a string containing the number represented in base 10.
//
// Example:
// ```
// num := 12444 as u32
// num.str() == '12444'
// ```
pub fn (u u32) str() -> string {
	return strconv.uint_to_str(u, 10)
}

// hex returns a string containing the number represented in base 16.
//
// Note: to get hexadecimal representation with `0x` prefix, use `hex_prefixed()` function.
//
// Example:
// ```
// num := 106 as u32
// num.hex() == '6a'
// ```
pub fn (u u32) hex() -> string {
	return strconv.uint_to_hex(u as u64, 10, false)
}

// hex_prefixed returns a string containing the number represented in base 16 with `0x` prefix.
//
// Note: to get hexadecimal representation without `0x` prefix, use `hex()` function.
//
// Example:
// ```
// num := 106 as u32
// num.hex_prefixed() == '0x6a'
// ```
pub fn (u u32) hex_prefixed() -> string {
	return strconv.uint_to_hex(u as u64, 10, true)
}

// hash returns the hash code for the number.
pub fn (u u32) hash() -> u64 {
	return wyhash64_(u, 0)
}

// cmp compares two values and returns an [`Ordering`] value.
pub fn (s u32) cmp(b u32) -> Ordering {
	return if s < b { .less } else if s > b { .greater } else { .equal }
}

// u64 is the set of all unsigned 64-bit integers.
// Range: 0 through 18446744073709551615.
pub type u64 = u64

// str returns a string containing the number represented in base 10.
//
// Example:
// ```
// num := 12444 as u64
// num.str() == '12444'
// ```
pub fn (u u64) str() -> string {
	return strconv.uint_to_str(u, 20)
}

// hex returns a string containing the number represented in base 16.
//
// Note: to get hexadecimal representation with `0x` prefix, use `hex_prefixed()` function.
//
// Example:
// ```
// num := 106 as u64
// num.hex() == '6a'
// ```
pub fn (u u64) hex() -> string {
	return strconv.uint_to_hex(u, 4, false)
}

// hex_prefixed returns a string containing the number represented in base 16 with `0x` prefix.
//
// Note: to get hexadecimal representation without `0x` prefix, use `hex()` function.
//
// Example:
// ```
// num := 106 as u64
// num.hex_prefixed() == '0x6a'
// ```
pub fn (u u64) hex_prefixed() -> string {
	return strconv.uint_to_hex(u, 4, true)
}

// hash returns the hash code for the number.
pub fn (u u64) hash() -> u64 {
	return wyhash64_(u, 0)
}

// clone returns the number itself.
pub fn (u u64) clone() -> u64 {
	return u
}

// cmp compares two values and returns an [`Ordering`] value.
pub fn (s u64) cmp(b u64) -> Ordering {
	return if s < b { .less } else if s > b { .greater } else { .equal }
}

// usize is platform-dependent unsigned integer type.
pub type usize = usize

// hex returns a string containing the number represented in base 16.
//
// Note: to get hexadecimal representation with `0x` prefix, use `hex_prefixed()` function.
//
// Example:
// ```
// num := 106 as usize
// num.hex() == '6a'
// ```
pub fn (u usize) hex() -> string {
	return strconv.uint_to_hex(u as u64, 20, false)
}

// hex_prefixed returns a string containing the number represented in base 16 with `0x` prefix.
//
// Note: to get hexadecimal representation without `0x` prefix, use `hex()` function.
//
// Example:
// ```
// num := 106 as usize
// num.hex_prefixed() == '0x6a'
// ```
pub fn (u usize) hex_prefixed() -> string {
	return strconv.uint_to_hex(u as u64, 20, true)
}

// str returns a string containing the number represented in base 10.
//
// Example:
// ```
// num := 12444 as usize
// num.str() == '12444'
// ```
pub fn (u usize) str() -> string {
	return strconv.uint_to_str(u as u64, 20)
}

// min returns the smaller of `u` and `v`.
//
// Example:
// ```
// (100 as usize).min(56 as usize) == 56
// ```
pub fn (u usize) min(v usize) -> usize {
	if u < v {
		return u
	}
	return v
}

// max returns the larger of `u` and `v`.
//
// Example:
// ```
// (100 as usize).max(56 as usize) == 100
// ```
pub fn (u usize) max(v usize) -> usize {
	if u > v {
		return u
	}
	return v
}

// hash returns the hash code for the number.
pub fn (u usize) hash() -> u64 {
	return wyhash64_(u, 0)
}

// cmp compares two values and returns an [`Ordering`] value.
pub fn (s usize) cmp(b usize) -> Ordering {
	return if s < b { .less } else if s > b { .greater } else { .equal }
}

// is_set returns true if isize end of range is valid
pub fn (s usize) is_set() -> bool {
	return s != MAX_USIZE
}

// unset returns an invalid value for usize [`Range`]
pub fn usize.unset() -> usize {
	return MAX_USIZE
}

// i8 is the set of all signed 8-bit integers.
// Range: -128 through 127.
pub type i8 = i8

// str returns a string containing the number represented in base 10.
//
// Example:
// ```
// num := 100 as i8
// num.str() == '100'
// ```
pub fn (u i8) str() -> string {
	return strconv.int_to_str(u as i64, 5)
}

// hex returns a string containing the number represented in base 16.
//
// Note: to get hexadecimal representation with `0x` prefix, use `hex_prefixed()` function.
//
// Example:
// ```
// num := 106 as i8
// num.hex() == '6a'
// ```
pub fn (u i8) hex() -> string {
	return strconv.int_to_hex(u as i64, 4, false)
}

// hex_prefixed returns a string containing the number represented in base 16 with `0x` prefix.
//
// Note: to get hexadecimal representation without `0x` prefix, use `hex()` function.
//
// Example:
// ```
// num := 106 as i8
// num.hex_prefixed() == '0x6a'
// ```
pub fn (u i8) hex_prefixed() -> string {
	return strconv.int_to_hex(u as i64, 4, true)
}

// hash returns the hash code for the number.
pub fn (u i8) hash() -> u64 {
	abs := if u < 0 { -u } else { u }
	return wyhash64_(abs as u64, 0)
}

// cmp compares two values and returns an [`Ordering`] value.
pub fn (s i8) cmp(b i8) -> Ordering {
	return if s < b { .less } else if s > b { .greater } else { .equal }
}

// i16 is the set of all signed 16-bit integers.
// Range: -32768 through 32767.
pub type i16 = i16

// str returns a string containing the number represented in base 10.
//
// Example:
// ```
// num := 100 as i16
// num.str() == '100'
// ```
pub fn (u i16) str() -> string {
	return strconv.int_to_str(u as i64, 7)
}

// hex returns a string containing the number represented in base 16.
//
// Note: to get hexadecimal representation with `0x` prefix, use `hex_prefixed()` function.
//
// Example:
// ```
// num := 106 as i16
// num.hex() == '6a'
// ```
pub fn (u i16) hex() -> string {
	return strconv.int_to_hex(u as i64, 7, false)
}

// hex_prefixed returns a string containing the number represented in base 16 with `0x` prefix.
//
// Note: to get hexadecimal representation without `0x` prefix, use `hex()` function.
//
// Example:
// ```
// num := 106 as i16
// num.hex_prefixed() == '0x6a'
// ```
pub fn (u i16) hex_prefixed() -> string {
	return strconv.int_to_hex(u as i64, 7, true)
}

// hash returns the hash code for the number.
pub fn (u i16) hash() -> u64 {
	abs := if u < 0 { -u } else { u }
	return wyhash64_(abs as u64, 0)
}

// cmp compares two values and returns an [`Ordering`] value.
pub fn (s i16) cmp(b i16) -> Ordering {
	return if s < b { .less } else if s > b { .greater } else { .equal }
}

// i32 is the set of all signed 32-bit integers.
// Range: -2147483648 through 2147483647.
pub type i32 = i32

// str returns a string containing the number represented in base 10.
//
// Example:
// ```
// num := 100 as i32
// num.str() == '100'
// ```
pub fn (u i32) str() -> string {
	return strconv.int_to_str(u as i64, 12)
}

// debug_str returns a string containing the number represented in base 10.
//
// Example:
// ```
// num := 100 as i32
// num.str() == '100'
// ```
pub fn (u i32) debug_str() -> string {
	return u.str()
}

// clone returns the number itself.
//
// Example:
// ```
// num := 100 as i32
// num.clone() == 100
// ```
pub fn (u i32) clone() -> i32 {
	return u
}

// hex returns a string containing the number represented in base 16.
//
// Note: to get hexadecimal representation with `0x` prefix, use `hex_prefixed()` function.
//
// Example:
// ```
// num := 106 as i32
// num.hex() == '6a'
// ```
pub fn (u i32) hex() -> string {
	return strconv.int_to_hex(u as i64, 12, false)
}

// hex_prefixed returns a string containing the number represented in base 16 with `0x` prefix.
//
// Note: to get hexadecimal representation without `0x` prefix, use `hex()` function.
//
// Example:
// ```
// num := 106 as i32
// num.hex_prefixed() == '0x6a'
// ```
pub fn (u i32) hex_prefixed() -> string {
	return strconv.int_to_hex(u as i64, 12, true)
}

// min returns the smaller of `u` and `v`.
//
// Example:
// ```
// 100.min(56) == 56
// ```
pub fn (u i32) min(v i32) -> i32 {
	if u < v {
		return u
	}
	return v
}

// max returns the larger of `u` and `v`.
//
// Example:
// ```
// 100.max(56) == 100
// ```
pub fn (u i32) max(v i32) -> i32 {
	if u > v {
		return u
	}
	return v
}

// abs returns the absolute value of `u`.
//
// Example:
// ```
// assert 100.abs() == 100
// assert -100.abs() == 100
// ```
pub fn (u i32) abs() -> i32 {
	if u < 0 {
		return -u
	}
	return u
}

// hash returns the hash code for the number.
pub fn (u i32) hash() -> u64 {
	abs := if u < 0 { -u } else { u }
	return wyhash64_(abs as u64, 0)
}

// cmp compares two values and returns an [`Ordering`] value.
pub fn (s i32) cmp(b i32) -> Ordering {
	return if s < b { .less } else if s > b { .greater } else { .equal }
}

// i64 is the set of all signed 64-bit integers.
// Range: -9223372036854775808 through 9223372036854775807.
pub type i64 = i64

// str returns a string containing the number represented in base 10.
//
// Example:
// ```
// num := 100 as i64
// num.str() == '100'
// ```
pub fn (u i64) str() -> string {
	return strconv.int_to_str(u, 21)
}

// hex returns a string containing the number represented in base 16.
//
// Note: to get hexadecimal representation with `0x` prefix, use `hex_prefixed()` function.
//
// Example:
// ```
// num := 106 as i64
// num.hex() == '6a'
// ```
pub fn (u i64) hex() -> string {
	return strconv.int_to_hex(u, 21, false)
}

// hex_prefixed returns a string containing the number represented in base 16 with `0x` prefix.
//
// Note: to get hexadecimal representation without `0x` prefix, use `hex()` function.
//
// Example:
// ```
// num := 106 as i64
// num.hex_prefixed() == '0x6a'
// ```
pub fn (u i64) hex_prefixed() -> string {
	return strconv.int_to_hex(u, 21, true)
}

// min returns the smaller of `u` and `v`.
//
// Example:
// ```
// 100.min(56) == 56
// ```
pub fn (u i64) min(v i64) -> i64 {
	if u < v {
		return u
	}
	return v
}

// max returns the larger of `u` and `v`.
//
// Example:
// ```
// 100.max(56) == 100
// ```
pub fn (u i64) max(v i64) -> i64 {
	if u > v {
		return u
	}
	return v
}

// hash returns the hash code for the number.
pub fn (u i64) hash() -> u64 {
	abs := if u < 0 { -u } else { u }
	return wyhash64_(abs as u64, 0)
}

// cmp compares two values and returns an [`Ordering`] value.
pub fn (s i64) cmp(b i64) -> Ordering {
	return if s < b { .less } else if s > b { .greater } else { .equal }
}

// isize is platform-dependent integer type.
pub type isize = isize

// str returns a string containing the number represented in base 10.
//
// Example:
// ```
// num := 100 as isize
// num.str() == '100'
// ```
pub fn (u isize) str() -> string {
	return strconv.int_to_str(u as i64, 21)
}

// hex returns a string containing the number represented in base 16.
//
// Note: to get hexadecimal representation with `0x` prefix, use `hex_prefixed()` function.
//
// Example:
// ```
// num := 106 as isize
// num.hex() == '6a'
// ```
pub fn (u isize) hex() -> string {
	return strconv.int_to_hex(u as i64, 21, false)
}

// hex_prefixed returns a string containing the number represented in base 16 with `0x` prefix.
//
// Note: to get hexadecimal representation without `0x` prefix, use `hex()` function.
//
// Example:
// ```
// num := 106 as isize
// num.hex_prefixed() == '0x6a'
// ```
pub fn (u isize) hex_prefixed() -> string {
	return strconv.int_to_hex(u as i64, 21, true)
}

// max returns the larger of `u` and `v`.
// Example:
// ```
// (100 as isize).max(56 as isize) == 100
// ```
pub fn (u isize) max(v isize) -> isize {
	if u > v {
		return u
	}
	return v
}

// min returns the smaller of `u` and `v`.
// Example:
// ```
// (100 as isize).min(56 as isize) == 56
// ```
pub fn (u isize) min(v isize) -> isize {
	if u < v {
		return u
	}
	return v
}

// hash returns the hash code for the number.
pub fn (u isize) hash() -> u64 {
	abs := if u < 0 { -u } else { u }
	return wyhash64_(abs as u64, 0)
}

// cmp compares two values and returns an [`Ordering`] value.
pub fn (s isize) cmp(b isize) -> Ordering {
	return if s < b { .less } else if s > b { .greater } else { .equal }
}

// is_set returns true if isize end of range is valid
pub fn (i isize) is_set() -> bool {
	return i != MAX_ISIZE
}

// unset returns an invalid value for isize [`Range`]
pub fn isize.unset() -> isize {
	return MAX_ISIZE
}

// void is a pseudo-type that can be used only inside pointers, bare `void` is not allowed.
pub type void = void

// str returns a string hexadecimal representation of the pointer.
//
// Example:
// ```
// ptr := 0xFFFFFF as &void
// ptr.str() == '0xffffff'
// ```
pub fn (u &void) str() -> string {
	// SAFETY: &void can be safely casted to u64.
	return strconv.uint_to_hex(unsafe { u as u64 }, 21, true)
}

// bool is the set of boolean values, true and false.
pub type bool = bool

// str returns the string representation of the boolean.
// Example:
// ```
// (100 > 56).str() == 'true'
// ```
pub fn (u bool) str() -> string {
	return if u { 'true' } else { 'false' }
}

// hash returns the hash code for the boolean.
pub fn (u bool) hash() -> u64 {
	return u as u64
}

// cmp compares two values and returns an [`Ordering`] value.
pub fn (s bool) cmp(b bool) -> Ordering {
	if s == b {
		return .equal
	}
	return if s { .greater } else { .less }
}

// interface Any {}

// any is the set of all types, including function types.
pub type any = any // Any

// never is the bottom type.
// This type can be used only for return type of functions. Functions with `never`
// return type can never return to the caller. Such functions always calls `panic` or
// any other function that never returns or has infinite loop at the end.
pub type never = never

// unit is the Zero-sized type with only one value `()`.
// It is used to represent the absence of a value. For example,
// [`Set[T]`] represented as [`Map[TKey, unit]`].
pub type unit = ()

// str returns the string representation of the unit.
// String representation of the unit is always `()`.
pub fn (u unit) str() -> string {
	return '()'
}

// debug_str returns the string representation of the unit.
pub fn (u unit) debug_str() -> string {
	return '()'
}

// clone returns the unit itself.
pub fn (u unit) clone() -> unit {
	return u
}

// hash returns the hash code for the unit.
pub fn (u unit) hash() -> u64 {
	return wyhash64_(6226215, 0)
}

// equal compares two unit values.
// Since there is only one value of unit type, this function always returns true.
pub fn (u unit) equal(v unit) -> bool {
	return true
}

// cmp compares two values and returns an [`Ordering`] value.
pub fn (s unit) cmp(b unit) -> Ordering {
	return .equal
}
