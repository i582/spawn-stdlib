module time

import errno
import sys.libc

// sleep pauses the execution of the calling thread for a given duration (in nanoseconds).
//
// The thread may sleep longer than the duration specified due to scheduling specifics or
// platform-dependent functionality, but it will not sleep less.
//
// Example:
// ```
// time.sleep(1 * time.SECOND)
// time.sleep(100 * time.MILLISECOND)
// ```
//
// A negative duration will cause panic.
pub fn sleep(dur Duration) {
	if dur < 0 {
		panic('duration less than zero')
	}

	mut req := libc.timespec{ tv_sec: (dur / SECOND) as i64, tv_nsec: (dur % SECOND) as i64 }
	mut rem := libc.timespec{}
	for libc.nanosleep(&mut req, &mut rem) < 0 {
		if errno.last() == .EINTR {
			// Interrupted by a signal handler
			req = rem
		} else {
			break
		}
	}
}
