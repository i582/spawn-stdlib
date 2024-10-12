module builtin

import sys.libc
import internal
import backtrace
import intrinsics

pub comptime const (
	// backtrace_mode sets the backtrace mode.
	// - 'none' — no backtrace at all
	// - 'full' — full backtrace, including all frames
	// - 'native' — native backtrace
	//              On Unix it uses `backtrace` function from C standard library,
	//              on Windows it uses `CaptureStackBackTrace` from Windows API.
	backtrace_mode = 'none'
)

extern {
	pub fn setjmp(env i32) -> i32
	pub fn printf(format *u8, args ...any) -> i32
	pub fn fprintf(file *void, format *u8, args ...any) -> i32
}

// panic is a built-in function for raising an error.
// It prints the given message to the standard output, prints a stack trace (if not disabled),
// and exits with code 1.
#[cold]
#[track_caller]
pub fn panic(s string) -> never {
	comptime if panic_strategy == 'abort' {
		panic_abort(s)
	} $else {
		panic_unwind(s)
	}
}

#[track_caller]
fn panic_abort(s string) -> never {
	fprintf(libc.STDERR, c'panic: %s\n', s.c_str())
	intrinsics.abort()
}

#[track_caller]
fn panic_unwind(s string) -> never {
	comptime if panic_strategy == 'unwind' {
		internal.set_panicked(s)
		internal.flushdefers(true)
	}

	// we want to see panic message after all buffered stdout output
	libc.fflush(C.stdout)
	loc := intrinsics.caller_location()
	fprintf(libc.STDERR, c'panic: %s at %s:%d:%d\n', s.c_str(), loc.file, loc.line, loc.col)
	thread_id := internal.get_thread_id()
	thread_name := internal.get_thread_name()

	comptime if panic_strategy == 'unwind' && backtrace_mode != 'none' {
		fprintf(libc.STDERR, c'\nthread "%s" (%u):\n', thread_name.c_str(), thread_id)
		comptime if backtrace_mode == 'native' {
			print_backtrace()
		} $else {
			backtrace.display(skip: 4)
		}
	} $else {
		fprintf(libc.STDERR, c'thread "%s" (%u)\n', thread_name.c_str(), thread_id)
	}

	comptime if panic_strategy == 'unwind' && backtrace_mode == 'none' {
		fprintf(libc.STDERR, c'\nnote: compile with `--backtrace full` or `--backtrace native` to see a stack trace\n')
	}

	libc.exit(1)
}

// recover is a built-in function for catching a panic.
// For now, it can be used as argument for defer.
// Example:
// ```
// fn foo() {
//     panic('foo')
// }
//
// fn main() {
//     defer recover()
//     foo()
//     println('after foo')
// }
// ```
// This will print 'after foo'. Panic will be caught by `defer recover()` and the program
// will continue.
#[no_inline]
pub fn recover() -> ?string {
	internal.recoverimpl()
	return none
}

pub struct Location {
	file &u8
	line u32
	col  u32
}

pub fn Location.new(file &u8, line u32, col u32) -> Location {
	return new_location(file, line, col)
}

#[track_caller]
pub fn Location.caller() -> Location {
	return intrinsics.caller_location()
}

pub fn (l Location) str() -> string {
	return "${string.view_from_c_str(l.file)}:${l.line}:${l.col}"
}

fn new_location(file &u8, line u32, col u32) -> Location {
	return Location{ file: file, line: line, col: col }
}
