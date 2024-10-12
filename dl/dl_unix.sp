module dl

// TODO: add safe cast with size check
// TODO: Windows implementation

import mem

#[include("<dlfcn.h>")]

extern {
	fn dlopen(filename *u8, flags i32) -> *void
	fn dlsym(handle *void, symbol *u8) -> *void
	fn dlclose(handle *void) -> i32
	fn dlerror() -> *u8
}

extern pub const (
	// RTLD_LAZY perform lazy binding.
	//
	// Relocations shall be performed at an implementation-defined time, ranging from the time
	// of the `open` call until the first reference to a given symbol occurs.
	// Specifying `RTLD_LAZY` should improve performance on implementations supporting dynamic
	// symbol binding since a process might not reference all of the symbols in an executable
	// object file. And, for systems supporting dynamic symbol resolution for normal process
	// execution, this behaviour mimics the normal handling of process execution.
	//
	// Conflicts with `RTLD_NOW`.
	RTLD_LAZY = 0

	// RTLD_NOW perform eager binding.
	//
	// All necessary relocations shall be performed when the executable object file is first
	// loaded. This may waste some processing if relocations are performed for symbols
	// that are never referenced. This behaviour may be useful for applications that need to
	// know that all symbols referenced during execution will be available before
	// `open` returns.
	//
	// Conflicts with `RTLD_LAZY`.
	RTLD_NOW = 0

	// RTLD_GLOBAL make loaded symbols available for resolution globally.
	//
	// The executable object file's symbols shall be made available for relocation processing of any
	// other executable object file. In addition, calls to `get` on `Library` obtained from
	// `this` allows executable object files loaded with this mode to be searched.
	RTLD_GLOBAL = 0

	// RTLD_LOCAL load symbols into an isolated namespace.
	//
	// The executable object file's symbols shall not be made available for relocation processing of
	// any other executable object file. This mode of operation is most appropriate for e.g. plugins.
	RTLD_LOCAL = 0

	// TODO: document?
	RTLD_NODELETE = 0
	RTLD_NOLOAD   = 0
)

pub type Handle = *mut void

// new opens a shared library image with the given filename.
//
// If the `filename` contains a path separator, the `filename` is interpreted as a `path` to
// a file. Otherwise, platform-specific algorithms are employed to find a library with a
// matching file name.
//
// This is equivalent to `open(filename, RTLD_LAZY | RTLD_LOCAL).
//
// If the library cannot be opened, an `DlError` is returned.
pub fn new(filename string) -> ![Library, DlError] {
	return open(filename, RTLD_LAZY | RTLD_LOCAL)
}

// open opens a shared library image with the given filename and flags.
//
// If the `filename` contains a path separator, the `filename` is interpreted as a `path` to
// a file. Otherwise, platform-specific algorithms are employed to find a library with a
// matching file name.
//
// If the library cannot be opened, an `DlError` is returned.
pub fn open(filename string, flags i32) -> ![Library, DlError] {
	return unsafe { open_impl(filename.data, flags) }
}

#[unsafe]
fn open_impl(filename *u8, flags i32) -> ![Library, DlError] {
	handle := dlopen(filename, flags)
	if handle == nil {
		return error(DlError.from_dlerror("failed to open shared library `${string.from_c_str(filename)}`: "))
	}
	return Library{ handle: handle }
}

// this load the current executable as a shared library image.
pub fn this() -> Library {
	// SAFETY: this does not load any new shared library images, no danger in it executing
	// initialiser routines.
	return unsafe {
		open_impl(nil, RTLD_LAZY | RTLD_LOCAL).expect('this should never fail')
	}
}

// get returns the address of the symbol in the shared library image.
// If the symbol is not found, `none` is returned.
//
// See [`get_as`] for a type-safe version of this method.
//
// Example:
// ```
// lib := dl.new("libexample.so").unwrap()
// fun := lib.get("example_function").unwrap()
// ```
pub fn (l &Library) get(symbol string) -> ?&void {
	if l.closed {
		return none
	}
	sym := dlsym(l.handle, symbol.data)
	if sym == nil {
		return none
	}
	return mem.assume_safe[void](sym)
}

// get_as returns the address of the symbol in the shared library image, cast to the type `F`.
// If the symbol is not found, `none` is returned.
//
// See also [`get`] if you need to work with raw pointers.
//
// Example:
// ```
// lib := dl.new("libexample.so").unwrap()
// fun := lib.get_as[fn () -> void]("example_function").unwrap()
// fun()
// ```
pub fn (l &Library) get_as[F](symbol string) -> ?F {
	sym := l.get(symbol)?
	return unsafe { sym as F }
}

// close closes the shared library image.
//
// After calling this method, `get` will always return `none`.
pub fn (l &mut Library) close() -> bool {
	l.closed = true
	return dlclose(l.handle) == 0
}

// last_error returns the last error that occurred.
pub fn last_error() -> string {
	str := dlerror()
	if str == nil {
		return "unknown error"
	}
	return string.from_c_str(str)
}

// DlError is an error returned by the `dl` module.
// `msg` contains the error message obtained from `dlerror`.
pub struct DlError {
	msg string
}

pub fn DlError.from_dlerror(prefix string) -> DlError {
	return DlError{
		msg: prefix + last_error()
	}
}

pub fn (e DlError) msg() -> string {
	return e.msg
}
