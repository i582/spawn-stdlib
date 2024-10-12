module builtin

import mem
import intrinsics
import reflection

// Array is contiguous growable array. In code it is used as `[]T`.
//
// Examples:
// ```
// mut arr := []i32{} // empty array of i32
// arr.push(5)
// arr.push(6)
//
// arr.len == 2
// arr.cap == 2
// arr[1] == 5
//
// arr.insert(1, 7)
// arr == [5, 7, 6]
//
// for item in arr {
//     println(item)
// }
// ```
//
// To initialize an array with some values, use `[]`:
// ```
// arr := [1, 2, 3]
// ```
// Type of the array is inferred from the first value.
// If you want, for example, array of `u8` with 3 elements, you can write:
// ```
// arr := [1 as u8, 2, 3]
// ```
//
// If you need to create array of given length, use `len` field in initializer:
// ```
// arr := []i32{len: 5}
// ```
//
// To set capacity, use `cap` field:
// ```
// arr := []i32{len: 5, cap: 10}
// ```
//
// Array can be used to create various data structures, for example, a stack:
// ```
// mut stack := []i32{}
// stack.push(5)
// stack.push(6)
// stack.push(7)
//
// for {
//    el := stack.pop() or { break }
//    println(el) // 7, 6, 5
// }
// ```
//
// # Indexing
//
// Array supports indexing with `[]` operator:
// ```
// arr := [1, 2, 3]
// println(arr[1]) // 2
// ```
// Note, indexing starts from 0.
//
// If index is out of bounds, it will panic:
// ```
// arr := [1, 2, 3]
// println(arr[5]) // panic: index out of bounds, index: 5, len: 3
// ```
// To safely get an element, use `get` method:
// ```
// arr := [1, 2, 3]
// println(arr.get(5)) // none
// ```
//
// # Internal representation
//
// Array is represented as a struct with 3 fields:
// 1. `data` — pointer to the first element
// 2. `len` — number of elements in the array
// 3. `cap` — capacity of the array
//
// Array of two elements of type `u8` with capacity 4 will be represented as:
// ```text
//             ptr      len  capacity
//        +--------+--------+--------+
//        | 0x0123 |      2 |      4 |
//        +--------+--------+--------+
//             |
//             v
// Heap   +--------+--------+--------+--------+
//        |    'a' |    'b' |     \0 |     \0 |
//        +--------+--------+--------+--------+
// ```
// Note, that 3rd and 4th elements are initialized with Zero-value for `u8` type.
pub struct Array[T] {
	data *mut T
	len  usize
	cap  usize
}

// new_empty_array creates a new empty array.
//
// Note: don't use this function directly, use `[]T{}` or `[]` instead.
pub fn new_empty_array[T]() -> Array[T] {
	return Array[T]{}
}

// new_array creates a new array with given length and capacity.
// If capacity is less than length, capacity will be set to length.
//
// Note: don't use this function directly, use `[]T{len: 10, cap: 15}` instead.
pub fn new_array[T](len usize, cap usize) -> Array[T] {
	fact_cap := if cap < len { len } else { cap }
	return Array[T]{
		data: mem.alloc(fact_cap * mem.size_of[T]()) as &mut T
		len: len
		cap: fact_cap
	}
}

// new_array_with_init creates a new array with given length and capacity and
// initializes all elements with the result of the given function.
//
// Note: don't use this function directly, use `[]T{init: |i| i * 2}` instead.
pub fn new_array_with_init[T](len usize, cap usize, init fn (i usize) -> T) -> Array[T] {
	mut arr := new_array[T](len, cap)
	for i in 0 .. len {
		arr.fast_set(i, init(i))
	}
	return arr
}

// new_array_with_default creates a new array with given length and capacity and
// initializes all elements with the given default value.
//
// Note: don't use this function directly, use `[]T{len: 5}` instead.
pub fn new_array_with_default[T](len usize, cap usize, def T) -> Array[T] {
	mut arr := new_array[T](len, cap)
	for i in 0 .. len {
		arr.fast_set(i, def)
	}
	return arr
}

// new_array_from_raw creates a new array from a pointer to the data.
// This function is used internally to create an array from an array literal.
//
// Note: this function is actually quite safe, provided that the size of the
// allocated memory for the passed pointer is not less than the passed length,
// otherwise the behavior is undefined.
#[unsafe]
pub fn new_array_from_raw[T](data *T, len usize) -> Array[T] {
	data_copy := mem.alloc(len * mem.size_of[T]()) as &mut T
	mem.fast_copy(data_copy as *mut u8, data as *u8, len * mem.size_of[T]())
	return Array[T]{
		data: data_copy
		len: len
		cap: len
	}
}

// from_ptr creates a new array from a pointer to the data.
// This function is used internally to create an array from an array literal.
//
// Note: this function is actually quite safe, provided that the size of the
// allocated memory for the passed pointer is not less than the passed length,
// otherwise the behavior is undefined.
#[unsafe]
#[track_caller]
pub fn Array.from_ptr[T](data *T, len usize) -> Array[T] {
	mem.assume_safe(data)
	data_copy := mem.alloc(len * mem.size_of[T]()) as &mut T
	mem.fast_copy(data_copy as *mut u8, data as *u8, len * mem.size_of[T]())
	return Array[T]{
		data: data_copy
		len: len
		cap: len
	}
}

#[unsafe]
#[track_caller]
pub fn Array.from_ptr_no_copy[T](data *T, len usize) -> []T {
	return Array[T]{
		data: mem.assume_safe_mut(data)
		len: len
		cap: len
	}
}

// push appends an element to the end of the array.
//
// Example:
// ```
// mut arr := []i32{}
// arr.push(5)
// arr.push(6)
// arr.push(7)
// assert arr == [5, 6, 7]
// ```
pub fn (arr &mut Array[T]) push(value T) {
	arr.ensure_cap(arr.len + 1)
	// SAFETY: we just ensured that there is enough space, so this is safe.
	unsafe { arr.fast_push(value) }
}

// push_within_capacity appends an element to the end of the array if there is
// enough space capacity, otherwise it returns an error.
//
// Unlike [`push`], this function doesn't allocate memory when the capacity is
// reached. The caller is responsible for ensuring that there is enough capacity.
pub fn (arr &mut Array[T]) push_within_capacity(value T) -> ! {
	if arr.len == arr.cap {
		return msg_err('array is full, len: ${arr.len}, cap: ${arr.cap}')
	}
	// SAFETY: we just checked that there is enough space.
	unsafe { arr.fast_push(value) }
}

