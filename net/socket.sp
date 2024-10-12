module net

import time
import mem
import sys.libc

pub struct Socket {
	handle i32
}

pub fn (s Socket) set_read_timeout(timeout time.Duration) -> ! {
	secs := timeout.as_secs()
	timeval := libc.timeval{ tv_sec: secs, tv_usec: (timeout.as_micros() - secs * time.MILLISECOND) as i32 }
	socket_error(libc.setsockopt(s.handle, libc.SOL_SOCKET, libc.SO_RCVTIMEO, &timeval, mem.size_of[libc.timeval]() as u32))!
}

pub fn (s Socket) set_write_timeout(timeout time.Duration) -> ! {
	secs := timeout.as_secs()
	timeval := libc.timeval{ tv_sec: secs, tv_usec: (timeout.as_micros() - secs * time.MILLISECOND) as i32 }
	socket_error(libc.setsockopt(s.handle, libc.SOL_SOCKET, libc.SO_SNDTIMEO, &timeval, mem.size_of[libc.timeval]() as u32))!
}

// set_blocking will change the state of the socket to either blocking,
// when state is true, or non blocking (false).
pub fn set_blocking(handle i32, state bool) -> ! {
	comptime if windows {
		t := if state { 0 as u32 } else { 1 as u32 }
		socket_error(libc.ioctlsocket(handle, libc.FIONBIO, &t))!
	} $else {
		mut flags := libc.fcntl(handle, libc.F_GETFL, nil)
		if state {
			flags &= ~libc.O_NONBLOCK
		} else {
			flags |= libc.O_NONBLOCK
		}
		socket_error(libc.fcntl(handle, libc.F_SETFL, flags))!
	}
}

pub fn set_reuse(handle i32) -> ! {
	mut optval := 1 as i32
	socket_error(libc.setsockopt(handle, libc.SOL_SOCKET, libc.SO_REUSEADDR, &optval, 4))!
}
