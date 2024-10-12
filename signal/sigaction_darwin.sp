module signal

import sys.libc

pub fn SigSet.all() -> SigSet {
	mut set := 0 as libc.sigset_t
	libc.sigfillset(&mut set)
	return SigSet{ sigset: set }
}

pub fn SigSet.empty() -> SigSet {
	return SigSet{ sigset: 0 as libc.sigset_t }
}
