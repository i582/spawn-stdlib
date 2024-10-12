module builtin

// Set is a set data structure. A set is a collection of unique elements.
// The elements are stored in a hash table, so the time complexity of
// operations is O(1) on average.
//
// Order is not guaranteed when iterating over the elements.
pub struct Set[T: MapKey] {
	m Map[T, unit]
}

// new creates a new empty set.
pub fn Set.new[T: MapKey]() -> Set[T] {
	return Set[T]{ m: new_map() }
}

// equal returns true if the two sets are equal.
//
// Two sets are equal if they have the same elements.
pub fn (s &mut Set[T]) equal(other &Set[T]) -> bool
	where T: Equality
{
	return s.m.equal(&other.m)
}

// clone returns a new set with the same elements where
// each element is cloned.
pub fn (s &mut Set[T]) clone() -> &mut Set[T]
	where T: Clone
{
	return &mut Set[T]{ m: s.m.clone() }
}

// insert adds an element to the set.
//
// If the element is already in the set, it will be
// overwritten (effectively doing nothing).
pub fn (s &mut Set[T]) insert(x T) {
	s.m.insert(x, ())
}

// contains returns true if the set contains the element.
//
// Example:
// ```
// mut s := Set.new[i32]()
// s.insert(1)
// s.insert(2)
// assert s.contains(1)
// assert !s.contains(3)
// ```
pub fn (s &Set[T]) contains(x T) -> bool {
	return s.m.contains(x)
}

// remove removes an element from the set.
//
// If the element is not in the set, it will do nothing.
pub fn (s &mut Set[T]) remove(x T) {
	s.m.remove(x)
}

// union_with returns a new set that is the union of the two sets.
// The union of two sets is the set of elements that are in either set.
// This operation is also known as the "or" operation.
//
// Example:
// ```
// mut s1 := Set.new[i32]()
// s1.insert(1)
// s1.insert(2)
// mut s2 := Set.new[i32]()
// s2.insert(2)
// s2.insert(3)
// mut s3 := s1.union_with(&s2)
// assert s3.contains(1)
// assert s3.contains(2)
// assert s3.contains(3)
// ```
pub fn (s &Set[T]) union_with(other &Set[T]) -> Set[T] {
	mut ns := Set.new[T]()
	for x in s.m.keys_iter() {
		ns.insert(x)
	}
	for x in other.m.keys_iter() {
		ns.insert(x)
	}
	return ns
}

// intersection returns a new set that is the intersection of the two sets.
// The intersection of two sets is the set of elements that are in both sets.
// This operation is also known as the "and" operation.
//
// Example:
// ```
// mut s1 := Set.new[i32]()
// s1.insert(1)
// s1.insert(2)
// mut s2 := Set.new[i32]()
// s2.insert(2)
// s2.insert(3)
// mut s3 := s1.intersection(&s2)
// assert !s3.contains(1)
// assert s3.contains(2)
// assert !s3.contains(3)
// ```
pub fn (s &Set[T]) intersection(other &Set[T]) -> Set[T] {
	mut ns := Set.new[T]()
	for x in s.m.keys_iter() {
		if other.contains(x) {
			ns.insert(x)
		}
	}
	return ns
}

// difference returns a new set that is the difference of the two sets.
// The difference of two sets is the set of elements that are in the first set
// but not in the second set.
//
// Example:
// ```
// mut s1 := Set.new[i32]()
// s1.insert(1)
// s1.insert(2)
// mut s2 := Set.new[i32]()
// s2.insert(2)
// s2.insert(3)
// mut s3 := s1.difference(&s2)
// assert s3.contains(1)
// assert !s3.contains(2)
// assert !s3.contains(3)
// ```
pub fn (s &Set[T]) difference(other &Set[T]) -> Set[T] {
	mut ns := Set.new[T]()
	for x in s.m.keys_iter() {
		if !other.contains(x) {
			ns.insert(x)
		}
	}
	return ns
}

