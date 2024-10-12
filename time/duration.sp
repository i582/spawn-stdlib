module time

import strings

pub const (
	// NANOSECOND is one nanosecond as [`Duration`].
	NANOSECOND = 1 as Duration

	// MICROSECOND is count of nanoseconds in 1 microsecond.
	MICROSECOND = 1_000 as Duration

	// MILLISECOND is count of nanoseconds in 1 millisecond.
	MILLISECOND = 1_000_000 as Duration

	// SECOND is count of nanoseconds in 1 second.
	SECOND = 1_000_000_000 as Duration

	// MINUTE is count of nanoseconds in 1 minute.
	MINUTE = (60 as i64 * 1_000_000_000) as Duration

	// HOUR is count of nanoseconds in 1 hour.
	HOUR = (60 as i64 * 60 * 1_000_000_000) as Duration

	// INFINITE represents a maximum value of [`Duration`] ~ 290 years.
	INFINITE = 9223372036854775807 as Duration
)

// Duration represents the elapsed time between two instants
// as an i64 nanosecond count. The representation limits the
// largest representable duration to approximately 290 years.
//
// Example:
// ```
// now := time.instant_now()
// // do something
// elapsed := now.elapsed()
// println(elapsed.as_secs())
// ```
//
// To create a new [`Duration`] use special constants like
// [`SECOND`] or [`MINUTE`].
// ```
// time.sleep(2 * time.SECOND)
// ```
pub type Duration = i64

// from_secs creates a new [`Duration`] from seconds.
pub fn Duration.from_secs(s i64) -> Duration {
	return s * SECOND
}

// from_millis creates a new [`Duration`] from milliseconds.
pub fn Duration.from_millis(ms i64) -> Duration {
	return ms * MILLISECOND
}

// from_micros creates a new [`Duration`] from microseconds.
pub fn Duration.from_micros(us i64) -> Duration {
	return us * MICROSECOND
}

// from_nanos creates a new [`Duration`] from nanoseconds.
pub fn Duration.from_nanos(ns i64) -> Duration {
	return ns
}

// is_zero returns true if [`Duration`] represents zero duration.
pub fn (d Duration) is_zero() -> bool {
	return d == 0
}

// as_secs returns seconds part of duration.
//
// If the duration is less than 1 second, returns 0.
pub fn (d Duration) as_secs() -> i64 {
	return d / SECOND
}

// as_millis returns milliseconds part of duration.
//
// If the duration is less than 1 millisecond, returns 0.
pub fn (d Duration) as_millis() -> i64 {
	return d / MILLISECOND
}

// as_micros returns microseconds part of duration.
//
// If the duration is less than 1 microsecond, returns 0.
pub fn (d Duration) as_micros() -> i64 {
	return d / MICROSECOND
}

// as_nanos returns duration as i64 value.
pub fn (d Duration) as_nanos() -> i64 {
	return d
}

// str returns a string representation of the duration in the form:
// ```txt
// h:m:s      // 5:02:33
// m:s.mi<s>  // 2:33.015
// s.mi<s>    // 33.015s
// mi.mc<ms>  // 15.007ms
// mc.ns<ns>  // 7.234us
// ns<ns>     // 234ns
// ```
pub fn (d Duration) str() -> string {
	if d == INFINITE {
		return "inf"
	}

	if d == 0 {
		return "0s"
	}

	mut t := d as i64
	hr := t / HOUR
	t -= hr * HOUR
	min := t / MINUTE
	t -= min * MINUTE
	sec := t / SECOND
	t -= sec * SECOND
	ms := t / MILLISECOND
	t -= ms * MILLISECOND
	us := t / MICROSECOND
	t -= us * MICROSECOND
	ns := t

	if hr > 0 {
		mut sb := strings.new_builder(10)
		sb.write_i64(hr)
		sb.write_u8(b`:`)
		sb.write_padded_i64(min, 2, b`0`)
		sb.write_u8(b`:`)
		sb.write_padded_i64(sec, 2, b`0`)
		return sb.str_view()
	}

	if min > 0 {
		mut sb := strings.new_builder(10)
		sb.write_i64(min)
		sb.write_u8(b`:`)
		sb.write_padded_i64(sec, 2, b`0`)
		sb.write_u8(b`.`)
		sb.write_padded_i64(ms, 3, b`0`)
		return sb.str_view()
	}

	if sec > 0 {
		mut sb := strings.new_builder(10)
		sb.write_i64(sec)
		sb.write_u8(b`.`)
		sb.write_padded_i64(ms, 3, b`0`)
		sb.write_u8(b`s`)
		return sb.str_view()
	}

	if ms > 0 {
		mut sb := strings.new_builder(10)
		sb.write_i64(ms)
		sb.write_u8(b`.`)
		sb.write_padded_i64(us, 3, b`0`)
		sb.write_str('ms')
		return sb.str_view()
	}

	if us > 0 {
		mut sb := strings.new_builder(10)
		sb.write_i64(us)
		sb.write_u8(b`.`)
		sb.write_padded_i64(ns, 3, b`0`)
		sb.write_str('us')
		return sb.str_view()
	}

	return '${ns}ns'
}
