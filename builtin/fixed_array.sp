module builtin

import mem

// FixedArray is array of fixed size. In code it is used as `[Size]T`.
//
// Example:
// ```
// mut arr := [5]i32{} // array of i32 with size of 5
// arr[1] = 10
// assert arr == [0, 10, 0, 0, 0] as [5]i32
// ```
//
// To initialize an array with some values, use `[]` with explicit as cast:
// ```
// arr := [1, 2, 3] as [3]i32
// ```
//
// # Indexing
//
// Fixed array supports indexing with `[]` operator:
// ```
// arr := [1, 2, 3] as [3]i32
// println(arr[1]) // 2
// ```
// Note, indexing starts from 0.
//
// If index is out of bounds, it will panic:
// ```
// arr := [1, 2, 3] as [3]i32
// index := 5
// println(arr[index]) // panic: index out of bounds, index: 5, len: 3
// ```
// To safely get an element, use `get` method:
// ```
// arr := [1, 2, 3] as [3]i32
// println(arr.get(5)) // none
// ```
pub struct FixedArray[T, const Size as usize] {
	data [Size]T
}

// new_fixed_array creates a new array of passed type and size with [`default`] values.
//
// Note: don't use this function directly, use `[Size]T{}` or `[1, 2, 3] as [3]i32` instead.
pub fn new_fixed_array[T, const Size as usize](default T) -> FixedArray[T, Size] {
	mut res := FixedArray[T, Size]{}
	for i in 0 .. Size {
		res.data[i] = default
	}
	return res
}

// new_fixed_array_with_init creates a new array of passed type and size with
// each of the value initialized with result of passed [`init`] function.
//
// Note: don't use this function directly, use `[Size]T{init: <func>}` instead.
pub fn new_fixed_array_with_init[T, const Size as usize](init fn (i usize) -> T) -> FixedArray[T, Size] {
	mut res := FixedArray[T, Size]{}
	for i in 0 .. Size {
		res.data[i] = init(i)
	}
	return res
}

// new_fixed_array_without_init creates a new array of passed type and size without
// init elements. This means that actual values can contain garbage.
pub fn new_fixed_array_without_init[T, const Size as usize]() -> FixedArray[T, Size] {
	return FixedArray[T, Size]{}
}

// len returns the length of the array. This function always returns the same value.
pub fn (arr &FixedArray[T, Size]) len() -> usize {
	return Size
}

// set sets an element at the given index.
// If the index is out of bounds, this function will panic.
//
// Example:
// ```
// mut arr := [1, 2, 3] as [3]i32
// arr.set(1, 5)
// assert arr == [1, 5, 3] as [3]i32
// ```
pub fn (arr &mut FixedArray[T, Size]) set(i usize, val T) {
	comptime if !no_bounds_checking {
		if i >= Size {
			panic("index out of bounds, index: ${i}, size: ${Size}")
		}
	}

	arr.data[i] = val
}

// fast_set sets an element at the given index without checking bounds.
// Use this function only if you are sure that the index is in bounds.
#[unsafe]
pub fn (arr &mut FixedArray[T, Size]) fast_set(i usize, val T) {
	arr.data[i] = val
}

// as_ptr returns a mutable pointer to the first element of the array.
// This function is useful when interfacing with C or other low-level languages,
// as it allows direct access to the underlying data.
//
// Example:
// ```
// import sys.libc
//
// fn main() {
//     fd := libc.STDIN_FILENO
//     mut buf := [4096]u8{}
//     readed := libc.read(fd, buf.as_ptr(), 4096)
// }
// ```
pub fn (arr &mut FixedArray[T, Size]) as_ptr() -> &mut T {
	return unsafe { &mut arr.data[0] }
}

// get returns an element at the given index or `none` if the index is out of bounds.
//
// Example:
// ```
// mut arr := [1, 2, 3] as [3]i32
// assert arr.get(1).unwrap() == 2
// assert arr.get(5) == none
// ```
pub fn (arr &FixedArray[T, Size]) get(i usize) -> ?T {
	comptime if !no_bounds_checking {
		if i >= Size {
			return none
		}
	}

	return arr.data[i]
}

