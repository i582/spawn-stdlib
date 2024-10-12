module errno

import sys.libc

#[include("<errno.h>")]

pub fn errno_location() -> &mut i32 {
	return &mut C.errno
}

// reset_errno resets the global platform-specific errno to no-error.
pub fn reset_errno() {
	// SAFETY: errno is a thread-local variable.
	unsafe {
		*errno_location() = 0
	}
}

// errno returns the global platform-specific errno.
pub fn errno() -> i32 {
	return unsafe { *errno_location() }
}

// last returns the last errno that occurred.
pub fn last() -> Errno {
	return from_i32(errno())
}

// describe_errno returns a string describing the given errno.
pub fn describe_errno(num Errno) -> string {
	return string.from_c_str(libc.strerror(num as i32))
}

// desc returns a string describing the given errno.
pub fn (e Errno) desc() -> string {
	return describe_errno(e)
}

// str returns a string describing the given errno.
pub fn (e Errno) str() -> string {
	return '${e as i32}: ${e.desc()}'
}

pub fn from_i32(num i32) -> Errno {
	// TODO: safe cast from i32 to enum
	return num as Errno
}
