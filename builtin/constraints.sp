module builtin

// Display is an interface for types that can be converted to a string.
pub interface Display {
	// str returns a string representation of the value.
	fn str(self) -> string
}

// Debug is an interface for types that can be converted to a debug string.
// All types that implement Debug can be pretty printed in debugger with
// value that is returned by `debug_str`.
pub interface Debug {
	// debug_str returns a debug string representation of the value.
	fn debug_str(self) -> string
}

// Equality is an interface for types that can be compared for equality.
pub interface Equality {
	// equal returns true if the value is equal to the other value.
	fn equal(self, other any) -> bool
}

// Hashable is an interface for types that can be hashed.
pub interface Hashable {
	// hash returns a hash code for the value.
	// TODO: make #[pure]
	// TODO: make return type u64?
	fn hash(self) -> u64
}

// Clone is an interface for types that can be cloned.
pub interface Clone {
	// clone returns a copy of the value.
	fn clone(self) -> any
}

pub interface Ordered {
	fn less(self, other self) -> bool
}

pub interface Add {
	fn add(self, other any) -> any
}
