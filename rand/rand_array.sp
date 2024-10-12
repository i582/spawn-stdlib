module rand

// element returns a random element from the given array, or error
// if the array is empty.
//
// Note that all the positions in the array have an equal chance of being selected.
// This means that if the array has repeating elements,
//
// Example:
// ```
// array := [1, 2, 3]
// random_element := rand.element(array)
// assert random_element in [1, 2, 3]
// ```
//
// ```
// empty_array := []i32{}
// err := rand.element(empty_array).unwrap_err()
// assert err.msg() == 'cannot choose an element from an empty array'
// ```
pub fn element[T](array []T) -> !T {
	index := element_index(array)!
	return array[index]
}

// element_index returns a random element index from the given array, or
// error if the array is empty.
//
// Example:
// ```
// empty_array := []i32{}
// err := rand.element_index(empty_array).unwrap_err()
// assert err.msg() == 'cannot choose an element from an empty array'
// ```
//
// ```
// array := [1, 2, 3]
// random_element_index := rand.element_index(array)
// assert random_element_index in [0, 1, 2]
// ```
pub fn element_index[T](array []T) -> !usize {
	if array.len == 0 {
		return error('cannot choose an element from an empty array')
	}
	return u64_below_max(array.len as u64)! as usize
}