// fast_push appends an element to the end of the array without checking capacity.
// Use this function only if you are sure that there is enough capacity.
#[unsafe]
pub fn (arr &mut Array[T]) fast_push(value T) {
	unsafe {
		arr.data[arr.len] = value
	}
	arr.len++
}

// push_many appends all elements from the given array to the end of the array.
// Example:
// ```
// mut arr := []i32{}
// arr.push_many([1, 2, 3])
// assert arr == [1, 2, 3]
// ```
pub fn (arr &mut Array[T]) push_many(value Array[T]) {
	arr.ensure_cap(arr.len + value.len)
	// SAFETY: we just ensured that there is enough space, so this is safe.
	unsafe {
		mem.fast_copy((arr.data + arr.len) as *mut u8, value.data as *u8, value.len * mem.size_of[T]())
	}
	arr.len = arr.len + value.len
}

// push_front_many appends all elements from the given array to the beginning of the array.
// Example:
// ```
// mut arr := [1, 2, 3]
// arr.push_front_many([5, 6])
// assert arr == [5, 6, 1, 2, 3]
// ```
pub fn (arr &mut Array[T]) push_front_many(value Array[T]) {
	arr.ensure_cap(arr.len + value.len)
	// SAFETY: we just ensured that there is enough space, so this is safe.
	unsafe {
		mem.fast_copy((arr.data + value.len) as *mut u8, arr.data as *u8, arr.len * mem.size_of[T]())
		mem.fast_copy(arr.data as *mut u8, value.data as *u8, value.len * mem.size_of[T]())
	}
	arr.len = arr.len + value.len
}

// push_ptr appends `len` elements from the given pointer to the end of the array.
// `value` pointer must point to a valid memory region with at least `len` elements.
#[unsafe]
pub fn (arr &mut Array[T]) push_ptr(value *T, len usize) {
	arr.ensure_cap(arr.len + len)
	// SAFETY: we just ensured that there is enough space, so this is safe.
	unsafe {
		mem.fast_copy((arr.data + arr.len) as *mut u8, value as *u8, len * mem.size_of[T]())
	}
	arr.len += len
}

// push_fixed appends [`len`] elements from the given fixed-size array to the end of the array.
// If [`len`] is greater than [`Size`] of the fixed array, the function appends the entire
// fixed-size array.
//
// Example:
// ```
// mut arr := [1, 2, 3]
// fixed := [4, 5, 6] as [3]i32
// arr.push_fixed(fixed, 2)
// assert arr == [1, 2, 3, 4, 5]
// ```
pub fn (arr &mut Array[T]) push_fixed[const Size as usize](other [Size]T, len usize) {
	actual_len := if len > Size { Size } else { len }
	arr.ensure_cap(arr.len + actual_len)
	// SAFETY: we just ensured that there is enough space, so this is safe.
	unsafe {
		mem.fast_copy((arr.data + arr.len) as *mut u8, other.raw() as *u8, actual_len * mem.size_of[T]())
	}
	arr.len += actual_len
}

// prepend appends an element to the beginning of the array.
// Example:
// ```
// mut arr := [1, 2, 3]
// arr.prepend(5)
// assert arr == [5, 1, 2, 3]
// ```
pub fn (arr &mut Array[T]) prepend(value T) {
	arr.ensure_cap(arr.len + 1)
	// SAFETY: we just ensured that there is enough space, so this is safe.
	unsafe {
		mem.fast_copy((arr.data + 1) as *mut u8, arr.data as *u8, arr.len * mem.size_of[T]())
		arr.data[0] = value
	}
	arr.len++
}

// prepend_many appends all elements from the given array to the beginning of the array.
// Example:
// ```
// mut arr := [1, 2, 3]
// arr.prepend_many([5, 6])
// assert arr == [5, 6, 1, 2, 3]
// ```
pub fn (arr &mut Array[T]) prepend_many(value Array[T]) {
	arr.ensure_cap(arr.len + value.len)
	// SAFETY: we just ensured that there is enough space, so this is safe.
	unsafe {
		mem.fast_copy((arr.data + value.len) as *mut u8, arr.data as *u8, arr.len * mem.size_of[T]())
		mem.fast_copy(arr.data as *mut u8, value.data as *u8, value.len * mem.size_of[T]())
	}
	arr.len = arr.len + value.len
}

// prepend_ptr appends `len` elements from the given pointer to the beginning of the array.
// `value` pointer must point to a valid memory region with at least `len` elements.
#[unsafe]
pub fn (arr &mut Array[T]) prepend_ptr(value &T, len usize) {
	arr.ensure_cap(arr.len + len)
	// SAFETY: we just ensured that there is enough space, so this is safe.
	unsafe {
		mem.fast_copy((arr.data + len) as *mut u8, arr.data as *u8, arr.len * mem.size_of[T]())
		mem.fast_copy(arr.data as *mut u8, value as *u8, len * mem.size_of[T]())
	}
	arr.len = arr.len + len
}

// insert inserts an element at the given index. All elements after the index will
// be shifted to the right.
//
// Example:
// ```
// mut arr := [1, 2, 3]
// arr.insert(1, 5)
// assert arr == [1, 5, 2, 3]
// ```
#[track_caller]
pub fn (arr &mut Array[T]) insert(index usize, value T) {
	bounds_check(arr.len, index)
	arr.ensure_cap(arr.len + 1)
	// SAFETY: we just ensured that there is enough space, so this is safe.
	unsafe {
		mem.fast_copy((arr.data + index + 1) as *mut u8, (arr.data + index) as *u8, (arr.len - index) * mem.size_of[T]())
		arr.data[index] = value
	}
	arr.len++
}

// insert_many inserts multiple elements starting at the given index.
// All elements after the index will be shifted to the right.
//
// Example:
// ```
// mut arr := [1, 2, 3]
// arr.insert_many(1, [5, 6])
// assert arr == [1, 5, 6, 2, 3]
// ```
#[track_caller]
pub fn (arr &mut Array[T]) insert_many(index usize, values []T) {
	num_values := values.len
	if arr.len == 0 && index == 0 {
		arr.prepend_many(values)
		return
	}

	bounds_check(arr.len, index)
	arr.ensure_cap(arr.len + num_values)
	// SAFETY: we just ensured that there is enough space, so this is safe.
	unsafe {
		mem.fast_copy((arr.data + index + num_values) as *mut u8, (arr.data + index) as *u8, (arr.len - index) * mem.size_of[T]())
		for i in 0 .. num_values {
			arr.data[index + i] = values[i]
		}
	}
	arr.len += num_values
}

