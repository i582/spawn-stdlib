module backtrace

import pathlib
import os

// RawFrame represents an unresolved frame of stack trace.
//
// See [`resolve_frame`] to resolve a frame to [`ResolvedFrame`].
pub struct RawFrame {
	pc usize
}

// pc returns Program Counter of frame.
pub fn (r RawFrame) pc() -> usize {
	return r.pc
}

// ResolvedFrame represents a resolved frame of stack trace.
pub struct ResolvedFrame {
	// pc is the program counter for this frame.
	pc *void
	// filename is the absolute or relative path to the file that contains the
	// code for this frame.
	filename string
	// line is the line number of source code of this frame.
	line i32
	// func is the name of the function for this frame.
	func string
}

// relative_path returns the path to the frame relative to the current
// working directory.
//
// Example:
// ```
// bt := backtrace.capture().unwrap()
// println(bt.frames.first().relative_path())
// ```
pub fn (f ResolvedFrame) relative_path() -> string {
	return pathlib.relative(os.get_wd(), f.filename)
}

// relative_path_to returns the path to the frame relative to the
// passed [`base`].
//
// Example:
// ```
// bt := backtrace.capture().unwrap()
// println(bt.frames.first().relative_path_to('${$SPAWN_ROOT}/y'))
// ```
pub fn (f ResolvedFrame) relative_path_to(base string) -> string {
	return pathlib.relative(base, f.filename)
}

// demangled_name returns demangled Spawn function name.
//
// Example:
// ```
// bt := backtrace.capture().unwrap()
// println(bt.frames.first().demangled_name())
// ```
pub fn (f ResolvedFrame) demangled_name() -> string {
	return demangle(f.func)
}
