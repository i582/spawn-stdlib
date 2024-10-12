module time

import text
import strings
import sys.libc
import env

// ParseError represents a time parsing error.
pub struct ParseError {
	message string
}

fn ParseError.new(message string) -> ParseError {
	return ParseError{ message: message }
}

// msg implements the `IError.msg()` method for `ParseError`.
pub fn (err ParseError) msg() -> string {
	return 'Invalid time format code: ${err.message}'
}

pub fn parse_rfc3339(s string) -> !Time {
	if s == '' {
		return error(ParseError.new('datetime string is empty'))
	}

	if s.len < "2006-01-02T15:04:05".len {
		return error(ParseError.new('datetime string is too short'))
	}

	mut b := unsafe { s.bytes_no_copy() }

	mut ok := true
	year := parse_uint(b[0..4], 0, 9999, &mut ok)
	month := parse_uint(b[5..7], 1, 12, &mut ok)
	day := parse_uint(b[8..10], 1, days_in(month, year), &mut ok)
	hour := parse_uint(b[11..13], 0, 23, &mut ok)
	min := parse_uint(b[14..16], 0, 59, &mut ok)
	sec := parse_uint(b[17..19], 0, 59, &mut ok)

	if !ok || !(b[4] == b`-` && b[7] == b`-` && b[10] == b`T` && b[13] == b`:` && b[16] == b`:`) {
		return error(ParseError.new('datetime string is invalid'))
	}

	b = b[19..]

	mut nsec := 0
	if b.len >= 2 && b[0] == b`.` && is_digit(b, 1) {
		mut n := 2
		for n < b.len && is_digit(b, n) {
			n++
		}
		nsec = parse_nanoseconds(b, n) or { 0 }
		b = b[n..]
	}

	mut t := date(year, month, day, hour, min, sec, nsec, none)
	if b.len != 1 || b[0] != b`Z` {
		if b.len != "-07:00".len {
			return error(ParseError.new('datetime string is invalid'))
		}

		hr := parse_uint(b[1..3], 0, 23, &mut ok)
		mm := parse_uint(b[4..6], 0, 59, &mut ok)
		if !ok || !((b[0] == b`-` || b[0] == b`+`) && b[3] == b`:`) {
			return error(ParseError.new('datetime string is invalid'))
		}

		mut zone_offset := ((hr * 60 + mm) * 60) as u64
		if b[0] == b`-` {
			t.sub(zone_offset * SECOND)
		} else {
			t.add(zone_offset * SECOND)
		}
	}

	return t
}

fn parse_nanoseconds(value []u8, count i32) -> !i32 {
	if value[0] != b`.` && value[0] != b`,` {
		return error('bad value for field')
	}

	mut rem_value := value
	mut nbytes := count
	if nbytes > 10 {
		rem_value = rem_value[..10]
		nbytes = 10
	}

	slice := rem_value[1..nbytes]
	mut ns := string.view_from_bytes(slice).parse_int() or {
		return error('bad integer value')
	}

	if ns < 0 {
		return error('count < 0')
	}

	// we need nanoseconds, which means scaling by the number
	// of missing digits in the format, maximum length 10.
	scale_digits := 10 - nbytes
	for i in 0 .. scale_digits {
		ns *= 10
	}
	return ns as i32
}

// is_digit reports whether `s[i]` is in range and is a decimal digit.
fn is_digit(s []u8, i i32) -> bool {
	if i >= s.len {
		return false
	}
	c := s[i]
	return c.is_digit()
}

fn parse_uint_in_range(s []u8, min_len i32, max_len i32, min i32, max i32, ok &mut bool) -> (i32, i32) {
	mut x := 0
	mut len := 0
	for i, c in s {
		if i > max_len {
			// we found all digits
			len = max_len
			break
		}

		if c < b`0` || b`9` < c {
			if i >= min_len {
				// we found at least min_len digits
				break
			}

			*ok = false
			return min, len
		}
		x = x * 10 + c as i32 - b`0`
		len++
	}
	if x < min || max < x {
		*ok = false
		return min, len
	}
	return x, len
}

