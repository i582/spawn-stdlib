module time

import sys.libc
import strings

pub fn (t &Time) format() -> string {
	mut buf := [
		b`0`, b`0`, b`0`, b`0`,
		b`-`,
		b`0`, b`0`,
		b`-`,
		b`0`, b`0`,
		b` `,
		b`0`, b`0`,
		b`:`,
		b`0`, b`0`,
	] as [16]u8

	slice := buf[..]

	write_i32_at(slice, t.year, 4)
	write_i32_at(slice, t.month, 7)
	write_i32_at(slice, t.day, 10)
	write_i32_at(slice, t.hour, 13)
	write_i32_at(slice, t.minute, 16)

	return slice.ascii_str()
}

pub fn (t &Time) format_ss() -> string {
	mut buf := [
		b`0`, b`0`, b`0`, b`0`,
		b`-`,
		b`0`, b`0`,
		b`-`,
		b`0`, b`0`,
		b` `,
		b`0`, b`0`,
		b`:`,
		b`0`, b`0`,
		b`.`,
		b`0`, b`0`,
	] as [19]u8

	slice := buf[..]

	write_i32_at(slice, t.year, 4)
	write_i32_at(slice, t.month, 7)
	write_i32_at(slice, t.day, 10)
	write_i32_at(slice, t.hour, 13)
	write_i32_at(slice, t.minute, 16)
	write_i32_at(slice, t.second, 19)

	return slice.ascii_str()
}

pub fn (t &Time) format_ss_milli() -> string {
	mut buf := [
		b`0`, b`0`, b`0`, b`0`,
		b`-`,
		b`0`, b`0`,
		b`-`,
		b`0`, b`0`,
		b` `,
		b`0`, b`0`,
		b`:`,
		b`0`, b`0`,
		b`:`,
		b`0`, b`0`,
		b`.`,
		b`0`, b`0`, b`0`,
	] as [23]u8

	slice := buf[..]

	write_i32_at(slice, t.year, 4)
	write_i32_at(slice, t.month, 7)
	write_i32_at(slice, t.day, 10)
	write_i32_at(slice, t.hour, 13)
	write_i32_at(slice, t.minute, 16)
	write_i32_at(slice, t.second, 19)
	write_i32_at(slice, (t.nanosecond / 1_000_000) as i32, 23)

	return slice.ascii_str()
}

pub fn (t &Time) format_ss_micro() -> string {
	mut buf := [
		b`0`, b`0`, b`0`, b`0`,
		b`-`,
		b`0`, b`0`,
		b`-`,
		b`0`, b`0`,
		b` `,
		b`0`, b`0`,
		b`:`,
		b`0`, b`0`,
		b`:`,
		b`0`, b`0`,
		b`.`,
		b`0`, b`0`, b`0`, b`0`, b`0`, b`0`,
	] as [26]u8

	slice := buf[..]

	write_i32_at(slice, t.year, 4)
	write_i32_at(slice, t.month, 7)
	write_i32_at(slice, t.day, 10)
	write_i32_at(slice, t.hour, 13)
	write_i32_at(slice, t.minute, 16)
	write_i32_at(slice, t.second, 19)
	write_i32_at(slice, (t.nanosecond / 1_000) as i32, 26)

	return slice.ascii_str()
}

pub fn (t &Time) format_ss_nanos() -> string {
	mut buf := [
		b`0`, b`0`, b`0`, b`0`,
		b`-`,
		b`0`, b`0`,
		b`-`,
		b`0`, b`0`,
		b` `,
		b`0`, b`0`,
		b`:`,
		b`0`, b`0`,
		b`:`,
		b`0`, b`0`,
		b`.`,
		b`0`, b`0`, b`0`, b`0`, b`0`, b`0`, b`0`, b`0`, b`0`,
	] as [29]u8

	slice := buf[..]

	write_i32_at(slice, t.year, 4)
	write_i32_at(slice, t.month, 7)
	write_i32_at(slice, t.day, 10)
	write_i32_at(slice, t.hour, 13)
	write_i32_at(slice, t.minute, 16)
	write_i32_at(slice, t.second, 19)
	write_i32_at(slice, t.nanosecond as i32, 29)

	return slice.ascii_str()
}

pub fn (t &Time) format_rfc3339() -> string {
	arr, len := t.format_rfc3339_impl()
	return arr[..len].ascii_str()
}

pub fn (t &Time) format_rfc3339_to(sb &mut strings.Builder) {
	arr, len := t.format_rfc3339_impl()
	sb.write(arr[..len]) or {}
}

fn (t &Time) format_rfc3339_impl() -> ([25]u8, usize) {
	mut buf := [
		b`0`, b`0`, b`0`, b`0`,
		b`-`,
		b`0`, b`0`,
		b`-`,
		b`0`, b`0`,
		b`T`,
		b`0`, b`0`,
		b`:`,
		b`0`, b`0`,
		b`:`,
		b`0`, b`0`,
		// b`.`,
		// b`0`, b`0`, b`0`,
		b`Z`, // can be `-` or `+` as well
		b`0`, b`0`, b`:`, b`0`, b`0`,
	] as [25]u8

	slice := buf[..]

	write_i32_at(slice, t.year, 4)
	write_i32_at(slice, t.month, 7)
	write_i32_at(slice, t.day, 10)
	write_i32_at(slice, t.hour, 13)
	write_i32_at(slice, t.minute, 16)
	write_i32_at(slice, t.second, 19)

	mut len := 20
	if timezone := t.timezone {
		if timezone.offset < 0 {
			buf[19] = b`-`
		} else {
			buf[19] = b`+`
		}

		hours := timezone.hours().abs()
		minutes := timezone.minutes()
		write_i32_at(slice, hours, 22)
		write_i32_at(slice, minutes, 25)
		len = 25
	}

	// write_i32_at(slice, (t.nanosecond / 1_000_000) as i32, 23)
	return buf, len
}

pub fn (t &Time) hhmm() -> string {
	mut buf := [
		b`0`, b`0`,
		b`:`,
		b`0`, b`0`,
	] as [5]u8

	slice := buf[..]

	write_i32_at(slice, t.hour, 2)
	write_i32_at(slice, t.minute, 5)

	return slice.ascii_str()
}

pub fn (t &Time) hhmmss() -> string {
	mut buf := [
		b`0`, b`0`,
		b`:`,
		b`0`, b`0`,
		b`:`,
		b`0`, b`0`,
	] as [8]u8

	slice := buf[..]

	write_i32_at(slice, t.hour, 2)
	write_i32_at(slice, t.minute, 5)
	write_i32_at(slice, t.second, 8)

	return slice.ascii_str()
}

pub fn (t &Time) strftime(fmt string) -> string {
	tm := gm_time(&t.unix)
	mut buf := [1024]u8{}
	len := libc.strftime(&mut buf[0], 1024, fmt.c_str(), tm)
	return string.view_from_c_str_len(buf.as_ptr(), len).clone()
}

fn write_i32_at(mut slice []u8, val i32, at_end usize) {
	mut num := val
	if num < 0 {
		return
	}

	mut i := (at_end - 1) as isize
	for num > 0 && i >= 0 {
		slice[i] = (num % 10) as u8 + b`0`
		num /= 10
		i--
	}
}