// remove removes an element at the given index and returns it.
// All elements after the index will be shifted to the left, so in
// worst case this function will take O(n) time.
//
// If you don't need the order of elements, use `swap_remove` instead.
//
// Example:
// ```
// mut arr := [1, 2, 3, 4, 5]
// arr.remove(2)
// assert arr == [1, 2, 4, 5]
// ```
#[track_caller]
pub fn (arr &mut Array[T]) remove(index usize) -> T {
	bounds_check(arr.len, index)
	// SAFETY: index is always in bounds
	el := unsafe { arr.fast_get(index) }

	if index == arr.len - 1 {
		// fast path for the last element
		arr.len--
		return el
	}

	// SAFETY: we just checked that the index is in bounds.
	unsafe {
		mem.fast_copy((arr.data + index) as *mut u8, (arr.data + index + 1) as *u8, (arr.len - index - 1) * mem.size_of[T]())
	}
	arr.len--
	return el
}

// swap_remove removes an element at the given index and returns it.
//
// Note, that this function doesn't preserve the order of elements,
// removed element will be replaced with the last element in the array.
// Thanks to this, this function is faster than `remove` and takes O(1) time
// in worst case.
//
// If you need to preserve the order of elements, use `remove` instead.
//
// Example:
// ```
// mut arr := [1, 2, 3, 4, 5]
// arr.swap_remove(2)
// assert arr == [1, 2, 5, 4]
// ```
#[track_caller]
pub fn (arr &mut Array[T]) swap_remove(index usize) -> T {
	bounds_check(arr.len, index)
	// SAFETY: index is always in bounds
	el := unsafe { arr.fast_get(index) }

	if index == arr.len - 1 {
		// fast path for the last element
		arr.len--
		return el
	}

	arr.swap(index, arr.len - 1)
	arr.len--
	return el
}

// remove_first removes the first element from the array.
// Note: complexity of this function is O(n), if you don't need the order of elements,
// use `swap_remove(0)` instead.
//
// Example:
// ```
// mut arr := [1, 2, 3]
// arr.remove_first()
// assert arr == [2, 3]
// ```
//
// ```
// mut arr := [1, 2, 3]
// arr.swap_remove(0) // O(1)
// assert arr == [3, 2]
// ```
#[track_caller]
pub fn (arr &mut Array[T]) remove_first() {
	arr.remove(0)
}

// remove_last removes the last element from the array.
//
// Example:
// ```
// mut arr := [1, 2, 3]
// arr.remove_last()
// assert arr == [1, 2]
// ```
#[track_caller]
pub fn (arr &mut Array[T]) remove_last() {
	bounds_check(arr.len, 0)
	arr.len--
}

// first returns the first element of the array.
// If the array is empty, this function will panic.
//
// If you need to get the first element without panicking, use `first_or_none` instead.
//
// Example:
// ```
// arr := [1, 2, 3]
// arr.first() == 1
// ```
#[track_caller]
pub fn (arr Array[T]) first() -> T {
	comptime if !no_bounds_checking {
		if arr.len == 0 {
			panic('array is empty')
		}
	}
	// SAFETY: we just checked that the array is not empty.
	return unsafe { *arr.data }
}

// first_or_none returns the first element of the array or `none` if the array is empty.
//
// Example:
// ```
// arr := [1, 2, 3]
// arr.first_or_none().unwrap() == 1
// ```
pub fn (arr Array[T]) first_or_none() -> ?T {
	if arr.len == 0 {
		return none
	}
	// SAFETY: we just checked that the array is not empty.
	return unsafe { *arr.data }
}

// last returns the last element of the array or panics if the array is empty.
//
// If you need to get the last element without panicking, use [`last_or_none`] instead.
//
// Example:
// ```
// arr := [1, 2, 3]
// arr.last() == 3
// ```
#[track_caller]
pub fn (arr &Array[T]) last() -> T {
	comptime if !no_bounds_checking {
		if arr.len == 0 {
			panic('array is empty')
		}
	}
	// SAFETY: we just checked that the array is not empty.
	return unsafe { arr.fast_get(arr.len - 1) }
}

// last_or_none returns the last element of the array or `none` if the array is empty.
//
// Example:
// ```
// arr := [1, 2, 3]
// arr.last_or_none().unwrap() == 3
// ```
pub fn (arr Array[T]) last_or_none() -> ?T {
	if arr.len == 0 {
		return none
	}
	// SAFETY: we just checked that the array is not empty.
	return unsafe { arr.fast_get(arr.len - 1) }
}

// pop removes the last element from the array and returns it or returns `none` if the array is empty.
//
// Example:
// ```
// mut arr := [1, 2, 3]
// assert arr.pop().unwrap() == 3
// assert arr == [1, 2]
// ```
pub fn (arr &mut Array[T]) pop() -> ?T {
	if arr.len == 0 {
		return none
	}
	arr.len--
	// SAFETY: we just checked that the array is not empty.
	return unsafe { arr.fast_get(arr.len) }
}

// pop_front removes the first element from the array and returns it or returns `none` if the array is empty.
//
// Example:
// ```
// mut arr := [1, 2, 3]
// assert arr.pop_front().unwrap() == 1
// assert arr == [2, 3]
// ```
pub fn (arr &mut Array[T]) pop_front() -> ?T {
	if arr.len == 0 {
		return none
	}
	// SAFETY: we just checked that the array is not empty.
	el := unsafe { *arr.data }
	arr.len--
	// SAFETY: we just checked that the array is not empty.
	unsafe {
		mem.fast_copy(arr.data as *mut u8, (arr.data + 1) as *u8, arr.len * mem.size_of[T]())
	}
	return el
}

// get returns an element at the given index or `none` if the index is out of bounds.
//
// Example:
// ```
// arr := [1, 2, 3]
// assert arr.get(1).unwrap() == 2
// assert arr.get(5) == none
// ```
pub fn (arr &Array[T]) get(index usize) -> ?T {
	if index >= arr.len {
		return none
	}
	// SAFETY: we just checked that the index is in bounds.
	return unsafe { arr.fast_get(index) }
}

#[track_caller]
pub fn (arr &Array[T]) get_ptr(index usize) -> &T {
	bounds_check(arr.len, index)
	// SAFETY: we just checked that the index is in bounds.
	return unsafe { arr.fast_get_ptr(index) }
}

#[track_caller]
pub fn (arr &Array[T]) get_mut_ptr(index usize) -> &mut T {
	bounds_check(arr.len, index)
	// SAFETY: we just checked that the index is in bounds.
	return unsafe { arr.fast_get_ptr(index) }
}

