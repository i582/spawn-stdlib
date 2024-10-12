module builtin

import sys.libc

// print_backtrace prints the basic backtrace to stderr.
//
// See also `backtrace` module for more advanced stack traces.
pub fn print_backtrace() {
	comptime if musl {
		// TODO: compile warning?
		// musl doesn't have backtrace_symbols_fd
		eprintln('Musl C library does not support `backtrace` and `backtrace_symbols_fd`, native backtrace is not available.')
		return
	}

	mut buffer := [100]*void{}
	nr_ptrs := libc.backtrace(&mut buffer[0], 100)
	if nr_ptrs < 2 {
		return
	}
	libc.backtrace_symbols_fd(&mut buffer[0], nr_ptrs - 1, 2)
}

// get_backtrace returns the basic backtrace as an array of strings.
//
// See also `backtrace` module for more advanced stack traces.
pub fn get_backtrace() -> []string {
	mut buffer := [100]*void{}
	nr_ptrs := libc.backtrace(&mut buffer[0], 100)
	if nr_ptrs < 2 {
		return []
	}
	arr := libc.backtrace_symbols(&mut buffer[0], nr_ptrs - 1)
	if arr == nil {
		return []
	}
	mut res := []string{cap: nr_ptrs}
	for i in 0 .. nr_ptrs - 1 {
		res.push(string.from_c_str(unsafe { arr[i] }))
	}
	return res
}