fn parse_uint(s []u8, min i32, max i32, ok &mut bool) -> i32 {
	mut x := 0
	for c in s {
		if c < b`0` || b`9` < c {
			*ok = false
			return min
		}
		x = x * 10 + c as i32 - b`0`
	}
	if x < min || max < x {
		*ok = false
		return min
	}
	return x
}

fn slice_bound(arr []u8, index i32) -> i32 {
	if index >= arr.len {
		return arr.len as i32
	}
	return index
}

pub const (
	ANSIC        = "W MMM _D hh:mm:ss YYYY"
	UNIX_DATE    = "W MMM _D hh:mm:ss ZZZZ YYYY"
	RUBY_DATE    = "W MMM DD hh:mm:ss ZZ YYYY"
	RFC822       = "DD MMM YY hh:mm ZZZZ"
	RFC822Z      = "DD MMM YY hh:mm ZZ"
	RFC850       = "WW, DD-MMM-YY hh:mm:ss ZZZZ"
	RFC1123      = "W, DD MMM YYYY hh:mm:ss ZZZZ"
	RFC1123Z     = "W, DD MMM YYYY hh:mm:ss ZZ"
	RFC3339      = "YYYY-MM-DDThh:mm:ssZZZ"
	RFC3339_NANO = "YYYY-MM-DDThh:mm:ss.nZZZ"     // TODO: n
	KITCHEN      = "h:mmPM"
	STAMP        = "MMM _D hh:mm:ss"
	DATE_TIME    = "YYYY.MM.DD hh:mm:ss"
	DATE_ONLY    = "YYYY.MM.DD"
	TIME_ONLY    = "hh:mm:ss"
)