// get_or_panic returns an element at the given index or panics if the index is out of bounds.
//
// Example:
// ```
// arr := [1, 2, 3]
// assert arr.get_or_panic(1) == 2
// arr.get_or_panic(5) // panic: index out of bounds, index: 5, len: 3
// ```
#[track_caller]
pub fn (arr &Array[T]) get_or_panic(index usize) -> T {
	bounds_check(arr.len, index)
	// SAFETY: we just checked that the index is in bounds.
	return unsafe { arr.fast_get(index) }
}

// fast_get returns an element at the given index without checking bounds.
// Use this function only if you are sure that the index is in bounds.
#[unsafe]
#[skip_profile("used in tracing profile to collect data")]
pub fn (arr Array[T]) fast_get(index usize) -> T {
	return unsafe { arr.data[index] }
}

// fast_get_ptr returns a pointer to an element at the given index without checking bounds.
// Use this function only if you are sure that the index is in bounds.
#[unsafe]
#[skip_profile]
pub fn (arr Array[T]) fast_get_ptr(index usize) -> &mut T {
	return mem.assume_safe_mut(unsafe { arr.data + index })
}

// set sets an element at the given index.
// If the index is out of bounds, this function will panic.
//
// Example:
// ```
// mut arr := [1, 2, 3]
// arr.set(1, 5)
// assert arr == [1, 5, 3]
// ```
#[track_caller]
pub fn (arr &mut Array[T]) set(index usize, value T) {
	bounds_check(arr.len, index)
	// SAFETY: we just checked that the index is in bounds.
	unsafe { arr.fast_set(index, value) }
}

// fast_set sets an element at the given index without checking bounds.
// Use this function only if you are sure that the index is in bounds.
#[unsafe]
#[skip_coverage("used in coverage to collect data")]
#[skip_profile("used in tracing profile to collect data")]
pub fn (arr &mut Array[T]) fast_set(index usize, value T) {
	unsafe {
		arr.data[index] = value
	}
}

// reserve reserves capacity for at least `additional` more elements.
//
// Array may reserve more space to avoid frequent reallocations.
// After calling this function, capacity will be greater or equal to
// `len + additional`.
//
// If capacity is already greater than `len + additional`, this function does nothing.
//
// Example:
// ```
// mut arr := []i32{len: 5}
// arr.reserve(10)
// assert arr.cap >= 15
// ```
pub fn (arr &mut Array[T]) reserve(additional usize) {
	arr.ensure_cap(arr.len + additional)
}

// reserve_exact reserves exactly `additional` more elements.
//
// Unlike [`reserve`], this function doesn't reserve more space than needed to
// speculatively avoid frequent reallocations. If capacity is already greater
// than `len + additional`, this function does nothing.
//
// Example:
// ```
// mut arr := []i32{len: 5}
// arr.reserve_exact(10)
// assert arr.cap == 15
// ```
pub fn (arr &mut Array[T]) reserve_exact(additional usize) {
	new_cap := arr.len + additional
	if new_cap <= arr.cap {
		// fast path, we have enough capacity for the new elements so we
		// don't need to allocate new memory and copy the old elements
		return
	}
	new_data := mem.alloc(new_cap * mem.size_of[T]())
	mem.fast_copy(new_data, arr.data as *u8, arr.len * mem.size_of[T]())
	arr.data = new_data
	arr.cap = new_cap
}

// swap swaps the elements at the given indices in the array.
// If the indices are out of bounds, this function will panic.
//
// Example:
// ```
// mut arr := [1, 2, 3]
// arr.swap(0, 2)
// assert arr == [3, 2, 1]
// ```
pub fn (arr &mut Array[T]) swap(index1 usize, index2 usize) {
	comptime if !no_bounds_checking {
		if index1 >= arr.len || index2 >= arr.len {
			panic('index out of bounds, index1: ${index1}, index2: ${index2}, len: ${arr.len}')
		}
	}

	if index1 == index2 {
		return
	}

	// SAFETY: we just checked that the indices are in bounds.
	unsafe {
		tmp := arr.fast_get(index1)
		arr[index1] = arr.fast_get(index2)
		arr[index2] = tmp
	}
}

pub fn (arr Array[T]) copy_from(other Array[T]) -> usize {
	count := if arr.len < other.len { arr.len } else { other.len }
	unsafe {
		mem.fast_copy(arr.data as *mut u8, other.data as *u8, count * mem.size_of[T]())
	}
	return count
}

// reverse returns a new array with elements in reverse order.
//
// To reverse the array inplace, see [`reverse_inplace`] method.
//
// Example:
// ```
// arr := [1, 2, 3]
// assert arr.reverse() == [3, 2, 1]
// ```
#[must_use("reverse returns a new array without modifying the original")]
pub fn (arr Array[T]) reverse() -> []T {
	mut result := []T{len: arr.len}
	for i in 0 .. arr.len {
		// SAFETY: index is always in bounds
		unsafe { result.fast_set(i, arr.fast_get(arr.len - i - 1)) }
	}
	return result
}

// reverse_inplace reverses the array in place.
//
// To get a new array with reverse order, see [`reverse`] method.
//
// Example:
// ```
// mut arr := [1, 2, 3]
// arr.reverse_inplace()
// assert arr == [3, 2, 1]
// ```
pub fn (arr &mut Array[T]) reverse_inplace() {
	for i in 0 .. arr.len / 2 {
		tmp := arr.fast_get(i)
		arr.fast_set(i, arr.fast_get(arr.len - i - 1))
		arr.fast_set(arr.len - i - 1, tmp)
	}
}

#[unsafe]
#[track_caller]
pub fn (arr &mut Array[T]) set_len(new usize) {
	if new > arr.cap {
		panic('new length is greater than the capacity, new: ${new}, cap: ${arr.cap}')
	}
	arr.len = new
}

pub fn (arr &mut Array[T]) ensure_cap(required usize) {
	if intrinsics.likely(required <= arr.cap) {
		return
	}
	arr.cap = array_ensure_cap(required, mem.size_of[T](), (&mut arr.data) as &mut &u8, arr.cap)
}

// array_ensure_cap ensures that the array has at least the given capacity.
//
// This function is standalone because we don't want to have many variants of this
// code for all the different array types, this prevents code bloat.
fn array_ensure_cap(required usize, element_size usize, data_ptr &mut &u8, cap usize) -> usize {
	mut new_cap := if cap > 0 { cap * 2 } else { 2 }
	for required > new_cap {
		new_cap = new_cap * 2
	}
	// SAFETY: we use this function only internally and always with a valid pointers.
	unsafe {
		new_data := mem.alloc(new_cap * element_size)
		mem.fast_copy(new_data, *data_ptr, cap * element_size)
		*data_ptr = new_data
	}
	return new_cap
}

