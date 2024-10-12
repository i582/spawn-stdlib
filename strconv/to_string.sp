module strconv

import sys.libc

pub fn uint_to_str(u u64, count_digits usize) -> string {
	mut buf := [25]u8{}
	len := libc.snprintf(&mut buf[0], count_digits + 1, c'%llu', u)
	if len < 0 {
		return ''
	}
	final_len := count_digits.min(len as usize)
	return string.view_from_c_str_len(&buf[0], final_len).clone()
}

pub fn int_to_str(i i64, count_digits usize) -> string {
	mut buf := [25]u8{}
	final_count_digits := if i < 0 { count_digits + 1 } else { count_digits }
	len := libc.snprintf(&mut buf[0], final_count_digits + 1, c'%lld', i)
	if len < 0 {
		return ''
	}
	final_len := final_count_digits.min(len as usize)
	return string.view_from_c_str_len(&buf[0], final_len).clone()
}

pub fn uint_to_hex(u u64, count_digits usize, need_prefix bool) -> string {
	mut buf := [30]u8{}
	mut start := 0 as usize
	if need_prefix {
		start = 2
		buf[0] = b`0`
		buf[1] = b`x`
	}
	len := libc.snprintf(&mut buf[start], count_digits + start + 1, c'%llx', u)
	if len < 0 {
		return ''
	}
	final_len := (count_digits + start).min(len as usize + start)
	return string.view_from_c_str_len(&buf[0], final_len).clone()
}

pub fn int_to_hex(i i64, count_digits usize, need_prefix bool) -> string {
	mut buf := [25]u8{}
	mut start := 0
	mut num := i
	if i < 0 {
		start = 1
		buf[0] = b`-`
		num = -i
	}
	if need_prefix {
		buf[start] = b`0`
		buf[start + 1] = b`x`
		start += 2
	}
	len := libc.snprintf(&mut buf[start], count_digits + 1, c'%llx', num)
	if len < 0 {
		return ''
	}
	final_len := (count_digits + start).min(len as usize + start)
	return string.view_from_c_str_len(&buf[0], final_len).clone()
}

pub fn uint_to_octal(u u64, count_digits usize) -> string {
	mut buf := [25]u8{}
	len := libc.snprintf(&mut buf[0], count_digits + 1, c'%llo', u)
	if len < 0 {
		return ''
	}
	final_len := count_digits.min(len as usize)
	return string.view_from_c_str_len(&buf[0], final_len).clone()
}

pub fn float_to_str(f f64, count_after_dot usize, count_digits usize) -> string {
	mut buf := [512]u8{}
	len := libc.snprintf(&mut buf[0], count_digits, c'%.*f', count_after_dot, f)
	if len < 0 {
		return ''
	}
	return string.view_from_c_str_len(&buf[0], len as usize).clone()
}

pub fn float_to_str_scientific(f f64, count_digits usize) -> string {
	mut buf := [512]u8{}
	len := libc.snprintf(&mut buf[0], count_digits, c'%e', f)
	if len < 0 {
		return ''
	}
	return string.view_from_c_str_len(&buf[0], len as usize).clone()
}

pub fn float_to_str_g(f f64, count_digits usize) -> string {
	mut buf := [512]u8{}
	len := libc.snprintf(&mut buf[0], count_digits, c'%g', f)
	if len < 0 {
		return ''
	}
	return string.view_from_c_str_len(&buf[0], len as usize).clone()
}

const P10_U64 = 10000000000000000000 as u64 // 19 zeros

// sprint_u128 prints unsigned 128-bit integer to buffer and
// returns the number of bytes written.
//
// Buffer must be large enough to hold the result.
pub fn sprint_u128(buf *mut u8, index i32, val u128) -> i32 {
	mut len := 0
	if val > MAX_U64 {
		leading := val / P10_U64
		trailing := (val % P10_U64) as u64
		add_len := sprint_u128(buf, index, leading)
		len = add_len
		len += unsafe { libc.sprintf(buf + index + len, c"%019llu", trailing) }
	} else {
		len = unsafe { libc.sprintf(buf + index, c"%llu", val as u64) }
	}
	return len
}

// sprint_i128 prints signed 128-bit integer to buffer and
// returns the number of bytes written.
//
// Buffer must be large enough to hold the result.
pub fn sprint_i128(buf *mut u8, index i32, val i128) -> i32 {
	if val < 0 {
		mut len := 0
		len += unsafe { libc.sprintf(buf + index, c"-") }
		len += sprint_u128(buf, index + len, -val as u128)
		return len
	}
	return sprint_u128(buf, index, val as u128)
}
