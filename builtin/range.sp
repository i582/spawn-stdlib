module builtin

// RangeBound represent a type that can be used as [`Range`].
//
// This type is a way of encoding that [`Range`] has no beginning or end.
pub interface RangeBound {
	Ordered
	Equality
	// is_set returns true if the value is considered valid
	fn is_set(&self) -> bool
	// unset creates a new value that is considered invalid
	fn unset() -> any
}

pub struct Range[Idx: RangeBound] {
	// start is the lower bound of the range (inclusive)
	start Idx

	// end is the upper bound of the range (exclusive or inclusive)
	end Idx

	// inclusive is true when end is inclusive
	inclusive bool
}

// exclusive creates new exclusive [`Range`] from [`start`] to [`end`].
//
// Same as `start..end`.
pub fn Range.exclusive[Idx: RangeBound](start Idx, end Idx) -> Range[Idx] {
	return Range{ start: start, end: end }
}

// inclusive creates new inclusive [`Range`] from [`start`] to [`end`].
//
// Same as `start..=end`.
pub fn Range.inclusive[Idx: RangeBound](start Idx, end Idx) -> Range[Idx] {
	return Range{ start: start, end: end, inclusive: true }
}

// from creates new exclusive [`Range`] from [`start`].
//
// Same as `start..`.
pub fn Range.from[Idx: RangeBound](start Idx) -> Range[Idx] {
	return Range{ start: start, end: Idx.unset() }
}

// to creates new exclusive [`Range`] to [`end`].
//
// Same as `..end`.
pub fn Range.to[Idx: RangeBound](end Idx) -> Range[Idx] {
	return Range{ start: Idx.unset(), end: end }
}

// to_inclusive creates new inclusive [`Range`] to [`end`].
//
// Same as `..=end`.
pub fn Range.to_inclusive[Idx: RangeBound](end Idx) -> Range[Idx] {
	return Range{ start: Idx.unset(), end: end, inclusive: true }
}

// str returns string representation of [`Range`]
pub fn (r Range[Idx]) str() -> string {
	start := r.start_bound()?.str() or { '' }
	end := r.end_bound()?.str() or { '' }
	if r.inclusive {
		return '${start}..=${end}'
	}
	return '${start}..${end}'
}

// start_bound returns the starting value of this range or not if the range
// was created without a beginning
pub fn (r Range[Idx]) start_bound() -> ?Idx {
	if !r.start.is_set() {
		return none
	}
	return r.start
}

// end_bound returns the ending value of this range or none if the range
// was created without end
pub fn (r Range[Idx]) end_bound() -> ?Idx {
	if !r.end.is_set() {
		return none
	}
	return r.end
}

// is_empty returns true if the range contains no items
//
// Example:
// ```
// assert (3..6).is_empty() == false
// assert (3..3).is_empty() == true
// assert (5..3).is_empty() == true
// ```
pub fn (r Range[Idx]) is_empty(value Idx) -> bool {
	return !(r.start < r.end)
}

// contains returns true if [`value`] is contained in the range
pub fn (r Range[Idx]) contains(value Idx) -> bool {
	return value <= r.start && value < r.end
}