pub fn (arr Array[T]) add(other Array[T]) -> Array[T] {
	mut result := []T{cap: arr.len + other.len}
	result.push_many(arr)
	result.push_many(other)
	return result
}

pub fn (arr &Array[T]) sub(start usize, end usize) -> Array[T] {
	comptime if !no_bounds_checking {
		if start > arr.len || end > arr.len {
			panic('index out of bounds, start: ${start}, end: ${end}, len: ${arr.len}')
		}
		if start > end {
			panic('cannot sub with start > end, start: ${start}, end: ${end}')
		}
	}
	mut result := []T{cap: end - start}
	for i in start .. end {
		// SAFETY: i is always in bounds.
		result.push(unsafe { (*arr).fast_get(i) })
	}
	return result
}

pub fn (arr Array[T]) slice(start usize, end usize) -> Array[T] {
	comptime if !no_bounds_checking {
		if start > arr.len || end > arr.len {
			panic('index out of bounds, start: ${start}, end: ${end}, len: ${arr.len}')
		}
		if start > end {
			panic('cannot slice with start > end, start: ${start}, end: ${end}')
		}
	}
	mut result := []T{cap: end - start}
	for i in start .. end {
		result.push(arr.fast_get(i))
	}
	return result
}

#[track_caller]
pub fn (arr Array[T]) slice2(start usize, end usize, inclusive_end bool) -> Array[T] {
	mut final_start := if start == -1 { 0 as usize } else { start }
	mut final_end := if end == -1 { arr.len } else { end } + inclusive_end as usize

	comptime if !no_bounds_checking {
		if final_start > arr.len || final_end > arr.len {
			end_for_error := if end == -1 { arr.len } else { end }
			panic('index out of bounds, start: ${final_start}, end: ${end_for_error}, inclusive_end: ${inclusive_end}, len: ${arr.len}')
		}
		if final_start > final_end {
			end_for_error := if end == -1 { arr.len } else { end }
			panic('cannot slice with start > end, start: ${final_start}, inclusive_end: ${inclusive_end}, end: ${end_for_error}')
		}
	}
	return Array[T]{
		data: arr.data + final_start
		len: final_end - final_start
		cap: final_end - final_start
	}
}

pub fn (arr Array[T]) slice3(range Range[usize]) -> Array[T] {
	comptime if !no_bounds_checking {
		if range.start > arr.len || range.end > arr.len {
			panic('index out of bounds, start: ${range.start}, end: ${range.end}, len: ${arr.len}')
		}
		if range.start > range.end {
			panic('cannot slice with start > end, start: ${range.start}, end: ${range.end}')
		}
	}
	return Array[T]{
		data: arr.data + range.start
		len: range.end - range.start
		cap: range.end - range.start
	}
}

pub fn (arr Array[T]) partition(cb fn (el T) -> bool) -> ([]T, []T) {
	mut left := []T{}
	mut right := []T{}
	for item in arr {
		if cb(item) {
			left.push(item)
		} else {
			right.push(item)
		}
	}
	return left, right
}

pub fn (arr &mut Array[T]) clear() {
	arr.len = 0
}

pub fn (arr &mut Array[T]) trim(new_len usize) {
	comptime if !no_bounds_checking {
		if new_len > arr.len {
			panic('new_len is greater than the current length, new_len: ${new_len}, len: ${arr.len}')
		}
	}
	arr.len = new_len
}

pub fn (arr &mut Array[T]) drop(count usize) {
	n := if count > arr.len { arr.len } else { count }
	arr.data = arr.data + n
	arr.len = arr.len - n
	arr.cap = arr.cap - n
}

// map applies the provided callback function to each element of the array and
// returns a new array containing the results. The original array remains unmodified.
//
// Example:
// ```
// arr := [1, 2, 3]
// assert arr.map(|x i32| x * x) == [1, 4, 9]
// ```
#[must_use("map returns a new array without modifying the original")]
pub fn (arr Array[T]) map[U](cb fn (el T) -> U) -> []U {
	mut result := []U{cap: arr.len}
	for item in arr {
		// SAFETY: we always have enough memory for the new element.
		unsafe { result.fast_push(cb(item)) }
	}
	return result
}

// map_not_none applies the provided callback function to  element
// of the array and returns a new array containing the non-`none` results.
// The original array remains unmodified.
//
// Example:
// ```
// arr := ["10", "hello", "20"]
// assert arr.map_not_none(|el| el.i32_opt()) == [10, 20]
// ```
#[must_use("map_not_none returns a new array without modifying the original")]
pub fn (arr Array[T]) map_not_none[U](cb fn (el T) -> ?U) -> []U {
	mut result := []U{cap: arr.len}
	for item in arr {
		if value := cb(item) {
			// SAFETY: we always have enough memory for the new element.
			unsafe { result.fast_push(value) }
		}
	}
	return result
}

// filter returns an array that contains only the elements
// that satisfy the predicate.
//
// Example:
// ```
// arr := [1, 2, 3, 4, 5]
// evens := arr.filter(|el| el % 2 == 0)
// assert evens == [2, 4]
// ```
#[must_use("filter returns a new array without modifying the original")]
pub fn (arr Array[T]) filter(cb fn (el T) -> bool) -> []T {
	mut result := []T{cap: arr.len}
	for item in arr {
		if cb(item) {
			// SAFETY: we always have enough memory for the new element.
			unsafe { result.fast_push(item) }
		}
	}
	return result
}

#[must_use("filter_is_instance returns a new array without modifying the original")]
pub fn (arr Array[T]) filter_is_instance[U]() -> Array[U] where T: reflection.Interface {
	mut result := []U{cap: arr.len}
	for item in arr {
		if item is U {
			// SAFETY: we always have enough memory for the new element.
			unsafe { result.fast_push(*item) }
		}
	}
	return result
}

// reduce applies a function to each element in the array [`arr`] and combines
// them into a single value of type `U`.
//
// The function starts with an initial value `init` and iterates over each
// element in the array, applying the provided callback function [`cb`] to the
// accumulated result and the current element. The result of each callback
// invocation becomes the new accumulated value for the next iteration.
//
// Example:
// ```
// arr := [1, 2, 3, 4, 5]
// sum := arr.reduce(0, |acc, el| acc + el)
//
// assert sum == 15
// ```
//
// In this example, the `reduce` function computes the sum of all elements
// in the array by starting with an initial value of `0` and using a callback
// function that adds each element to the accumulated sum.
#[must_use("reduce returns a value without modifying the original array")]
pub fn (arr Array[T]) reduce[U](init U, cb fn (acc U, el T) -> U) -> U {
	mut result := init
	for item in arr {
		result = cb(result, item)
	}
	return result
}

