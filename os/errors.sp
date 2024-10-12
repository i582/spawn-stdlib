module os

import errno

// IOError is an error that occurs when an IO operation fails,
// for example, when a file cannot be opened or read.
pub struct IOError {
	num errno.Errno // error number
	msg string      // description of the error with optional prefix
}

// from_errno creates an `IOError` from the last errno.
#[cold] // almost always this function is called in an error path, hint the compiler to optimize for that
pub fn IOError.from_errno(prefix string) -> IOError {
	num := errno.last()
	return IOError{
		num: num
		msg: prefix + num.desc()
	}
}

pub fn (e IOError) msg() -> string {
	return e.msg
}

#[inline]
pub fn IOError.throw(res bool, context string) -> ! {
	if res {
		return
	}

	return error(IOError.from_errno(context))
}