// get_ptr returns a mutable reference to element at the given index or
// panics if the index is out of bounds.
//
// Example:
// ```
// mut arr := [1, 2, 3] as [3]i32
// assert *arr.get_ptr(1) == 2
// ```
#[track_caller]
pub fn (arr &mut FixedArray[T, Size]) get_ptr(i usize) -> &mut T {
	comptime if !no_bounds_checking {
		if i >= Size {
			panic("index out of bounds, index: ${i}, size: ${Size}")
		}
	}

	return unsafe { &mut arr.data[i] }
}

// get_ptr_or_none returns a mutable reference to element at the given index or
// `none` if the index is out of bounds.
//
// Example:
// ```
// mut arr := [1, 2, 3] as [3]i32
// assert *arr.get_ptr_or_none(1).unwrap() == 2
// assert arr.get_ptr_or_none(5) == none
// ```
pub fn (arr &mut FixedArray[T, Size]) get_ptr_or_none(i usize) -> ?&mut T {
	if i >= Size {
		return none
	}
	return unsafe { &mut arr.data[i] }
}

#[unsafe]
pub fn (arr &FixedArray[T, Size]) fast_get(i usize) -> T {
	return arr.data[i]
}

#[unsafe]
pub fn (arr &FixedArray[T, Size]) fast_get_ptr(i usize) -> &T {
	return unsafe { &arr.data[i] }
}

// get_or_panic returns an element at the given index or
// panics if the index is out of bounds.
//
// Example:
// ```
// mut arr := [1, 2, 3] as [3]i32
// assert arr.get_or_panic(1) == 2
// ```
#[track_caller]
pub fn (arr &FixedArray[T, Size]) get_or_panic(i usize) -> T {
	comptime if !no_bounds_checking {
		if i >= Size {
			panic("index out of bounds, index: ${i}, size: ${Size}")
		}
	}

	return arr.data[i]
}

// first returns the first element of the array.
//
// Example:
// ```
// arr := [1, 2, 3] as [3]i32
// assert arr.first() == 1
// ```
pub fn (arr &FixedArray[T, Size]) first() -> T {
	return arr.data[0]
}

// last returns the last element of the array.
//
// Example:
// ```
// arr := [1, 2, 3] as [3]i32
// assert arr.last() == 3
// ```
pub fn (arr &FixedArray[T, Size]) last() -> T {
	return arr.data[Size - 1]
}

// fill sets each element of the array to the given value.
//
// Example:
// ```
// mut arr := [1, 2, 3] as [3]i32
// arr.fill(10)
// assert arr == [10, 10, 10] as [3]i32
// ```
pub fn (arr &mut FixedArray[T, Size]) fill(val T) {
	for i in 0 .. Size {
		arr.data[i] = val
	}
}

// swap swaps the elements at the given indices in the array.
// If the indices are out of bounds, this function will panic.
//
// Example:
// ```
// mut arr := [1, 2, 3] as [3]i32
// arr.swap(0, 2)
// assert arr == [3, 2, 1] as [3]i32
// ```
#[track_caller]
pub fn (arr &mut FixedArray[T, Size]) swap(i usize, j usize) {
	comptime if !no_bounds_checking {
		if i >= Size || j >= Size {
			panic("index out of bounds, index: ${i}, size: ${Size}")
		}
	}

	mut tmp := arr.data[i]
	arr.data[i] = arr.data[j]
	arr.data[j] = tmp
}

// reverse returns a new array with elements in reverse order.
//
// To reverse the array inplace, see [`reverse_inplace`] method.
//
// Example:
// ```
// arr := [1, 2, 3] as [3]i32
// assert arr.reverse() == [3, 2, 1] as [3]i32
// ```
#[must_use("reverse returns a new array without modifying the original")]
pub fn (arr &FixedArray[T, Size]) reverse() -> FixedArray[T, Size] {
	mut res := FixedArray[T, Size]{}
	for i in 0 .. Size {
		res.data[i] = arr.data[Size - i - 1]
	}
	return res
}

// reverse_inplace reverses the array in place.
//
// To get a new array with reverse order, see [`reverse`] method.
//
// Example:
// ```
// mut arr := [1, 2, 3] as [3]i32
// arr.reverse_inplace()
// assert arr == [3, 2, 1] as [3]i32
// ```
pub fn (arr &mut FixedArray[T, Size]) reverse_inplace() {
	for i in 0 .. arr.len() / 2 {
		tmp := arr.fast_get(i)
		arr.fast_set(i, arr.fast_get(arr.len() - i - 1))
		arr.fast_set(arr.len() - i - 1, tmp)
	}
}