pub fn (t &Time) custom_format(layout string) -> string {
	mut sb := strings.new_builder(layout.len + 10)

	mut hour_pos := -1 as isize
	mut hour_kind := ChunkType.hour

	mut layout_b := layout.bytes_no_copy()
	for {
		chunk, sep, rem := read_chunk(layout_b) or { break }
		sb.write(sep) or {}

		match chunk {
			.year => {
				sb.write_padded_i64(t.short_year(), 2, b`0`)
			}
			.full_year => {
				sb.write_padded_i64(t.year, 4, b`0`)
			}
			.short_quarter => {
				sb.write_i64(t.quarter())
			}
			.quarter => {
				sb.write_padded_i64(t.quarter(), 2, b`0`)
			}
			.ordinal_quarter => {
				quarter := t.quarter()
				sb.write_i64(quarter)
				sb.write_str(text.ordinal_suffix(quarter))
			}
			.short_month => {
				sb.write_i64(t.month)
			}
			.spaced_month => {
				sb.write_padded_i64(t.month, 2, b` `)
			}
			.ordinal_month => {
				sb.write_i64(t.month)
				sb.write_str(text.ordinal_suffix(t.month))
			}
			.month => {
				sb.write_padded_i64(t.month, 2, b`0`)
			}
			.mid_month => {
				short_name := SHORT_MONTHS_NAMES.get(t.month - 1) or { 'Jan' }
				sb.write_str(short_name)
			}
			.name_month => {
				name := LONG_MONTHS_NAMES.get(t.month - 1) or { 'January' }
				sb.write_str(name)
			}
			.spaced_day => {
				sb.write_padded_i64(t.day, 2, b` `)
			}
			.short_day => {
				sb.write_i64(t.day)
			}
			.day => {
				sb.write_padded_i64(t.day, 2, b`0`)
			}
			.ordinal_day => {
				sb.write_i64(t.day)
				sb.write_str(text.ordinal_suffix(t.day))
			}
			.short_year_day => {
				sb.write_i64(t.day_of_year())
			}
			.ordinal_year_day => {
				day := t.day_of_year()
				sb.write_i64(day)
				sb.write_str(text.ordinal_suffix(day))
			}
			.year_day => {
				sb.write_padded_i64(t.day_of_year(), 3, b`0`)
			}
			.short_hour => {
				hour_kind = .short_hour
				hour_pos = sb.len as isize // save position to correct value for PM
				sb.write_i64(t.hour)
			}
			.hour => {
				hour_pos = sb.len as isize // save position to correct value for PM
				sb.write_padded_i64(t.hour, 2, b`0`)
			}
			.short_minute => {
				sb.write_i64(t.minute)
			}
			.minute => {
				sb.write_padded_i64(t.minute, 2, b`0`)
			}
			.short_second => {
				sb.write_i64(t.second)
			}
			.second => {
				sb.write_padded_i64(t.second, 2, b`0`)
			}
			.short_weekday => {
				weekday := t.day_of_week()
				name := SHORT_WEEKDAY_NAMES.get(weekday) or { 'Mon' }
				sb.write_str(name)
			}
			.weekday => {
				weekday := t.day_of_week()
				name := LONG_WEEKDAY_NAMES.get(weekday) or { 'Monday' }
				sb.write_str(name)
			}
			.short_timezone => {
				off := t.offset()
				if off == 0 {
					sb.write_u8(b`Z`)
				} else {
					hours := off / SECONDS_PER_HOUR
					if hours > 0 {
						sb.write_u8(b`+`)
						sb.write_i64(hours)
					} else {
						sb.write_u8(b`-`)
						sb.write_i64(-hours)
					}
				}
			}
			.timezone => {
				off := t.offset()
				if off == 0 {
					sb.write_u8(b`Z`)
				} else {
					hours := off / SECONDS_PER_HOUR
					if hours > 0 {
						sb.write_u8(b`+`)
						sb.write_padded_i64(hours, 2, b`0`)
						sb.write_str('00')
					} else {
						sb.write_u8(b`-`)
						sb.write_padded_i64(-hours, 2, b`0`)
						sb.write_str('00')
					}
				}
			}
			.colon_timezone => {
				off := t.offset()
				if off == 0 {
					sb.write_u8(b`Z`)
				} else {
					hours := off / SECONDS_PER_HOUR
					if hours > 0 {
						sb.write_u8(b`+`)
						sb.write_padded_i64(hours, 2, b`0`)
						sb.write_str(':00')
					} else {
						sb.write_u8(b`-`)
						sb.write_padded_i64(-hours, 2, b`0`)
						sb.write_str(':00')
					}
				}
			}
			.name_timezone => {
				sb.write_str(t.timezone_name())
			}
			.pm => {
				if hour_pos != -1 {
					actual_value := if t.hour >= 12 { t.hour - 12 } else { t.hour }

					if hour_kind == .hour {
						if actual_value < 10 {
							sb[hour_pos] = b`0` // padding
							sb[hour_pos + 1] = b`0` + actual_value as u8
						} else {
							actual_value_str := actual_value.str()
							for i, ch in actual_value_str {
								sb[hour_pos + i] = ch
							}
						}
					} else if hour_kind == .short_hour {
						actual_value_str := actual_value.str()
						for i, ch in actual_value_str {
							sb[hour_pos + i] = ch
						}

						if actual_value < 10 && t.hour > 10 {
							// need shift whole builder to left
							sb.remove(hour_pos + 1)
						}
					}
				}

				if t.hour >= 12 {
					sb.write_str('PM')
				} else {
					sb.write_str('AM')
				}
			}
		}

		layout_b = rem
	}
	return sb.str_view()
}

var timezone_cache = map[string]i32{}

fn timezone_to_offset(name string) -> i32 {
	if cached := timezone_cache.get(name) {
		return cached
	}

	env.set('TZ', name, overwrite: true)
	libc.tzset()

	off := offset()

	env.unset('TZ')
	libc.tzset()

	// clone name since it created from tmp array
	timezone_cache[name] = off
	return off
}

