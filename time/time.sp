module time

import sys.libc

pub const (
	SECONDS_PER_MINUTE = 60
	SECONDS_PER_HOUR   = 60 * 60
	SECONDS_PER_DAY    = 24 * 60 * 60
	SECONDS_PER_WEEK   = 7 * 24 * 60 * 60
	SECONDS_PER_YEAR   = 365 * 24 * 60 * 60

	DAYS_PER_400_YEARS = 365 * 400 + 97
	DAYS_PER_100_YEARS = 365 * 100 + 24
	DAYS_PER_4_YEARS   = 365 * 4 + 1
	DAYS_IN_YEAR       = 365
)

// now returns the current time in the local timezone.
//
// To get the current time in UTC, use [`utc`].
pub fn now() -> Time {
	return Time.now()
}

// utc returns the current time in UTC.
//
// To get the current time in the local timezone, use [`now`].
pub fn utc() -> Time {
	return Time.utc()
}

// offset returns local time zone UTC offset in seconds.
pub fn offset() -> i32 {
	t := utc()
	local := t.local()
	return (local.unix - t.unix) as i32
}

// date returns the [`Time`] corresponding to
// ```text
// yyyy-mm-dd hh:mm:ss + nsec nanoseconds
// ```
// in the appropriate zone for that time in the given location.
//
// If the values passed do not specify a year or month or day they
// are set to 1. Passing only a time will result in a date of
// January 1, 0001 being created.
pub fn date(year i32, month i32, day i32, hour i32, min i32, sec i32, nsec i32, timezone ?Timezone) -> Time {
	// TODO: normalize
	return Time{
		year: year.max(1) // set year to 1 as minimum value
		month: month.max(1) // set month to 1 as minimum value
		day: day.max(1) // set day to 1 as minimum value
		hour: hour
		minute: min
		second: sec
		nanosecond: nsec
		timezone: timezone
	}
}

pub struct Timezone {
	name   string
	offset i32
}

pub fn (t &Timezone) hours() -> i32 {
	return t.offset / (60 * 60)
}

pub fn (t &Timezone) minutes() -> i32 {
	return (t.offset - t.hours() * SECONDS_PER_HOUR) / SECONDS_PER_MINUTE
}

pub struct Time {
	year       i32
	month      i32
	day        i32
	hour       i32
	minute     i32
	second     i32
	nanosecond i64
	unix       i64
	is_local   bool
	timezone   ?Timezone
}

// from_nanos returns a new [`Time`] instance from the given Unix
// timestamp in seconds and nanoseconds.
//
// The timestamp is the number of seconds elapsed since 1970-01-01 00:00:00 UTC.
pub fn Time.from_nanos(secs i64, nanos i64) -> Time {
	mut day_offset := secs / SECONDS_PER_DAY
	if secs % SECONDS_PER_DAY < 0 {
		// If the time is negative, we need to subtract a day to get the correct day
		day_offset--
	}

	year, month, day := calculate_date_from_day_offset(day_offset)
	hour, minute, second := calculate_time_from_second_offset(secs % SECONDS_PER_DAY)

	return Time{
		year: year
		month: month
		day: day
		hour: hour
		minute: minute
		second: second
		nanosecond: nanos
		unix: secs
	}
}

// from_days_after_unix_epoch returns an new [`Time`] instance from the given `days` after
// the unix epoch 1970-01-01.
//
// Only the year, month and day of the returned [`Time`] will be set, everything else will be 0.
//
// To get days back, use [`Time.days_from_unix_epoch`].
pub fn Time.from_days_after_unix_epoch(days i64) -> Time {
	year, month, day := calculate_date_from_day_offset(days)
	return Time{
		year: year
		month: month
		day: day
	}
}

// str returns the time formatted in RFC3339 format.
pub fn (t &Time) str() -> string {
	return t.format_rfc3339()
}

// since returns the duration elapsed since the given time.
// TODO: what if the time is in the future?
pub fn (t &Time) since(other Time) -> Duration {
	return t.diff(other)
}

