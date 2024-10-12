module builtin

import intrinsics

// as_cast tries to cast a value of some interface type to a concrete type.
// If the cast fails, it panics.
//
// ```
// foo := Foo{} as IFoo
// bar := foo as Bar // panics, foo contains a Foo, not a Bar
// ```
//
// Code above translates to:
//
// ```
// foo := as_cast(foo._Foo, foo.id, 2, "foo", "Bar", IFoo_as_mapping)
// ```
// Where first argument is the pointer to the interface inner value, second
// argument is concrete type ID inside the interface, third argument is
// expected type ID and last three arguments are used for panic message.
#[track_caller]
fn as_cast[T](val &T, actual i32, expected i32, interface_name string, expected_type string, names []string) -> &T {
	if intrinsics.likely(expected == actual) {
		return val
	}

	as_cast_fail(actual, interface_name, expected_type, names)
}

// as_cast_fail is a helper function for `as_cast` to panic with a nice message.
// We mark it as cold, so compiler can optimize it out of the hot path. We also
// mark it as no_inline, since call to this function is very unlikely, we want
// assemlly to be as small as possible on the hot path.
#[cold]
#[no_inline]
#[track_caller]
fn as_cast_fail(actual i32, interface_name string, expected_type string, names []string) -> never {
	actual_name := names.get(actual - 1) or { 'unknown' }
	panic('as cast failed, concrete type in `${interface_name}` is a `${actual_name}`, but expected a `${expected_type}`')
}

// safe_as_cast tries to cast a value of some interface type to a concrete type.
// Unlike `as_cast`, it does not panic if the cast fails, but returns none.
//
// ```
// foo := Foo{} as IFoo
// bar := foo as? Bar // bar is none, foo contains a Foo, not a Bar
// if bar == none {
//   // cast failed
// }
// ```
//
// For more information see `as_cast` documentation.
fn safe_as_cast[T](val &T, actual i32, expected i32) -> ?&T {
	if intrinsics.likely(expected == actual) {
		return val
	}
	return none
}

// safe_as_union_cast tries to cast a value of some union type to a concrete type.
// Unlike `as_cast`, it does not panic if the cast fails, but returns none.
//
// ```
// foo := Foo{} as FooOrBar
// bar := foo as? Bar // bar is none, foo contains a Foo, not a Bar
// if bar == none {
//   // cast failed
// }
// ```
//
// For more information see `as_cast` documentation.
fn safe_as_union_cast[T](val T, actual i32, expected i32) -> ?T {
	if intrinsics.likely(expected == actual) {
		return val
	}
	return none
}
