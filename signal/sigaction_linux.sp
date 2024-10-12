module signal

import sys.libc

pub fn SigSet.all() -> SigSet {
	mut set := libc.sigset_t{}
	libc.sigfillset(&mut set)
	return SigSet{ sigset: set }
}

pub fn SigSet.empty() -> SigSet {
	mut set := libc.sigset_t{}
	libc.sigemptyset(&mut set)
	return SigSet{ sigset: set }
}
