module builtin

// Ordering represents the result of a comparison between two values.
pub enum Ordering {
	// less represents the ordering of a value that is less than another.
	less = -1
	// equal represents the ordering of a value that is equal to another.
	equal = 0
	// greater represents the ordering of a value that is greater than another.
	greater = 1
}

// is_eq returns true if the ordering is equal.
pub fn (o Ordering) is_eq() -> bool {
	return o == .equal
}

// is_ne returns true if the ordering is not equal.
pub fn (o Ordering) is_ne() -> bool {
	return o != .equal
}

// is_lt returns true if the ordering is less than.
pub fn (o Ordering) is_lt() -> bool {
	return o == .less
}

// is_le returns true if the ordering is less than or equal.
pub fn (o Ordering) is_le() -> bool {
	return o != .greater
}

// is_gt returns true if the ordering is greater than.
pub fn (o Ordering) is_gt() -> bool {
	return o == .greater
}

// is_ge returns true if the ordering is greater than or equal.
pub fn (o Ordering) is_ge() -> bool {
	return o != .less
}

// reverse returns the reverse of the ordering.
//
// - less becomes greater
// - equal remains equal
// - greater becomes less
//
// See [`Ordering.reverse_if`] for a version that only reverses the
// ordering if a condition is true.
//
// This method can be used to reverse a sort order:
// ```
// values := [10, 5, 8]
// assert values.sorted_by(|a, b| a.cmp(*b)) == [5, 8, 10]
// assert values.sorted_by(|a, b| a.cmp(*b).reverse()) == [10, 8, 5]
// ```
pub fn (o Ordering) reverse() -> Ordering {
	return match o {
		.less => .greater
		.equal => .equal
		.greater => .less
	}
}

// reverse_if returns the reverse of the ordering if the condition is true,
// otherwise it returns the ordering itself.
//
// - less becomes greater
// - equal remains equal
// - greater becomes less
//
// This method can be used to reverse a sort order conditionally:
// ```
// need_reverse := true
// values := [10, 5, 8]
// assert values.sorted_by(|a, b| a.cmp(*b).reverse_if(need_reverse)) == [10, 8, 5]
// ```
pub fn (o Ordering) reverse_if(cond bool) -> Ordering {
	if cond {
		return o.reverse()
	}
	return o
}
