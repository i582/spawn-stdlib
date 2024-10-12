module time

import sys.libc

#[skip_profile]
pub fn instant_now() -> Instant {
	clock_id := libc.CLOCK_MONOTONIC
	return Instant{ t: Timespec.new(clock_id) }
}