// after reports whether the time is after the given time.
// TODO: what if the time is in the future?
pub fn (t &Time) after(other Time) -> bool {
	return t.unix > other.unix || (t.unix == other.unix && t.nanosecond > other.nanosecond)
}

// diff returns the duration between the two times.
pub fn (t &Time) diff(other Time) -> Duration {
	unixs := (t.unix - other.unix) * SECOND
	nanos := t.nanosecond - other.nanosecond
	return unixs + nanos
}

// add returns a new time instance with the given duration added to the time.
pub fn (t &Time) add(dur Duration) -> Time {
	return Time.from_nanos(t.unix + dur / SECOND, t.nanosecond + dur % SECOND)
}

// add_days returns a new time instance with the given number of days added to the time.
pub fn (t &Time) add_days(days i64) -> Time {
	return Time.from_nanos(t.unix + days * SECONDS_PER_DAY, t.nanosecond)
}

// sub returns a new time instance with the given duration subtracted from the time.
pub fn (t &Time) sub(dur Duration) -> Time {
	return Time.from_nanos(t.unix - dur / SECOND, t.nanosecond - dur % SECOND)
}

// sub_days returns a new time instance with the given number of days subtracted from the time.
pub fn (t &Time) sub_days(days i64) -> Time {
	return Time.from_nanos(t.unix - days * SECONDS_PER_DAY, t.nanosecond)
}

// unix_time returns the UNIX time with second resolution.
pub fn (t &Time) unix_time() -> i64 {
	return t.unix
}

// offset returns time zone UTC offset in seconds.
// If time is local, returns local time zone UTC offset in seconds.
pub fn (t &Time) offset() -> i32 {
	if t.is_local {
		return offset()
	}
	if timezone := t.timezone {
		return timezone.offset
	}
	// UTC time
	return 0
}

// timezone_name returns name of timezone for this time.
pub fn (t &Time) timezone_name() -> string {
	if t.is_local {
		return string.view_from_c_str(libc.tzname[0])
	}

	if timezone := t.timezone {
		if timezone.name.len != 0 {
			return timezone.name
		}
	}

	return 'UTC'
}

// short_year returns only two number of year.
pub fn (t &Time) short_year() -> i64 {
	return t.year % 100
}

// quarter returns number of quarter of year,
pub fn (t &Time) quarter() -> i64 {
	return (t.month + 2) / 3
}

// day_of_week returns the current day of week as an integer.
pub fn (t &Time) day_of_week() -> i32 {
	return day_of_week(t.year, t.month, t.day - 1)
}

// day_of_year returns the current day of year as an integer.
pub fn (t &Time) day_of_year() -> i32 {
	days_before := DAYS_BEFORE.get(t.month - 1) or { 0 }
	mut res := t.day + days_before
	if is_leap(t.year) {
		if t.month > 2 {
			// add one day only if current date after 29 february
			res++
		}
	}

	return res
}

// days_from_unix_epoch return the number of days since the UNIX epoch 1970-01-01.
//
// To create [`Time`] back, use [`Time.from_days_after_unix_epoch`].
pub fn (t &Time) days_from_unix_epoch() -> i32 {
	return days_from_unix_epoch(t.year, t.month, t.day)
}