// find iterates over the elements of the array and returns the first element
// for which the provided callback function returns true. If no such element is found,
// it returns none.
//
// Example:
// ```
// arr := [1, 2, 3]
// assert arr.find(|el| el % 2 == 0).unwrap() == 2
// ```
pub fn (arr Array[T]) find(cb fn (el T) -> bool) -> ?T {
	for item in arr {
		if cb(item) {
			return item
		}
	}
	return none
}

// find_index iterates over the elements of the array and returns the index
// of first element for which the provided callback function returns true.
// If no such element is found, it returns none.
//
// Example:
// ```
// arr := [1, 2, 3]
// assert arr.find_index(|el| el % 2 == 0).unwrap() == 1
// ```
pub fn (arr Array[T]) find_index(cb fn (el T) -> bool) -> ?usize {
	for i in 0 .. arr.len {
		if cb(arr.fast_get(i)) {
			return i
		}
	}
	return none
}

// split_once splits the array into two arrays at the first element
// that satisfies the predicate. The element that satisfies the predicate
// is not included in any of the resulting arrays.
//
// Example:
// ```
// arr := ['--flag', 'value', '--', '--flag2', 'value2']
// assert arr.split_once(|el| el == '--') == (['--flag', 'value'], ['--flag2', 'value2'])
// ```
pub fn (arr Array[T]) split_once(cb fn (el T) -> bool) -> ([]T, []T) {
	for i, item in arr {
		if cb(item) {
			return arr.sub(0, i), arr.sub(i + 1, arr.len)
		}
	}
	return arr, []T{}
}

// any returns `true` if the provided callback function returns `true`
// for any element in the array. If no such element is found, it returns `false`.
//
// Example:
// ```
// arr := [1, 2, 3]
// assert arr.any(|el| el % 2 == 0) == true  // since 2 is even
// assert arr.any(|el| el > 5) == false      // no element is greater than 5
// ```
pub fn (arr Array[T]) any(cb fn (el T) -> bool) -> bool {
	for item in arr {
		if cb(item) {
			return true
		}
	}
	return false
}

// all returns `true` if the provided callback function returns `true`
// for all elements in the array. If any element does not satisfy the callback
// function, it returns `false`.
//
// Example:
// ```
// arr := [1, 2, 3]
// assert arr.all(|el| el > 0) == true        // all elements are greater than 0
// assert arr.all(|el| el % 2 == 0) == false  // not all elements are even
// ```
pub fn (arr Array[T]) all(cb fn (el T) -> bool) -> bool {
	for item in arr {
		if !cb(item) {
			return false
		}
	}
	return true
}

pub fn (arr Array[T]) for_each(cb fn (el T)) {
	for item in arr {
		cb(item)
	}
}

pub fn (arr Array[T]) repeat(count usize) -> Array[T] {
	mut result := []T{cap: arr.len * count}
	for i in 0 .. count {
		result.push_many(arr)
	}
	return result
}

pub fn (arr Array[T]) size_in_bytes() -> usize {
	// TODO: what about alignment?
	return arr.len * mem.size_of[T]()
}

pub fn (arr &Array[T]) equal(other Array[T]) -> bool
	where T: Equality
{
	if arr.len != other.len {
		return false
	}
	for i in 0 .. arr.len {
		if arr.fast_get(i) != other.fast_get(i) {
			return false
		}
	}
	return true
}

pub fn (arr Array[T]) raw() -> *T {
	return arr.data
}

pub fn (arr Array[T]) mut_raw() -> *mut T {
	return arr.data
}

pub fn (arr Array[T]) iter() -> ArrayIterator[T] {
	return ArrayIterator[T]{ arr: arr, index: 0 }
}

pub fn (arr Array[T]) back_iter() -> ArrayBackIterator[T] {
	return ArrayBackIterator[T]{ arr: arr, index: 0 }
}

struct ArrayIterator[T] {
	arr   []T
	index usize
}

pub fn (it &mut ArrayIterator[T]) next() -> ?T {
	if it.index < it.arr.len {
		el := it.arr.fast_get(it.index)
		it.index++
		return el
	}
	return none
}

pub struct ArrayBackIterator[T] {
	arr   []T
	index usize
}

pub fn (it &mut ArrayBackIterator[T]) next() -> ?T {
	if it.index < it.arr.len {
		el := it.arr.fast_get(it.arr.len - it.index - 1)
		it.index++
		return el
	}
	return none
}

// contains returns `true` if the array contains the specified value.
// If the value is not found in the array, it returns `false`.
//
// Example:
// ```
// arr := [1, 2, 3, 4, 5]
// assert arr.contains(3) == true   // since 3 is in the array
// assert arr.contains(6) == false  // since 6 is not in the array
// ```
pub fn (arr Array[T]) contains(value T) -> bool
	where T: Equality
{
	for item in arr {
		if item == value {
			return true
		}
	}
	return false
}

// index returns the index of the first occurrence of the specified value
// in the array. If the value is not found, it returns `none`.
//
// Example:
// ```
// arr := [1, 2, 3, 4, 5]
// assert arr.index(3).unwrap() == 2   // returns index 2 where 3 is found
// assert arr.index(6) == none         // returns none since 6 is not in the array
// ```
pub fn (arr Array[T]) index(value T) -> ?usize
	where T: Equality
{
	for i, item in arr {
		if item == value {
			return i
		}
	}
	return none
}

pub fn (arr Array[T]) join(sep string) -> string
	where T: Display
{
	mut parts := []string{cap: arr.len}
	for item in arr {
		parts.push(item.str())
	}

	mut len := 0 as usize
	for i, s in parts {
		len = len + s.len
		if i as usize != arr.len - 1 {
			len = len + sep.len
		}
	}
	mut result := mem.alloc(len + 1) as *mut u8
	mut pos := 0 as usize
	unsafe {
		for i, s in parts {
			mem.fast_copy(result + pos, s.data, s.len)
			pos = pos + s.len

			if i as usize != arr.len - 1 {
				mem.fast_copy(result + pos, sep.data, sep.len)
				pos = pos + sep.len
			}
		}
		result[len] = 0
	}
	return string.view_from_c_str_len(result, len)
}

