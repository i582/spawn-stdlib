module time

import sys.libc

#[include("<time.h>")]

pub fn gm_time(t &libc.time_t) -> &libc.tm_t {
	mut tm := libc.tm_t{}
	libc.gmtime_r(t, &mut tm)
	return &tm
}