// relative returns a human-readable relative time string.
//
// Examples:
// - "now"
// - "2 minutes ago"
// - "2 hours ago"
// - "2 days ago"
// - "2 weeks ago"
// - "2 years ago"
// - "in 2 minutes"
// - "in 2 hours"
// - "in 2 days"
// - "in 2 weeks"
// - "in 2 years"
pub fn (t &Time) relative() -> string {
	now_t := Time.now()
	mut secs := now_t.unix - t.unix

	mut prefix := ''
	mut suffix := ''

	if secs < 0 {
		secs *= -1
		prefix = 'in '
	} else {
		suffix = ' ago'
	}

	if secs < SECONDS_PER_MINUTE / 2 {
		return 'now'
	}

	if secs < SECONDS_PER_HOUR {
		minutes := secs / SECONDS_PER_MINUTE
		if minutes == 0 || minutes == 1 {
			return '${prefix}1 minute${suffix}'
		}

		return '${prefix}${minutes} minutes${suffix}'
	}

	if secs < SECONDS_PER_DAY {
		hours := secs / SECONDS_PER_HOUR
		if hours == 1 {
			return '${prefix}1 hour${suffix}'
		}

		return '${prefix}${hours} hours${suffix}'
	}

	if secs < SECONDS_PER_WEEK {
		days := secs / SECONDS_PER_DAY
		if days == 1 {
			return '${prefix}1 day${suffix}'
		}

		return '${prefix}${days} days${suffix}'
	}

	if secs < SECONDS_PER_YEAR {
		weeks := secs / SECONDS_PER_WEEK
		if weeks == 1 {
			return '${prefix}1 week${suffix}'
		}

		return '${prefix}${weeks} weeks${suffix}'
	}

	years := secs / SECONDS_PER_YEAR
	if years == 1 {
		return '${prefix}1 year${suffix}'
	}

	return '${prefix}${years} years${suffix}'
}

// relative_short returns a human-readable relative time string.
//
// Examples:
// - "now"
// - "in 5m"
// - "in 1d"
// - "2h ago"
// - "5y ago"
pub fn (t &Time) relative_short() -> string {
	now_t := Time.now()
	mut secs := now_t.unix - t.unix

	mut prefix := ''
	mut suffix := ''

	if secs < 0 {
		secs *= -1
		prefix = 'in '
	} else {
		suffix = ' ago'
	}

	if secs < SECONDS_PER_MINUTE / 2 {
		return 'now'
	}

	if secs < SECONDS_PER_HOUR {
		minutes := secs / SECONDS_PER_MINUTE
		if minutes == 0 || minutes == 1 {
			return '${prefix}1m${suffix}'
		}

		return '${prefix}${minutes}m${suffix}'
	}

	if secs < SECONDS_PER_DAY {
		hours := secs / SECONDS_PER_HOUR
		if hours == 1 {
			return '${prefix}1h${suffix}'
		}

		return '${prefix}${hours}h${suffix}'
	}

	if secs < SECONDS_PER_WEEK {
		days := secs / SECONDS_PER_DAY
		if days == 1 {
			return '${prefix}1d${suffix}'
		}

		return '${prefix}${days}d${suffix}'
	}

	if secs < SECONDS_PER_YEAR {
		weeks := secs / SECONDS_PER_WEEK
		if weeks == 1 {
			return '${prefix}1w${suffix}'
		}

		return '${prefix}${weeks}w${suffix}'
	}

	years := secs / SECONDS_PER_YEAR
	if years == 1 {
		return '${prefix}1y${suffix}'
	}

	return '${prefix}${years}y${suffix}'
}

// calculate_date_from_day_offset returns the year, month, and day based on the given day offset.
fn calculate_date_from_day_offset(mut day_offset i64) -> (i32, i32, i32) {
	// source: http://howardhinnant.github.io/date_algorithms.html#civil_from_days

	// shift from 1970-01-01 to 0000-03-01
	day_offset += 719468 // (DAYS_PER_400_YEARS * 1970 / 400 - (28+31)) as i32

	mut era := 0
	if day_offset >= 0 {
		era = (day_offset / DAYS_PER_400_YEARS) as i32
	} else {
		era = ((day_offset - DAYS_PER_400_YEARS - 1) / DAYS_PER_400_YEARS) as i32
	}

	// day_of_era => [0..146096]
	day_of_era := day_offset - era * DAYS_PER_400_YEARS

	// year_of_era => [0..399]
	year_of_era := (day_of_era - day_of_era / (DAYS_PER_4_YEARS - 1) + day_of_era / DAYS_PER_100_YEARS - day_of_era / (DAYS_PER_400_YEARS - 1)) / DAYS_IN_YEAR

	mut year := (year_of_era + era * 400) as i32

	// day_of_year => with year beginning Mar 1 [0..365]
	day_of_year := day_of_era - (DAYS_IN_YEAR * year_of_era + year_of_era / 4 - year_of_era / 100)

	month_position := (5 * day_of_year + 2) / 153
	day := (day_of_year - (153 * month_position + 2) / 5 + 1) as i32
	mut month := month_position

	if month_position < 10 {
		month += 3
	} else {
		month -= 9
	}

	if month <= 2 {
		year += 1
	}

	return year, month, day
}

