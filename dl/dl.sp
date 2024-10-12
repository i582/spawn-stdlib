module dl

// Library represents a shared library image.
pub struct Library {
	handle Handle
	closed bool
}

// raw returns the raw handle of the shared library image.
//
// This should be used when you need to pass the handle to a C function.
pub fn (l &Library) raw() -> Handle {
	return l.handle
}

// str returns a string representation of the library.
pub fn (l &Library) str() -> string {
	return 'Library@' + (l.handle as usize).hex_prefixed()
}
