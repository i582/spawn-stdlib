module time

import sys.libc

// as_timespec returns a timespec struct representing the time [`d`]
// seconds in the future.
//
// This function is primarily used for setting timeouts for C
// functions that require a [`libc.timespec`].
pub fn (d Duration) as_timespec() -> libc.timespec {
	mut ts := libc.timespec{}
	libc.clock_gettime(libc.CLOCK_REALTIME, &mut ts)
	d_sec := d / SECOND
	d_nsec := d % SECOND
	ts.tv_sec += d_sec
	ts.tv_nsec += d_nsec
	if ts.tv_nsec > SECOND as i64 {
		ts.tv_nsec -= SECOND as i64
		ts.tv_sec++
	}
	return ts
}
