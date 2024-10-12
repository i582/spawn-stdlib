module time

import sys.winapi

#[include('<time.h>')]

pub const UNIX_EPOCH = system_unix_epoch()

const (
	NANOS_PER_SEC           = 1_000_000_000
	INTERVALS_PER_SEC       = 1_000_000_000 / 100
	INTERVALS_TO_UNIX_EPOCH = 11_644_473_600 as u64 * INTERVALS_PER_SEC
)

const (
	START_TIME = query()
	FREQUENCY  = freq()
)

pub fn freq() -> u64 {
	mut f := 0 as u64
	winapi.QueryPerformanceFrequency(&mut f)
	return f
}

pub fn query() -> u64 {
	mut count := 0 as u64
	winapi.QueryPerformanceCounter(&mut count)
	return count
}

pub fn time_epsilon() -> Duration {
	return SECOND / FREQUENCY
}

struct Instant {
	// t is duration that relative to an arbitrary microsecond epoch
	// from the WinAPI `QueryPerformanceCounter` function.
	t Duration
}

pub fn instant_now() -> Instant {
	now := query()
	instant_nanos := mul_div_u64(now, NANOS_PER_SEC, FREQUENCY)
	return Instant{ t: instant_nanos }
}

pub fn (i Instant) duration_since(earlier Instant) -> Duration {
	return i.t - earlier.t
}

pub fn (i Instant) elapsed() -> Duration {
	return instant_now().duration_since(i)
}

pub fn (i Instant) unix_nanos() -> u64 {
	return i.t as u64
}

pub fn (i Instant) equal(other Instant) -> bool {
	return i.t == other.t
}

pub fn (i Instant) less(other Instant) -> bool {
	return i.t < other.t
}

pub fn (i Instant) debug_str() -> string {
	return 'Instant: ${i.t}'
}

pub struct SystemTime {
	t winapi.FILETIME
}

pub fn system_now() -> SystemTime {
	mut s := SystemTime{}
	winapi.GetSystemTimePreciseAsFileTime(&mut s.t)
	return s
}

pub fn system_unix_epoch() -> SystemTime {
	return system_from_intervals(INTERVALS_TO_UNIX_EPOCH)
}

pub fn (s SystemTime) intervals() -> i64 {
	return s.t.dwHighDateTime as i64 << 32 | s.t.dwLowDateTime as i64
}

pub fn (s SystemTime) duration_since(earlier SystemTime) -> Duration {
	return intervals_to_duration(s.intervals() - earlier.intervals())
}

pub fn (s SystemTime) elapsed() -> Duration {
	return system_now().duration_since(s)
}

pub fn (s SystemTime) unix_nanos() -> u64 {
	return s.intervals() as u64 * 100 as u64
}

pub fn (s SystemTime) equal(other SystemTime) -> bool {
	return s.intervals() == other.intervals()
}

pub fn (s SystemTime) less(other SystemTime) -> bool {
	return s.intervals() < other.intervals()
}

pub fn (s SystemTime) debug_str() -> string {
	return 'System: ${s.intervals()}'
}

fn system_from_intervals(intervals i64) -> SystemTime {
	return SystemTime{
		t: winapi.FILETIME{
			dwLowDateTime: intervals as u32
			dwHighDateTime: (intervals >> 32) as u32
		}
	}
}

fn intervals_to_duration(intervals i64) -> Duration {
	return (intervals as u64 * 100) as Duration
}

// Computes `(value * numer) / denom` without overflow, as long as both
// `(numer * denom)` and the overall result fit into i64 (which is the case
// for our time conversions).
//
// Thanks Rust for the algorithm!
fn mul_div_u64(value u64, numer u64, denom u64) -> u64 {
	q := value / denom
	r := value % denom
	// Decompose value as (value/denom*denom + value%denom),
	// substitute into (value*numer)/denom and simplify.
	// r < denom, so (denom*numer) is the upper bound of (r*numer)
	return q * numer + r * numer / denom
}

pub fn Time.now() -> Time {
	mut ft_utc := winapi.FILETIME{}
	winapi.GetSystemTimeAsFileTime(&mut ft_utc)
	mut st_utc := winapi.SYSTEMTIME{}
	winapi.FileTimeToSystemTime(&ft_utc, &mut st_utc)
	mut st_local := winapi.SYSTEMTIME{}
	winapi.SystemTimeToTzSpecificLocalTime(nil, &st_utc, &mut st_local)
	return Time{
		year: st_local.wYear
		month: st_local.wMonth
		day: st_local.wDay
		hour: st_local.wHour
		minute: st_local.wMinute
		second: st_local.wSecond
		nanosecond: st_local.wMilliseconds as i64 * 1_000_000
		unix: unix_time_from_system_time(st_local)
		is_local: true
	}
}

pub fn Time.utc() -> Time {
	mut ft_utc := winapi.FILETIME{}
	winapi.GetSystemTimeAsFileTime(&mut ft_utc)
	mut st_utc := winapi.SYSTEMTIME{}
	winapi.FileTimeToSystemTime(&ft_utc, &mut st_utc)
	return Time{
		year: st_utc.wYear
		month: st_utc.wMonth
		day: st_utc.wDay
		hour: st_utc.wHour
		minute: st_utc.wMinute
		second: st_utc.wSecond
		nanosecond: st_utc.wMilliseconds as i64 * 1_000_000
		unix: unix_time_from_system_time(st_utc)
	}
}

pub fn (t Time) local() -> Time {
	if t.is_local {
		return t
	}

	st_utc := winapi.SYSTEMTIME{
		wYear: t.year as u16
		wMonth: t.month as u16
		wDay: t.day as u16
		wHour: t.hour as u16
		wMinute: t.minute as u16
		wSecond: t.second as u16
		wMilliseconds: (t.nanosecond / 1_000_000) as u16
	}
	mut st_local := winapi.SYSTEMTIME{}
	winapi.SystemTimeToTzSpecificLocalTime(nil, &st_utc, &mut st_local)
	return Time{
		year: st_local.wYear
		month: st_local.wMonth
		day: st_local.wDay
		hour: st_local.wHour
		minute: st_local.wMinute
		second: st_local.wSecond
		nanosecond: st_local.wMilliseconds as i64 * 1_000_000
		unix: unix_time_from_system_time(st_local)
		is_local: true
	}
}

fn unix_time_from_system_time(st winapi.SYSTEMTIME) -> i64 {
	tm := winapi.tm_t{
		tm_sec: st.wSecond
		tm_min: st.wMinute
		tm_hour: st.wHour
		tm_mday: st.wDay
		tm_mon: st.wMonth - 1
		tm_year: st.wYear - 1900
	}
	return portable_timegm(unsafe { (&tm) as &tm_t })
}