// calculate_time_from_second_offset returns the hour, minute, and second
// based on the given second offset.
fn calculate_time_from_second_offset(mut second_offset i64) -> (i32, i32, i32) {
	if second_offset < 0 {
		second_offset += SECONDS_PER_DAY
	}
	hour := second_offset / SECONDS_PER_HOUR
	second_offset %= SECONDS_PER_HOUR
	minute := second_offset / SECONDS_PER_MINUTE
	second_offset %= SECONDS_PER_MINUTE
	return hour as i32, minute as i32, second_offset as i32
}

// days_from_unix_epoch returns the number of days since the UNIX epoch 1970-01-01.
//
// See http://howardhinnant.github.io/date_algorithms.html
fn days_from_unix_epoch(year i32, month i32, day i32) -> i32 {
	y := if month <= 2 { year - 1 } else { year }
	era := y / 400
	year_of_the_era := y - era * 400 // [0, 399]
	day_of_year := (153 * (month + (if month > 2 { -3 } else { 9 })) + 2) / 5 + day - 1 // [0, 365]
	day_of_the_era := year_of_the_era * 365 + year_of_the_era / 4 - year_of_the_era / 100 + day_of_year // [0, 146096]
	return era * 146097 + day_of_the_era - 719468
}

extern pub struct tm_t {
	tm_year i32
	tm_mon  i32
	tm_mday i32
	tm_hour i32
	tm_min  i32
	tm_sec  i32
}

fn portable_timegm(t &tm_t) -> i64 {
	mut year := t.tm_year + 1900
	mut month := t.tm_mon // 0-11
	if month > 11 {
		year += month / 12
		month %= 12
	} else if month < 0 {
		years_diff := (11 - month) / 12
		year -= years_diff
		month += 12 * years_diff
	}
	days_since_1970 := days_from_unix_epoch(year, month + 1, t.tm_mday) as i64
	return 60 * (60 * (24 * days_since_1970 + t.tm_hour) + t.tm_min) + t.tm_sec
}

// DAYS_BEFORE at index `m` counts the number of days in a non-leap year
// before month `m` begins. There is an entry for m=12, counting
// the number of days before January of next year (365).
const DAYS_BEFORE = [
	0,
	31,
	31 + 28,
	31 + 28 + 31,
	31 + 28 + 31 + 30,
	31 + 28 + 31 + 30 + 31,
	31 + 28 + 31 + 30 + 31 + 30,
	31 + 28 + 31 + 30 + 31 + 30 + 31,
	31 + 28 + 31 + 30 + 31 + 30 + 31 + 31,
	31 + 28 + 31 + 30 + 31 + 30 + 31 + 31 + 30,
	31 + 28 + 31 + 30 + 31 + 30 + 31 + 31 + 30 + 31,
	31 + 28 + 31 + 30 + 31 + 30 + 31 + 31 + 30 + 31 + 30,
	31 + 28 + 31 + 30 + 31 + 30 + 31 + 31 + 30 + 31 + 30 + 31,
]

fn days_in(m i32, year i32) -> i32 {
	if m == 2 && is_leap(year) {
		return 29
	}
	return DAYS_BEFORE[m] - DAYS_BEFORE[m - 1]
}

fn is_leap(year i32) -> bool {
	return year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)
}

const DAY_OF_WEEK_CONST = [0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4] as [12]i32

// day_of_week returns the current day of week of a given
// year, month, and day, as an integer.
pub fn day_of_week(y i32, m i32, d i32) -> i32 {
	// Sakomotho's algorithm is explained here:
	// https://stackoverflow.com/a/6385934
	mut sy := y
	if m < 3 {
		sy = sy - 1
	}
	return (sy + sy / 4 - sy / 100 + sy / 400 + DAY_OF_WEEK_CONST[m - 1] + d - 1) % 7 + 1
}
