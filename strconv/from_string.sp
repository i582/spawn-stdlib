module strconv

import sys.libc

pub fn parse_int(str string, base i32) -> ?i64 {
	if str == '' {
		return none
	}
	if base == 10 {
		return if str[0] == b`-` {
			-(parse_uint_10(str[1..])? as i64)
		} else {
			parse_uint_10(str)? as i64
		}
	}

	mut str_end := nil as *u8
	result := libc.strtoll(str.data, &mut str_end, base)
	// SAFETY: `str.data + str.len` is always a valid pointer to the end of the string.
	if result == 0 && unsafe { str.data + str.len } != str_end {
		return none
	}
	return result
}

pub fn parse_uint_10(str string) -> ?u64 {
	mut x := 0 as i64
	if str.len == 0 || !str[0].is_digit() {
		// string is empty or starts with non digit, so return none
		return none
	}

	for c in str {
		if c < b`0` || b`9` < c {
			return x
		}
		x = x * 10 + c as i32 - b`0`
	}
	return x
}

pub fn parse_uint(str string, base i32) -> ?u64 {
	if str == '' {
		return none
	}
	if str.starts_with('-') {
		return none
	}
	mut str_end := nil as *u8
	result := libc.strtoull(str.data, &mut str_end, base)
	// SAFETY: `str.data + str.len` is always a valid pointer to the end of the string.
	if result == 0 && unsafe { str.data + str.len } != str_end {
		return none
	}
	return result
}

pub fn parse_float(str string) -> ?f64 {
	if str == '' {
		return none
	}
	mut str_end := nil as *u8
	result := libc.strtod(str.data, &mut str_end)
	// SAFETY: `str.data + str.len` is always a valid pointer to the end of the string.
	if result == 0.0 && unsafe { str.data + str.len } != str_end {
		return none
	}
	return result
}