pub fn parse(layout string, value string) -> !Time {
	mut layout_b := layout.bytes_no_copy()
	mut value_b := value.bytes_no_copy()

	mut ok := true
	mut part_len := 0

	mut year := 0
	mut month := -1
	mut day := -1
	mut yday := -1
	mut hour := 0
	mut min := 0
	mut sec := 0
	mut nsec := 0
	mut weekday := 0
	mut is_pm := false
	mut is_am := false
	mut off_name := []u8{}
	mut off := 0
	mut off_min := 0

	mut year_day := -1

	for {
		chunk, sep, rem := read_chunk(layout_b) or { break }
		if value_b.starts_with_other(sep) {
			value_b = value_b[sep.len..]
		} else {
			return error(ParseError.new('separator `${sep}` not found'))
		}

		match chunk {
			.year => {
				year = parse_uint(value_b[..slice_bound(value_b, 2)], 0, 99, &mut ok) + 2000
				if !ok {
					return error(ParseError.new('invalid year'))
				}
				value_b = value_b[2..]
			}
			.full_year => {
				year = parse_uint(value_b[..slice_bound(value_b, 4)], 0, 9999, &mut ok)
				if !ok {
					return error(ParseError.new('invalid year'))
				}
				value_b = value_b[4..]
			}
			.short_quarter => {
				_, part_len = parse_uint_in_range(value_b[..slice_bound(value_b, 2)], 1, 2, 1, 4, &mut ok)
				if !ok {
					return error(ParseError.new('invalid short quarter'))
				}
				value_b = value_b[part_len..]
			}
			.quarter => {
				_ = parse_uint(value_b[..slice_bound(value_b, 2)], 1, 4, &mut ok)
				if !ok {
					return error(ParseError.new('invalid quarter'))
				}
				value_b = value_b[2..]
			}
			.short_month => {
				month, part_len = parse_uint_in_range(value_b[..slice_bound(value_b, 2)], 1, 2, 1, 12, &mut ok)
				if !ok {
					return error(ParseError.new('invalid month'))
				}
				value_b = value_b[part_len..]
			}
			.spaced_month => {
				len_to_parse := if value_b[0] == b` ` {
					value_b = value_b[1..]
					1
				} else {
					2
				}
				month = parse_uint(value_b[..slice_bound(value_b, len_to_parse)], 1, 12, &mut ok)
				if !ok {
					return error(ParseError.new('invalid spaced month'))
				}
				value_b = value_b[len_to_parse..]
			}
			.month => {
				month = parse_uint(value_b[..slice_bound(value_b, 2)], 1, 12, &mut ok)
				if !ok {
					return error(ParseError.new('invalid month'))
				}
				value_b = value_b[2..]
			}
			.name_month => {
				if value.len < 3 {
					// less than May
					return error(ParseError.new('invalid long month'))
				}

				// get first three bytes to compare over prefix
				start_month_name := string.view_from_c_str_len(value_b.raw(), 3)
				month_rem := value_b[3..]
				month_res, month_len := match start_month_name {
					"Jan" => consume_or_error(month_rem, 'uary', 1), 7
					"Feb" => consume_or_error(month_rem, 'ruary', 2), 8
					"Mar" => consume_or_error(month_rem, 'ch', 3), 5
					"Apr" => consume_or_error(month_rem, 'il', 4), 5
					"May" => Result[i32, Error]{ data: 5 }, 3
					"Jun" => consume_or_error(month_rem, 'e', 6), 4
					"Jul" => consume_or_error(month_rem, 'y', 7), 4
					"Aug" => consume_or_error(month_rem, 'ust', 8), 6
					"Sep" => consume_or_error(month_rem, 'tember', 9), 9
					"Oct" => consume_or_error(month_rem, 'ober', 10), 7
					"Nov" => consume_or_error(month_rem, 'ember', 11), 8
					"Dec" => consume_or_error(month_rem, 'ember', 12), 8
					else => return error(ParseError.new('invalid full month'))
				}
				month = month_res or { return error(err) }
				value_b = value_b[month_len..]
			}
			.mid_month => {
				if value.len < 3 {
					return error(ParseError.new('invalid short month'))
				}
				month_name := string.view_from_c_str_len(value_b.raw(), 3)
				month = match month_name {
					"Jan" => 1
					"Feb" => 2
					"Mar" => 3
					"Apr" => 4
					"May" => 5
					"Jun" => 6
					"Jul" => 7
					"Aug" => 8
					"Sep" => 9
					"Oct" => 10
					"Nov" => 11
					"Dec" => 12
					else => return error(ParseError.new('invalid short month ${month_name}'))
				}

				value_b = value_b[3..]
			}
			.short_day => {
				day, part_len = parse_uint_in_range(value_b[..slice_bound(value_b, 2)], 1, 2, 1, days_in(month, year), &mut ok)
				if !ok {
					return error(ParseError.new('invalid day'))
				}
				value_b = value_b[part_len..]
			}
			.spaced_day => {
				len_to_parse := if value_b[0] == b` ` {
					value_b = value_b[1..]
					1
				} else {
					2
				}
				day = parse_uint(value_b[..slice_bound(value_b, len_to_parse)], 1, days_in(month, year), &mut ok)
				if !ok {
					return error(ParseError.new('invalid spaced day'))
				}
				value_b = value_b[len_to_parse..]
			}
			.day => {
				// day can come before month
				max_value := if month == -1 || year == -1 { 31 } else { days_in(month, year) }
				day = parse_uint(value_b[..slice_bound(value_b, 2)], 1, max_value, &mut ok)
				if !ok {
					return error(ParseError.new('invalid day'))
				}
				value_b = value_b[2..]
			}
			.short_year_day => {
				max_value := if is_leap(year) { 366 } else { 365 }
				year_day, part_len = parse_uint_in_range(value_b[..slice_bound(value_b, 3)], 1, 3, 1, max_value, &mut ok)
				if !ok {
					return error(ParseError.new('invalid short year day'))
				}
				value_b = value_b[part_len..]
			}
			.year_day => {
				max_value := if is_leap(year) { 366 } else { 365 }
				year_day = parse_uint(value_b[..slice_bound(value_b, 3)], 1, max_value, &mut ok)
				if !ok {
					return error(ParseError.new('invalid year day'))
				}
				value_b = value_b[3..]
			}
			.short_hour => {
				hour, part_len = parse_uint_in_range(value_b[..slice_bound(value_b, 2)], 1, 2, 1, 59, &mut ok)
				if !ok {
					return error(ParseError.new('invalid hour'))
				}
				value_b = value_b[part_len..]
			}
			.hour => {
				hour = parse_uint(value_b[..slice_bound(value_b, 2)], 1, 59, &mut ok)
				if !ok {
					return error(ParseError.new('invalid hour'))
				}
				value_b = value_b[2..]
			}
			.short_minute => {
				min, part_len = parse_uint_in_range(value_b[..slice_bound(value_b, 2)], 1, 2, 1, 59, &mut ok)
				if !ok {
					return error(ParseError.new('invalid minute'))
				}
				value_b = value_b[part_len..]
			}
			.minute => {
				min = parse_uint(value_b[..slice_bound(value_b, 2)], 1, 59, &mut ok)
				if !ok {
					return error(ParseError.new('invalid minute'))
				}
				value_b = value_b[2..]
			}
			.short_second => {
				sec, part_len = parse_uint_in_range(value_b[..slice_bound(value_b, 2)], 1, 2, 1, 59, &mut ok)
				if !ok {
					return error(ParseError.new('invalid sec'))
				}
				value_b = value_b[part_len..]
			}
			.second => {
				sec = parse_uint(value_b[..slice_bound(value_b, 2)], 1, 59, &mut ok)
				if !ok {
					return error(ParseError.new('invalid sec'))
				}
				value_b = value_b[2..]
			}
			.weekday => {
				if value.len < 6 {
					// less than Friday
					return error(ParseError.new('invalid long weekday'))
				}

				// get first three bytes to compare over prefix
				start_weekday_name := string.view_from_c_str_len(value_b.raw(), 3)
				weekday_rem := value_b[3..]
				weekday_res, weekday_len := match start_weekday_name {
					"Mon" => consume_or_error(weekday_rem, 'day', 1), 6
					"Tue" => consume_or_error(weekday_rem, 'sday', 2), 7
					"Wed" => consume_or_error(weekday_rem, 'nesday', 3), 9
					"Thu" => consume_or_error(weekday_rem, 'rsday', 4), 8
					"Fri" => consume_or_error(weekday_rem, 'day', 5), 6
					"Sat" => consume_or_error(weekday_rem, 'urday', 6), 8
					"Sun" => consume_or_error(weekday_rem, 'day', 7), 6
					else => return error(ParseError.new('invalid full weekday'))
				}
				weekday = weekday_res or { return error(err) }
				value_b = value_b[weekday_len..]
			}
			.short_weekday => {
				if value.len < 3 {
					return error(ParseError.new('invalid short weekday'))
				}
				weekday_name := string.view_from_c_str_len(value_b.raw(), 3)
				weekday = match weekday_name {
					"Mon" => 1
					"Tue" => 2
					"Wed" => 3
					"Thu" => 4
					"Fri" => 5
					"Sat" => 6
					"Sun" => 7
					else => return error(ParseError.new('invalid short weekday ${weekday_name}'))
				}

				value_b = value_b[3..]
			}
			.short_timezone => {
				if value.len < 2 {
					return error(ParseError.new('invalid short timezone'))
				}

				mut neg := value_b[0] == b`-`
				value_b = value_b[1..]

				off, part_len = parse_uint_in_range(value_b[..slice_bound(value_b, 2)], 1, 2, 0, 14, &mut ok)
				if !ok {
					return error(ParseError.new('invalid short timezone'))
				}
				off *= SECONDS_PER_HOUR
				if neg {
					off *= -1
				}
				value_b = value_b[part_len..]
			}
			.timezone => {
				if value.len < 5 {
					return error(ParseError.new('invalid timezone'))
				}

				if value_b.len == 0 {
					layout_b = rem
					continue
				}

				if value_b[0] == b`Z` {
					value_b = value_b[1..]
					layout_b = rem
					off = 0
					continue
				}

				mut neg := value_b[0] == b`-`
				value_b = value_b[1..]

				full_offset := parse_uint(value_b[..slice_bound(value_b, 4)], 0, 1400, &mut ok)
				if !ok {
					return error(ParseError.new('invalid timezone'))
				}

				off = full_offset / 100
				off_min = full_offset % 100 * SECONDS_PER_MINUTE

				off = off * SECONDS_PER_HOUR + off_min * SECONDS_PER_MINUTE
				if neg {
					off *= -1
				}

				value_b = value_b[4..]
			}
			.colon_timezone => {
				if value.len < 5 {
					return error(ParseError.new('invalid timezone'))
				}

				if value_b.len == 0 {
					layout_b = rem
					continue
				}

				if value_b[0] == b`Z` {
					value_b = value_b[1..]
					layout_b = rem
					off = 0
					continue
				}

				mut neg := value_b[0] == b`-`
				value_b = value_b[1..]

				off = parse_uint(value_b[..slice_bound(value_b, 2)], 0, 14, &mut ok)
				if !ok {
					return error(ParseError.new('invalid timezone hour'))
				}

				value_b = value_b[2..]
				if value_b[0] != b`:` {
					return error(ParseError.new('invalid timezone, missed colon'))
				}
				value_b = value_b[1..]

				off_min = parse_uint(value_b[..slice_bound(value_b, 2)], 0, 59, &mut ok)
				if !ok {
					return error(ParseError.new('invalid timezone hour'))
				}

				off = off * SECONDS_PER_HOUR + off_min * SECONDS_PER_MINUTE
				if neg {
					off *= -1
				}

				value_b = value_b[2..]
			}
			.name_timezone => {
				if value.len < 3 {
					return error(ParseError.new('invalid timezone name'))
				}

				// name timezone can be MST or +04 form
				if value_b[0] in [b`-`, b`+`] {
					value_b = value_b[1..]
					off = parse_uint(value_b[..slice_bound(value_b, 2)], 0, 14, &mut ok)
					if !ok {
						return error(ParseError.new('invalid timezone hour'))
					}
					value_b = value_b[2..]
				} else {
					if value_b.len < 3 {
						return error(ParseError.new('invalid timezone name, too short'))
					}

					off_name = value_b[..slice_bound(value_b, 3)]
					value_b = value_b[3..]
				}
			}
			.pm => {
				// skip AM/PM
				if value_b.starts_with('PM') {
					is_pm = true
				} else if value_b.starts_with('AM') {
					is_am = true
				}

				value_b = value_b[2..]
			}
			else => {}
		}

		layout_b = rem
	}

	if is_pm {
		hour = (hour + 12) % 24
	}

	if day == -1 && month == -1 && year_day != -1 {
		is_leap := if year != -1 { is_leap(year) } else { false }
		day = year_day

		for i in 0 .. DAYS_BEFORE.len {
			mut days := DAYS_BEFORE[i]
			if is_leap && i >= 2 {
				days += 1
			}
			if day <= days {
				month = i as i32
				day -= DAYS_BEFORE[i - 1] + (is_leap && i > 2) as i32
				break
			}
		}
	}

	off_name_str := off_name.ascii_str()
	if off_name.len != 0 {
		off = timezone_to_offset(off_name_str)
	}

	timezone := if off != 0 {
		opt(Timezone{ offset: off, name: off_name_str })
	} else {
		none as ?Timezone
	}

	mut t := date(year, month, day, hour, min, sec, nsec, timezone)
	return t
}