// is_subset returns true if the set is a subset of the other set.
// A set is a subset of another set if all elements in the first set are
// also in the second set.
// The empty set is a subset of all sets.
// A set is not a subset of itself.
//
// Example:
// ```
// mut s1 := Set.new[i32]()
// s1.insert(1)
// s1.insert(2)
// mut s2 := Set.new[i32]()
// s2.insert(1)
// s2.insert(2)
// s2.insert(3)
// assert s1.is_subset(&s2)
// assert !s2.is_subset(&s1)
// ```
pub fn (s &Set[T]) is_subset(other &Set[T]) -> bool {
	for x in s.m.keys_iter() {
		if !other.contains(x) {
			return false
		}
	}
	return true
}

// is_superset returns true if the set is a superset of the other set.
// A set is a superset of another set if all elements in the second set are
// also in the first set.
// The empty set is a superset of all sets.
// A set is not a superset of itself.
// This operation is the inverse of is_subset.
// This operation is also known as the "contains" operation.
//
// Example:
// ```
// mut s1 := Set.new[i32]()
// s1.insert(1)
// s1.insert(2)
// mut s2 := Set.new[i32]()
// s2.insert(1)
// s2.insert(2)
// s2.insert(3)
// assert s2.is_superset(&s1)
// assert !s1.is_superset(&s2)
// ```
pub fn (s &Set[T]) is_superset(other &Set[T]) -> bool {
	return other.is_subset(s)
}

// is_disjoint returns true if the set is disjoint from the other set.
// Two sets are disjoint if they have no elements in common.
// The empty set is disjoint from all sets.
//
// Example:
// ```
// mut s1 := Set.new[i32]()
// s1.insert(1)
// s1.insert(2)
// mut s2 := Set.new[i32]()
// s2.insert(3)
// s2.insert(4)
// assert s1.is_disjoint(&s2)
// ```
pub fn (s &Set[T]) is_disjoint(other &Set[T]) -> bool {
	for x in s.m.keys_iter() {
		if other.contains(x) {
			return false
		}
	}
	return true
}

// is_proper_subset returns true if the set is a proper subset of the other set.
// A set is a proper subset of another set if all elements in the first set are
// also in the second set and the two sets are not equal.
// The empty set is a proper subset of all sets.
// A set is not a proper subset of itself.
//
// Example:
// ```
// mut s1 := Set.new[i32]()
// s1.insert(1)
// s1.insert(2)
// mut s2 := Set.new[i32]()
// s2.insert(1)
// s2.insert(2)
// s2.insert(3)
// assert s1.is_proper_subset(&s2)
// assert !s2.is_proper_subset(&s1)
// ```
pub fn (s &Set[T]) is_proper_subset(other &Set[T]) -> bool {
	return s.is_subset(other) && !s.is_superset(other)
}

// is_proper_superset returns true if the set is a proper superset of the other set.
// A set is a proper superset of another set if all elements in the second set are
// also in the first set and the two sets are not equal.
// The empty set is a proper superset of all sets.
// A set is not a proper superset of itself.
//
// Example:
// ```
// mut s1 := Set.new[i32]()
// s1.insert(1)
// s1.insert(2)
// mut s2 := Set.new[i32]()
// s2.insert(1)
// s2.insert(2)
// s2.insert(3)
// assert s2.is_proper_superset(&s1)
// assert !s1.is_proper_superset(&s2)
// ```
pub fn (s &Set[T]) is_proper_superset(other &Set[T]) -> bool {
	return s.is_superset(other) && !s.is_subset(other)
}

// is_empty returns true if the set is empty.
// The empty set has no elements.
pub fn (s &Set[T]) is_empty() -> bool {
	return s.m.is_empty()
}

// iter returns an iterator over the elements in the set.
// The iterator does not guarantee any order.
pub fn (s &Set[T]) iter() -> KeysIterator[T, unit] {
	return s.m.keys_iter()
}

// clear removes all elements from the set.
pub fn (s &mut Set[T]) clear() {
	s.m.clear()
}
