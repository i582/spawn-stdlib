module libc

#[include("<time.h>")]
#[include("<sys/time.h>")]

extern {
	pub const (
		CLOCK_REALTIME  = 0 as u32
		CLOCK_MONOTONIC = 0 as u32
	)

	#[typedef]
	pub struct timespec {
		tv_sec  i64
		tv_nsec i64
	}

	pub fn mach_absolute_time() -> u64
	pub fn clock_gettime(clock_id u32, tp *mut timespec)

	pub struct tm_t {
		tm_sec    i32
		tm_min    i32
		tm_hour   i32
		tm_mday   i32
		tm_mon    i32
		tm_year   i32
		tm_wday   i32
		tm_yday   i32
		tm_isdst  i32
		tm_gmtoff i32
	}

	pub type time_t = i64

	pub fn timegm(tm *tm_t) -> time_t
	pub fn gmtime_r(t *time_t, res *mut tm_t) -> *tm_t
	pub fn gmtime(t *time_t) -> *tm_t
	pub fn localtime_r(t *time_t, tm *mut tm_t)
	pub fn strftime(buf *mut u8, maxsize usize, const_format *u8, const_tm *tm_t) -> usize

	pub var (
		tzname = [2]*u8{}
	)

	pub fn tzset()

	pub fn nanosleep(req *mut timespec, rem *mut timespec) -> i32

	pub const (
		ITIMER_REAL    = 0
		ITIMER_VIRTUAL = 0
		ITIMER_PROF    = 0
	)

	#[typedef]
	pub struct itimerval {
		it_interval timeval
		it_value    timeval
	}

	#[typedef]
	pub struct timeval {
		tv_sec  i64
		tv_usec i32
	}

	pub fn setitimer(which i32, new_value *mut itimerval, old_value *itimerval) -> i32
}
