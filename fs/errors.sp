module fs

import errno

// FsError is an error that occurs when an IO operation fails,
// for example, when a file cannot be opened or read.
pub struct FsError {
	num errno.Errno // error number
	msg string      // description of the error with optional prefix
}

// from_errno creates an `FsError` from the last errno.
#[cold] // almost always this function is called in an error path, hint the compiler to optimize for that
pub fn FsError.from_errno(prefix string) -> FsError {
	num := errno.last()
	return FsError{
		num: num
		msg: prefix + num.desc()
	}
}

pub fn (e FsError) msg() -> string {
	return e.msg
}

#[inline]
pub fn FsError.throw(res bool, context string) -> ! {
	if res {
		return
	}

	return error(FsError.from_errno(context))
}
