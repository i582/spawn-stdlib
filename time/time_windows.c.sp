module time

import sys.libc
import mem

#[include("<time.h>")]

pub fn gm_time(t &libc.time_t) -> &libc.tm_t {
	// gmtime_r is not defined on Windows, so you gmtime instead
	res := libc.gmtime(t)
	return mem.assume_safe(res)
}