pub fn (arr &Array[T]) ascii_str() -> string
	where T: u8
{
	return string.view_from_c_str_len(arr.raw() as *u8, arr.len).clone()
}

pub fn (arr Array[T]) starts_with(prefix string) -> bool
	where T: u8
{
	if arr.len < prefix.len {
		return false
	}
	return mem.compare(arr.data as *u8, prefix.data, prefix.len) == 0
}

pub fn (arr Array[T]) starts_with_other(prefix []u8) -> bool
	where T: u8
{
	if arr.len < prefix.len {
		return false
	}
	return mem.compare(arr.data as *u8, prefix.raw(), prefix.len) == 0
}

pub fn (arr Array[T]) debug_str() -> string
	where T: Debug
{
	mut parts := []string{cap: arr.len}
	for item in arr {
		parts.push(item.debug_str())
	}

	mut len := 2 as usize
	for i, s in parts {
		len = len + s.len
		if i as usize != arr.len - 1 {
			len = len + 2
		}
	}
	mut result := mem.alloc(len + 1) as *mut u8
	mut pos := 1 as usize
	unsafe {
		result[0] = b`[`
		for i, s in parts {
			mem.fast_copy(result + pos, s.data, s.len)
			pos = pos + s.len

			if i as usize != arr.len - 1 {
				result[pos] = b`,`
				result[pos + 1] = b` `
				pos = pos + 2
			}
		}
		result[len - 1] = b`]`
		result[len] = 0
	}
	return string.view_from_c_str_len(result, len)
}

pub fn (arr Array[T]) str() -> string
	where T: Display
{
	return arr.inner_str(0)
}

pub fn (arr Array[T]) inner_str(indent i32) -> string
	where T: Display
{
	mut result := []u8{cap: 100}

	result.push(b`[`)
	for i, item in arr {
		mut item_str := item.str()

		comptime if T is string {
			result.push(b`'`)
		}

		comptime if T is rune {
			result.push(b`\``)
		}

		if indent > 0 && item_str.count('\n') > 0 {
			indent_text_impl(&mut result, item_str, indent * 3, true)
		} else {
			result.push_many(item_str.bytes_no_copy())
		}

		if item_str.ends_with('\n') {
			result.trim(1)
		}

		comptime if T is rune {
			result.push(b`\``)
		}

		comptime if T is string {
			result.push(b`'`)
		}

		if i as usize != arr.len - 1 {
			result.push(b`,`)
			result.push(b` `)
		}
	}
	result.push(b`]`)

	return string.view_from_bytes(result)
}

pub fn (arr Array[T]) as_pointers() -> []&T {
	mut result := []&T{cap: arr.len}
	for i in 0 .. arr.len {
		result.fast_push(mem.assume_safe(arr.data + i))
	}
	return result
}

pub fn (arr Array[T]) as_mut_pointers() -> []&mut T {
	mut result := []&mut T{cap: arr.len}
	for i in 0 .. arr.len {
		result.fast_push(mem.assume_safe_mut(arr.data + i))
	}
	return result
}

pub fn (arr &mut Array[T]) sort(cb fn (a &T, b &T) -> Ordering) {
	if arr.len < 2 {
		return
	}
	intrinsics.quick_sort(arr.data, arr.len, mem.size_of[T](), cb)
}

pub fn (arr &mut Array[T]) sort_by(cb fn (a &T, b &T) -> Ordering) {
	if arr.len < 2 {
		return
	}
	intrinsics.quick_sort(arr.data, arr.len, mem.size_of[T](), cb)
}

pub fn (arr &Array[T]) sorted_by(cb fn (a &T, b &T) -> Ordering) -> Array[T] {
	mut result := arr.copy()
	result.sort_by(cb)
	return result
}

fn sort_cb[T: Ordered](a &T, b &T) -> Ordering {
	return ((*a) > (*b)) as Ordering
}

fn rev_sort_cb[T: Ordered](a &T, b &T) -> Ordering {
	return ((*a) < (*b)) as Ordering
}

pub fn (arr &Array[T]) sorted() -> Array[T]
	where T: Clone + Ordered
{
	mut result := arr.clone()
	result.sort(sort_cb[T])
	return result
}

pub fn (arr &Array[T]) rev_sorted() -> Array[T]
	where T: Clone + Ordered
{
	mut result := arr.clone()
	result.sort(rev_sort_cb[T])
	return result
}

// copy returns a copy of the array.
// Values are copied, not cloned. If you need deep copy, use [`clone`] instead.
//
// Example:
// ```
// arr := [1, 2, 3]
// mut arr2 := arr.copy()
// arr2[0] = 5
// assert arr == [1, 2, 3]
// assert arr2 == [5, 2, 3]
// ```
pub fn (arr Array[T]) copy() -> []T {
	mut result := []T{cap: arr.len}
	for item in arr {
		result.fast_push(item)
	}
	return result
}

// clone returns a deep copy of the array.
// If you need shallow copy, use [`copy`] instead.
pub fn (arr Array[T]) clone() -> []T
	where T: Clone
{
	mut result := []T{cap: arr.len}
	for item in arr {
		// SAFETY: array is allocated with the same number of elements
		unsafe { result.fast_push(item.clone()) }
	}
	return result
}

// group_by groups the elements of an array into a map based on a key extracted
// from each element using the provided callback function [`cb`].
//
// The function iterates over each element in the array and applies the callback
// function to extract a key of type `K`. Elements with the same key are grouped
// together into an array, which is then stored in the resulting map under that key.
//
// Example:
// ```
// arr := [1, 2, 3, 4, 5, 6]
// grouped := arr.group_by(|el| el % 3)
//
// assert grouped[0] == [3, 6]
// assert grouped[1] == [1, 4]
// assert grouped[2] == [2, 5]
// ```
//
// In this example, the [`group_by`] method groups integers based on their remainder
// when divided by 3. The resulting map associates each possible remainder (0, 1, 2)
// with an array of integers that produce that remainder.
pub fn (arr Array[T]) group_by[K](cb fn (el T) -> K) -> map[K][]T
	where K: MapKey
{
	mut result := map[K][]T{}
	for item in arr {
		key := cb(item)
		if els_arr := result.get_mut_ptr_or_none(key) {
			els_arr.push(item)
		} else {
			mut new_arr := []T{cap: 1}
			new_arr.push(item)
			result.insert(key, new_arr)
		}
	}
	return result
}

