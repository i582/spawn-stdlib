module time

import sys.libc

pub const UNIX_EPOCH = system_unix_epoch()

type ClockId = u32

pub struct Timespec {
	sec     i64
	nanosec i64
}

#[skip_profile]
pub fn Timespec.new(clock ClockId) -> Timespec {
	mut ts := libc.timespec{}
	libc.clock_gettime(clock, &mut ts)
	return Timespec{ sec: ts.tv_sec, nanosec: ts.tv_nsec }
}

pub fn Timespec.zero() -> Timespec {
	return Timespec{ sec: 0, nanosec: 0 }
}

pub fn (t Timespec) duration_since(earlier Timespec) -> Duration {
	mut sec_diff := t.sec - earlier.sec
	mut nsec_diff := t.nanosec - earlier.nanosec
	if nsec_diff < 0 {
		nsec_diff = nsec_diff + SECOND
		sec_diff--
	}

	sec_diff_in_ns := sec_diff.checked_mul(SECOND) or {
		panic('duration_since: `sec_diff * SECOND` overflows a i64 (${sec_diff} * ${SECOND})')
	}

	dur := sec_diff_in_ns + nsec_diff
	return dur as Duration
}

#[skip_profile]
pub fn (t Timespec) unix_nanos() -> u64 {
	return t.sec * SECOND + t.nanosec
}

pub fn (t Timespec) debug_str() -> string {
	return 'Timespec: ${t.sec}.${t.nanosec}'
}

struct Instant {
	t Timespec
}

pub fn (i Instant) duration_since(earlier Instant) -> Duration {
	return i.t.duration_since(earlier.t)
}

pub fn (i Instant) elapsed() -> Duration {
	return instant_now().duration_since(i)
}

#[skip_profile]
pub fn (i Instant) unix_nanos() -> u64 {
	return i.t.unix_nanos()
}

pub fn (i Instant) equal(other Instant) -> bool {
	return i.t.sec == other.t.sec && i.t.nanosec == other.t.nanosec
}

pub fn (i Instant) less(other Instant) -> bool {
	return i.t.sec < other.t.sec || (i.t.sec == other.t.sec && i.t.nanosec < other.t.nanosec)
}

pub fn (i Instant) debug_str() -> string {
	return 'Instant: ${i.t.sec}.${i.t.nanosec}'
}

pub struct SystemTime {
	t Timespec
}

pub fn system_now() -> SystemTime {
	clock_id := libc.CLOCK_REALTIME
	return SystemTime{ t: Timespec.new(clock_id) }
}

pub fn system_unix_epoch() -> SystemTime {
	return SystemTime{ t: Timespec.zero() }
}

pub fn (s SystemTime) duration_since(earlier SystemTime) -> Duration {
	return s.t.duration_since(earlier.t)
}

pub fn (s SystemTime) elapsed() -> Duration {
	return system_now().duration_since(s)
}

pub fn (s SystemTime) unix_nanos() -> u64 {
	return s.t.unix_nanos()
}

pub fn (s SystemTime) equal(other SystemTime) -> bool {
	return s.t.sec == other.t.sec && s.t.nanosec == other.t.nanosec
}

pub fn (s SystemTime) less(other SystemTime) -> bool {
	return s.t.sec < other.t.sec || (s.t.sec == other.t.sec && s.t.nanosec < other.t.nanosec)
}

pub fn (s SystemTime) debug_str() -> string {
	return 'System: ${s.t.sec}.${s.t.nanosec}'
}

pub fn Time.now() -> Time {
	now_time := system_now()
	return Time.from_nanos(now_time.t.sec, now_time.t.nanosec).local()
}

pub fn Time.utc() -> Time {
	mut ts := libc.timespec{}
	libc.clock_gettime(libc.CLOCK_REALTIME, &mut ts)
	return Time.from_nanos(ts.tv_sec, ts.tv_nsec)
}

pub fn (t Time) local() -> Time {
	if t.is_local {
		return t
	}

	mut loc_tm := libc.tm_t{}
	libc.localtime_r((&t.unix) as *libc.time_t, &mut loc_tm)
	return Time{
		year: loc_tm.tm_year + 1900
		month: loc_tm.tm_mon + 1
		day: loc_tm.tm_mday
		hour: loc_tm.tm_hour
		minute: loc_tm.tm_min
		second: loc_tm.tm_sec
		nanosecond: t.nanosecond
		unix: portable_timegm(unsafe { (&loc_tm) as &tm_t })
		is_local: true
	}
}