fn consume_or_error(arr []u8, prefix string, val i32) -> !i32 {
	if !arr.starts_with(prefix) {
		return error(ParseError.new('invalid month'))
	}
	return val
}

enum ChunkType {
	year             // YY, 2 digit year, 00..99
	full_year        // YYYY, 4 digit year, 0000..9999
	short_quarter    // Q, quarter, 1, 2, 3, 4
	quarter          // QQ, quarter, 01, 02, 03, 04
	ordinal_quarter  // Qo, quarter, 1st, 2nd, etc.
	short_month      // M, 1..12
	spaced_month     // _M,  1..12
	ordinal_month    // Mo, 1st, 2nd, etc.
	month            // MM, 01..12
	mid_month        // MMM, Jan, Feb, etc.
	name_month       // MMMM, January, February, etc.
	spaced_day       // _D, day of the month, 1..31
	short_day        // D, day of the month, 1..31
	ordinal_day      // Do, day of the month, 1st 2nd, etc.
	day              // DD, day of the month, 01..31
	short_year_day   // DDD, day of the year, 1, 2 .. 364, 365[, 366]
	ordinal_year_day // DDDo, day of the year, 1st , 2nd .. 364th, 365th[, 366th]
	year_day         // DDDD, day of the year, 001, 002 .. 364, 365[, 366]
	short_hour       // h, hour, 1..23
	hour             // hh, hour, 01..23
	short_minute     // m, minute, 0..59
	minute           // mm, minute, 00..59
	short_second     // s, second, 0..59
	second           // ss, second, 00..59
	short_weekday    // W, weekday, Mon, etc.
	weekday          // WW, weekday, Monday, etc.
	short_timezone   // Z, time zone, -7, -6 .. +5, +6
	timezone         // ZZ, time zone, -0700, -0600 .. +0500, +0600
	colon_timezone   // ZZZ, time zone, -07:00, -06:00 .. +05:00, +06:00
	name_timezone    // ZZZZ, time zone, MST or +04
	pm               // PM
}