pub fn (arr &Array[T]) group() -> map[T]usize {
	mut result := map[T]usize{}
	for item in arr {
		if count := result.get_mut_ptr_or_none(item) {
			*count++
		} else {
			result.insert(item, 1)
		}
	}
	return result
}

pub fn (arr &Array[T]) chunks(size usize) -> [][]T {
	mut result := [][]T{}
	mut chunk := []T{cap: size}
	for item in arr {
		chunk.push(item)
		if chunk.len == size {
			result.push(chunk)
			chunk = []T{cap: size}
		}
	}
	if chunk.len > 0 {
		result.push(chunk)
	}
	return result
}

pub fn (arr Array[T]) to_map[K](mapper fn (el T) -> K) -> map[K]T
	where K: MapKey
{
	mut result := map[K]T{}
	for item in arr {
		key := mapper(item)
		result.insert(key, item)
	}
	return result
}

pub fn (arr Array[T]) flat_map[U](mapper fn (el T) -> []U) -> []U {
	mut result := []U{}
	for item in arr {
		result.push_many(mapper(item))
	}
	return result
}

pub fn (arr Array[T]) distinct() -> Array[T]
	where T: MapKey
{
	mut result := []T{}
	mut set := Set.new[T]()
	for item in arr {
		if !set.contains(item) {
			result.push(item)
			set.insert(item)
		}
	}
	return result
}

pub fn (arr Array[T]) distinct_by[K](cb fn (el T) -> K) -> Array[T]
	where K: MapKey
{
	mut result := []T{}
	mut set := Set.new[K]()
	for item in arr {
		key := cb(item)
		if !set.contains(key) {
			result.push(item)
			set.insert(key)
		}
	}
	return result
}

pub fn (arr &Array[T]) enumerate() -> [](usize, T) {
	mut result := [](usize, T){cap: arr.len}
	for i, item in arr {
		result.push((i as usize, item))
	}
	return result
}

pub fn (arr Array[T]) to_set() -> Set[T]
	where T: MapKey
{
	mut result := Set.new[T]()
	for item in arr {
		result.insert(item)
	}
	return result
}

// zip combines two arrays into a new array of tuples, where each tuple
// contains corresponding elements from the two input arrays [`arr`] and [`other`].
//
// Returns an array of tuples `(T, U)`, where each tuple consists of an element from
// `arr` and the corresponding element from `other`.
//
// The length of the resulting array is determined by the smaller length of the
// two input arrays. If [`arr`] has fewer elements than [`other`], or vice versa,
// only elements up to the length of the smaller array are included in the result.
//
// Example:
// ```
// arr := [1, 2, 3]
// other := ["a", "b", "c", "d"]
// zipped := arr.zip(other)
//
// assert zipped == [(1, "a"), (2, "b"), (3, "c")]
// ```
//
// In this example, the [`zip`] method combines the elements of `arr` and `other`
// into tuples. The resulting array contains tuples with elements from both arrays
// up to the length of the shorter array. The extra element "d" in `other` is not included
// in the result because `arr` has only three elements.
pub fn (arr Array[T]) zip[U](other []U) -> [](T, U) {
	len := if arr.len < other.len { arr.len } else { other.len }
	mut result := [](T, U){cap: len}
	for i in 0 .. len {
		result.fast_push((arr.fast_get(i), other.fast_get(i)))
	}
	return result
}

pub fn (arr &Array[T]) hash() -> u64
	where T: Hashable
{
	mut res := 0 as u64
	for item in arr {
		res = res.wrapping_mul(32).wrapping_add(item.hash())
	}
	return res
}

// max returns the maximum element of the array or `none` if the array is empty.
//
// Example:
// ```
// arr := [1, 2, 3]
// assert arr.max().unwrap() == 3
// ```
pub fn (arr &Array[T]) max() -> ?T
	where T: Ordered
{
	if arr.len == 0 {
		return none
	}
	mut max := arr.fast_get(0)
	for i in 1 .. arr.len {
		if arr.fast_get(i) > max {
			max = arr.fast_get(i)
		}
	}
	return max
}

// index_max returns the index of maximum element of the array
// or `none` if the array is empty.
//
// Example:
// ```
// arr := [1, 2, 3]
// assert arr.index_max().unwrap() == 2
// ```
pub fn (arr &Array[T]) index_max() -> ?usize
	where T: Ordered
{
	if arr.len == 0 {
		return none
	}
	mut index := 0 as usize
	mut max := arr.fast_get(0)
	for i in 1 .. arr.len {
		if arr.fast_get(i) > max {
			max = arr.fast_get(i)
			index = i
		}
	}
	return index
}

// min returns the minimum element of the array or `none` if the array is empty.
//
// Example:
// ```
// arr := [1, 2, 3]
// assert arr.min().unwrap() == 1
// ```
pub fn (arr &Array[T]) min() -> ?T
	where T: Ordered
{
	if arr.len == 0 {
		return none
	}
	mut min := arr.fast_get(0)
	for i in 1 .. arr.len {
		if arr.fast_get(i) < min {
			min = arr.fast_get(i)
		}
	}
	return min
}

// index_min returns the index of minimum element of the array
// or `none` if the array is empty.
//
// Example:
// ```
// arr := [1, 2, 3]
// assert arr.index_min().unwrap() == 0
// ```
pub fn (arr &Array[T]) index_min() -> ?usize
	where T: Ordered
{
	if arr.len == 0 {
		return none
	}
	mut index := 0 as usize
	mut min := arr.fast_get(0)
	for i in 1 .. arr.len {
		if arr.fast_get(i) < min {
			min = arr.fast_get(i)
			index = i
		}
	}
	return index
}

// sum calculates the sum of all elements in the array `arr`.
//
// If the array is empty, the function returns `none` to indicate that there is
// no sum to compute.
//
// Example:
// ```
// arr := [1, 2, 3, 4, 5]
// result := arr.sum()
//
// assert result == 15
// ```
pub fn (arr &Array[T]) sum() -> ?T
	where T: Add
{
	if arr.len == 0 {
		return none
	}

	mut res := arr[0]
	for i in 1 .. arr.len {
		el := arr.fast_get(i)
		res = res + el
	}

	return res
}

pub fn (arr &Array[T]) fixed_slice[const Size as usize]() -> [Size]T {
	mut res := [Size]T{}
	for i in 0 .. Size {
		res[i] = arr[i]
	}
	return res
}

#[track_caller]
fn bounds_check(len usize, index usize) {
	comptime if !no_bounds_checking {
		if intrinsics.unlikely(index >= len) {
			panic('index out of bounds, index: ${index}, len: ${len}')
		}
	}
}