#[track_caller]
pub fn (arr &FixedArray[T, Size]) sub(start usize, end usize) -> []T {
	comptime if !no_bounds_checking {
		if start >= Size || end >= Size {
			panic('index out of bounds, start: ${start}, end: ${end}, len: ${Size}')
		}
		if start > end {
			panic("start index is greater than end index")
		}
	}

	mut res := []T{cap: end - start}
	for i in start .. end {
		res.push(arr.data[i])
	}
	return res
}

#[track_caller]
pub fn (arr &mut FixedArray[T, Size]) slice2(start usize, end usize, inclusive_end bool) -> []T {
	mut final_start := if start == -1 { 0 as usize } else { start }
	mut final_end := if end == -1 { Size } else { end } + inclusive_end as usize

	comptime if !no_bounds_checking {
		if final_start > Size || final_end > Size {
			end_for_error := if end == -1 { Size } else { end }
			size := Size
			panic('index out of bounds, start: ${final_start}, end: ${end_for_error}, inclusive_end: ${inclusive_end}, len: ${size}')
		}
		if final_start > final_end {
			panic("start index is greater than end index")
		}
	}

	return []T{
		data: unsafe { &mut arr.data[final_start] }
		len: final_end - final_start
		cap: final_end - final_start
	}
}

// find iterates over the elements of the array and returns the first element
// for which the provided callback function returns true. If no such element is found,
// it returns none.
//
// Example:
// ```
// arr := [1, 2, 3] as [3]i32
// assert arr.find(|el| el % 2 == 0).unwrap() == 2
// ```
pub fn (arr &FixedArray[T, Size]) find(cb fn (_ T) -> bool) -> ?T {
	for i in 0 .. Size {
		if cb(arr.data[i]) {
			return arr.data[i]
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
// arr := [1, 2, 3] as [3]i32
// assert arr.find_index(|el| el % 2 == 0).unwrap() == 1
// ```
pub fn (arr &FixedArray[T, Size]) find_index(cb fn (_ T) -> bool) -> ?usize {
	for i in 0 .. Size {
		if cb(arr.data[i]) {
			return i
		}
	}
	return none
}

pub fn (arr &FixedArray[T, Size]) for_each(cb fn (_ T)) {
	for i in 0 .. Size {
		cb(arr.data[i])
	}
}

pub fn (arr &FixedArray[T, Size]) size_in_bytes() -> usize {
	return Size * mem.size_of[T]()
}

pub fn (arr &FixedArray[T, Size]) raw() -> &T {
	return unsafe { &arr.data[0] }
}

pub fn (arr &mut FixedArray[T, Size]) mut_raw() -> &mut T {
	return unsafe { &mut arr.data[0] }
}

// contains returns `true` if the array contains the specified value.
// If the value is not found in the array, it returns `false`.
//
// Example:
// ```
// arr := [1, 2, 3, 4, 5] as [5]i32
// assert arr.contains(3) == true   // since 3 is in the array
// assert arr.contains(6) == false  // since 6 is not in the array
// ```
pub fn (arr &FixedArray[T, Size]) contains(val T) -> bool
	where T: Equality
{
	for i in 0 .. Size {
		if arr.data[i] == val {
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
// arr := [1, 2, 3, 4, 5] as [5]i32
// assert arr.index(3).unwrap() == 2   // returns index 2 where 3 is found
// assert arr.index(6) == none         // returns none since 6 is not in the array
// ```
pub fn (arr &FixedArray[T, Size]) index(val T) -> ?usize
	where T: Equality
{
	for i in 0 .. Size {
		if arr.data[i] == val {
			return i
		}
	}
	return none
}

// filter returns a new **dynamic** array that contains only the elements
// that satisfy the predicate.
//
// Example:
// ```
// arr := [1, 2, 3, 4, 5] as [5]i32
// evens := arr.filter(|el| el % 2 == 0)
// assert evens == [2, 4]
// ```
#[must_use("filter returns a new array without modifying the original")]
pub fn (arr &FixedArray[T, Size]) filter(cb fn (el T) -> bool) -> []T {
	return arr[..].filter(cb)
}

// map applies the provided callback function to each element of the array and
// returns a new array containing the results. The original array remains unmodified.
//
// Example:
// ```
// arr := [1, 2, 3] as [3]i32
// assert arr.map(|x i32| x * x) == [1, 4, 9] as [3]i32
// ```
#[must_use("map returns a new array without modifying the original")]
pub fn (arr &FixedArray[T, Size]) map[U](cb fn (el T) -> U) -> [Size]U {
	mut result := [Size]U{}
	for i, item in arr {
		// SAFETY: we always have enough memory for the new element.
		unsafe { result.fast_set(i, cb(item)) }
	}
	return result
}

// map_not_none applies the provided callback function to  element
// of the array and returns a new **dynamic** array containing the
// non-`none` results.
// The original array remains unmodified.
//
// Example:
// ```
// arr := ["10", "hello", "20"] as [3]string
// assert arr.map_not_none(|el| el.i32_opt()) == [10, 20]
// ```
#[must_use("map_not_none returns a new array without modifying the original")]
pub fn (arr &FixedArray[T, Size]) map_not_none[U](cb fn (el T) -> ?U) -> []U {
	mut result := []U{cap: Size}
	for item in arr {
		if value := cb(item) {
			// SAFETY: we always have enough memory for the new element.
			unsafe { result.fast_push(value) }
		}
	}
	return result
}

// any returns `true` if the provided callback function returns `true`
// for any element in the array. If no such element is found, it returns `false`.
//
// Example:
// ```
// arr := [1, 2, 3] as [3]i32
// assert arr.any(|el| el % 2 == 0) == true  // since 2 is even
// assert arr.any(|el| el > 5) == false      // no element is greater than 5
// ```
pub fn (arr &FixedArray[T, Size]) any(f fn (_ T) -> bool) -> bool {
	for i in 0 .. Size {
		if f(arr.data[i]) {
			return true
		}
	}
	return false
}

// all returns `true` if the provided callback function returns `true`
// for all elements in the array. If any element does not satisfy the callback function, it returns `false`.
//
// Example:
// ```
// arr := [1, 2, 3] as [3]i32
// assert arr.all(|el| el > 0) == true        // all elements are greater than 0
// assert arr.all(|el| el % 2 == 0) == false  // not all elements are even
// ```
pub fn (arr &FixedArray[T, Size]) all(f fn (_ T) -> bool) -> bool {
	for i in 0 .. Size {
		if !f(arr.data[i]) {
			return false
		}
	}
	return true
}

pub fn (arr &FixedArray[T, Size]) ascii_str() -> string
	where T: u8
{
	return string.view_from_c_str_len(arr.data as *u8, Size).clone()
}

pub fn (arr &FixedArray[T, Size]) str() -> string
	where T: Display
{
	return arr.inner_str(0)
}

pub fn (arr &FixedArray[T, Size]) inner_str(indent i32) -> string
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

		comptime if T is rune {
			result.push(b`\``)
		}

		comptime if T is string {
			result.push(b`'`)
		}

		if i as usize != Size - 1 {
			result.push(b`,`)
			result.push(b` `)
		}
	}
	result.push(b`]`)

	return string.view_from_bytes(result)
}

pub fn (arr &FixedArray[T, Size]) debug_str() -> string
	where T: Debug
{
	mut parts := [Size]string{}
	for i in 0 .. Size {
		parts[i] = arr.data[i].debug_str()
	}

	mut len := 2 as usize
	for i in 0 .. Size {
		len = len + parts[i].len
		if i as usize != arr.len() - 1 {
			len += 2
		}
	}

	mut result := []u8{len: len + 1}
	mut pos := 1 as usize
	result[0] = b`[`
	for i in 0 .. Size {
		s := parts[i]
		mem.fast_copy(result.mut_raw() + pos, s.data, s.len)
		pos += s.len

		if i as usize != arr.len() - 1 {
			result[pos] = b`,`
			result[pos + 1] = b` `
			pos += 2
		}
	}
	result[len - 1] = b`]`
	result[len] = 0
	return string.view_from_bytes(result)
}

pub fn (arr &FixedArray[T, Size]) iter() -> FixedArrayIter[T, Size] {
	return FixedArrayIter[T, Size]{
		arr: arr
		i: 0
	}
}

pub struct FixedArrayIter[T, const Size as usize] {
	arr &FixedArray[T, Size]
	i   usize
}

pub fn (iter &mut FixedArrayIter[T, Size]) next() -> ?T {
	if iter.i >= iter.arr.len() {
		return none
	}
	res := iter.arr.get(iter.i)
	iter.i++
	return res
}