// known_letter return true if letter can start new chunk
fn known_letter(ch u8) -> bool {
	return ch in [b`Y`, b`M`, b`D`, b`W`, b`P`, b`Z`, b`Q`, b`h`, b`m`, b`s`, b`p`, b`_`]
}

fn read_chunk(layout []u8) -> ?(ChunkType, []u8, []u8) {
	if layout.starts_with('YY') {
		if layout[2..].starts_with('YY') {
			return .full_year, [], layout[4..]
		}

		return .year, [], layout[2..]
	}
	if layout.starts_with('M') {
		if layout[1..].starts_with('M') {
			if layout[2..].starts_with('M') {
				if layout[3..].starts_with('M') {
					return .name_month, [], layout[4..]
				}
				return .mid_month, [], layout[3..]
			}
			return .month, [], layout[2..]
		} else if layout[1..].starts_with('o') {
			return .ordinal_month, [], layout[2..]
		}
		return .short_month, [], layout[1..]
	}
	if layout.starts_with('Q') {
		if layout[1..].starts_with('Q') {
			return .quarter, [], layout[2..]
		} else if layout[1..].starts_with('o') {
			return .ordinal_quarter, [], layout[2..]
		}
		return .short_quarter, [], layout[1..]
	}
	if layout.starts_with('_') {
		if layout[1..].starts_with('M') {
			return .spaced_month, [], layout[2..]
		}
		if layout[1..].starts_with('D') {
			return .spaced_day, [], layout[2..]
		}
	}
	if layout.starts_with('D') {
		if layout[1..].starts_with('D') {
			if layout[2..].starts_with('D') {
				if layout[3..].starts_with('D') {
					return .year_day, [], layout[4..]
				} else if layout[3..].starts_with('o') {
					return .ordinal_year_day, [], layout[4..]
				}
				return .short_year_day, [], layout[3..]
			}
			return .day, [], layout[2..]
		} else if layout[1..].starts_with('o') {
			return .ordinal_day, [], layout[2..]
		}
		return .short_day, [], layout[1..]
	}
	if layout.starts_with('W') {
		if layout[1..].starts_with('W') {
			return .weekday, [], layout[2..]
		}
		return .short_weekday, [], layout[1..]
	}
	if layout.starts_with('h') {
		if layout[1..].starts_with('h') {
			return .hour, [], layout[2..]
		}
		return .short_hour, [], layout[1..]
	}
	if layout.starts_with('m') {
		if layout[1..].starts_with('m') {
			return .minute, [], layout[2..]
		}
		return .short_minute, [], layout[1..]
	}
	if layout.starts_with('s') {
		if layout[1..].starts_with('s') {
			return .second, [], layout[2..]
		}
		return .short_second, [], layout[1..]
	}
	if layout.starts_with('Z') {
		if layout[1..].starts_with('Z') {
			if layout[2..].starts_with('Z') {
				if layout[3..].starts_with('Z') {
					return .name_timezone, [], layout[4..]
				}
				return .colon_timezone, [], layout[3..]
			}
			return .timezone, [], layout[2..]
		}
		return .short_timezone, [], layout[1..]
	}
	if layout.starts_with('PM') {
		return .pm, [], layout[2..]
	}

	// try to advance to next token
	for i, ch in layout {
		// default separators
		if ch == b` ` || ch == b`-` {
			continue
		}
		// likely some letters between
		if !known_letter(ch) {
			continue
		}

		// if we reach here we likely can read next chunk
		chunk, _, rem := read_chunk(layout[i..]) or {
			// no luck, return
			return none
		}

		return chunk, layout[..i], rem
	}

	return none
}

const SHORT_MONTHS_NAMES = [
	"Jan",
	"Feb",
	"Mar",
	"Apr",
	"May",
	"Jun",
	"Jul",
	"Aug",
	"Sep",
	"Oct",
	"Nov",
	"Dec",
]

const LONG_MONTHS_NAMES = [
	"January",
	"February",
	"March",
	"April",
	"May",
	"June",
	"July",
	"August",
	"September",
	"October",
	"November",
	"December",
]

const SHORT_WEEKDAY_NAMES = [
	"Mon",
	"Tue",
	"Wed",
	"Thu",
	"Fri",
	"Sat",
	"Sun",
]

const LONG_WEEKDAY_NAMES = [
	"Monday",
	"Tuesday",
	"Wednesday",
	"Thursday",
	"Friday",
	"Saturday",
	"Sunday",
]
