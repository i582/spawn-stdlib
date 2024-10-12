module fs

// flush_stdout flushes stdout.
//
// By default, printing to stdout is buffered, this means that the text
// will not be printed until an internal buffer is filled. This function
// flushes the buffer and prints all pending text.
//
// See also: [`flush_stderr`].
pub fn flush_stdout() -> i32 {
	return stdout().flush() or { 0 }
}

// flush_stderr flushes stderr.
//
// By default, printing to stderr is buffered, this means that the text
// will not be printed until an internal buffer is filled. This function
// flushes the buffer and prints all pending text.
//
// See also: [`flush_stdout`].
pub fn flush_stderr() -> i32 {
	return stderr().flush() or { 0 }
}
