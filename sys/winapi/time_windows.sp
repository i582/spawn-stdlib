module winapi

#[include("<time.h>")]

extern {
	pub struct FILETIME {
		dwLowDateTime  u32
		dwHighDateTime u32
	}

	pub struct SYSTEMTIME {
		wYear         u16
		wMonth        u16
		wDayOfWeek    u16
		wDay          u16
		wHour         u16
		wMinute       u16
		wSecond       u16
		wMilliseconds u16
	}

	pub struct TIME_ZONE_INFORMATION {
		Bias         i32
		StandardName [32]u16
		StandardDate SYSTEMTIME
		StandardBias i32
		DaylightName [32]u16
		DaylightDate SYSTEMTIME
		DaylightBias i32
	}

	pub fn GetSystemTimeAsFileTime(time *mut FILETIME)
	pub fn FileTimeToSystemTime(lpFileTime *FILETIME, lpSystemTime *mut SYSTEMTIME)
	pub fn QueryPerformanceCounter(count *mut u64) -> bool
	pub fn QueryPerformanceFrequency(freq *mut u64) -> bool
	pub fn GetSystemTimePreciseAsFileTime(time *mut FILETIME)
	pub fn SystemTimeToTzSpecificLocalTime(lpTimeZoneInformation *TIME_ZONE_INFORMATION, lpUniversalTime *SYSTEMTIME, lpLocalTime *mut SYSTEMTIME)

	pub fn Sleep(dwMilliseconds u32)

	pub type time_t = i64

	pub struct tm_t {
		tm_year i32
		tm_mon  i32
		tm_mday i32
		tm_hour i32
		tm_min  i32
		tm_sec  i32
	}

	#[typedef]
	pub struct timespec {
		tv_sec  i64
		tv_nsec i64
	}

	pub fn localtime_s(t *time_t, tm *tm_t)
	pub fn timespec_get(t *timespec, base i32) -> i32
}
