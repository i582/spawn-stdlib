module main

test "fixed array creation via [4]i32{}" {
	arr := [4]i32{}
	t.assert_eq(arr.len(), 4, "len should be 4")
	t.assert_eq(arr[0], 0, "arr[0] should be 0")
	t.assert_eq(arr[3], 0, "arr[3] should be 0")
}

test "fixed array creation via [4]i32{} with init" {
	arr := [4]i32{init: || 10}
	t.assert_eq(arr.len(), 4, "len should be 4")
	t.assert_eq(arr[0], 10, "arr[0] should be 10")
	t.assert_eq(arr[3], 10, "arr[3] should be 10")
}

test "fixed array creation via [4]usize{} with init with index" {
	arr := [4]usize{init: |index| index * 2}
	t.assert_eq(arr.len(), 4, "len should be 4")
	t.assert_eq(arr[0], 0, "arr[0] should be 0")
	t.assert_eq(arr[3], 6, "arr[3] should be 6")
}

test "fixed array creation" {
	arr := [1, 2, 3, 4] as [4]i32
	t.assert_eq(arr.len(), 4, "len should be 4")
	t.assert_eq(arr[0], 1, "arr[0] should be 1")
	t.assert_eq(arr[3], 4, "arr[3] should be 4")
}

test "fixed array element access" {
	arr := [10, 20, 30, 40, 50] as [5]i32
	t.assert_eq(arr[0], 10, "arr[0] should be 10")
	t.assert_eq(arr[2], 30, "arr[2] should be 30")
	t.assert_eq(arr[4], 50, "arr[4] should be 50")
}

#[must_panic]
test "fixed array element access out of bounds" {
	arr := [10, 20, 30, 40, 50] as [5]i32
	index := 100
	t.assert_eq(arr[index], 10, "arr[0] should be 10")
}

test "fixed array element assignment" {
	mut arr := [0, 0, 0, 0, 0] as [5]i32
	arr[1] = 11
	arr[3] = 33

	t.assert_eq(arr[1], 11, "arr[1] should be 11")
	t.assert_eq(arr[3], 33, "arr[3] should be 33")
}

test "sum elements of fixed array" {
	arr := [1, 2, 3, 4, 5] as [5]i32
	mut sum := 0

	for el in arr {
		sum += el
	}

	t.assert_eq(sum, 15, "sum should be 15")
}

test "fixed array first element" {
	arr := [1, 2, 3] as [3]i32
	t.assert_eq(arr.first(), 1, "first element should be 1")
}

test "fixed array last element" {
	arr := [1, 2, 3] as [3]i32
	t.assert_eq(arr.last(), 3, "last element should be 3")
}

test "fixed array fill" {
	mut arr := [1, 2, 3] as [3]i32
	arr.fill(10)
	t.assert_eq(arr.str(), [10, 10, 10].str(), "all elements should be 10")
}

test "fixed array swap elements" {
	mut arr := [1, 2, 3] as [3]i32
	arr.swap(0, 2)
	t.assert_eq(arr.str(), [3, 2, 1].str(), "array should be [3, 2, 1] after swap")
}

#[must_panic]
test "fixed array swap elements out of bounds" {
	mut arr := [1, 2, 3] as [3]i32
	arr.swap(0, 3)
}

test "fixed array reverse" {
	arr := [1, 2, 3] as [3]i32
	reversed := arr.reverse()
	t.assert_eq(reversed.str(), [3, 2, 1].str(), "reversed array should be [3, 2, 1]")
	t.assert_eq(arr.str(), [1, 2, 3].str(), "original array should remain unchanged")
}

test "fixed array reverse inplace" {
	mut arr := [1, 2, 3] as [3]i32
	arr.reverse_inplace()
	t.assert_eq(arr.str(), [3, 2, 1].str(), "array should be [3, 2, 1] after reverse_inplace")
}

test "fixed array reverse single element" {
	arr := [42] as [1]i32
	reversed := arr.reverse()
	t.assert_eq(reversed.str(), [42].str(), "reversed single element array should be [42]")
}

test "fixed array reverse inplace single element" {
	mut arr := [42] as [1]i32
	arr.reverse_inplace()
	t.assert_eq(arr.str(), [42].str(), "inplace reverse single element array should be [42]")
}

test "fixed array find element" {
	arr := [1, 2, 3, 4, 5] as [5]i32
	t.assert_eq(arr.find(|el| el % 2 == 0).unwrap(), 2, "should find the first even number (2)")
	t.assert_eq(arr.find(|el| el > 3).unwrap(), 4, "should find the first number greater than 3 (4)")
	t.assert_none(arr.find(|el| el == 10), "should return none for element not found")
}

test "fixed array find_index element" {
	arr := [1, 2, 3, 4, 5] as [5]i32
	t.assert_eq(arr.find_index(|el| el % 2 == 0).unwrap(), 1, "should find the index of first even number (1)")
	t.assert_eq(arr.find_index(|el| el > 3).unwrap(), 3, "should find the index of first number greater than 3 (3)")
	t.assert_none(arr.find_index(|el| el == 10), "should return none for index not found")
}

test "fixed array any method" {
	arr := [1, 2, 3, 4, 5] as [5]i32
	t.assert_true(arr.any(|el| el % 2 == 0), "should return true if any element is even")
	t.assert_true(arr.any(|el| el > 4), "should return true if any element is greater than 4")
	t.assert_false(arr.any(|el| el > 5), "should return false if no element is greater than 5")
}

test "fixed array all method" {
	arr := [2, 4, 6, 8, 10] as [5]i32
	t.assert_true(arr.all(|el| el % 2 == 0), "should return true if all elements are even")
	t.assert_false(arr.all(|el| el > 5), "should return false if not all elements are greater than 5")
}

test "fixed array contains method" {
	arr := [1, 2, 3, 4, 5] as [5]i32
	t.assert_eq(arr.contains(3), true, "should return true if the array contains 3")
	t.assert_eq(arr.contains(6), false, "should return false if the array does not contain 6")
}

test "fixed array index method" {
	arr := [1, 2, 3, 4, 5] as [5]i32
	t.assert_eq(arr.index(3).unwrap(), 2, "should return index 2 for value 3")
	t.assert_none(arr.index(6), "should return none if the value 6 is not in the array")
}

test "fixed array index method first occurrence" {
	arr := [1, 2, 3, 2, 1] as [5]i32
	t.assert_eq(arr.index(2).unwrap(), 1, "should return the index of the first occurrence of 2")
}

test "filter of fixed array" {
	arr := [1, 2, 3, 4, 5] as [5]i32
	filtered := arr.filter(|el| el > 2)

	t.assert_eq(filtered.str(), [3, 4, 5].str(), 'actual should be equal to expected')
}

test "fixed array map method" {
	arr := [1, 2, 3] as [3]i32
	squared := arr.map(|x| x * x)
	t.assert_eq(squared.str(), [1, 4, 9].str(), "should return a new array with squared values")

	// Ensure original array is unchanged
	t.assert_eq(arr.str(), [1, 2, 3].str(), "original array should remain unmodified")
}

test "fixed array map method with string" {
	arr := ["a", "b", "c"] as [3]string
	uppercased := arr.map(|x| x.to_upper())
	t.assert_eq(uppercased.str(), ["A", "B", "C"].str(), "should return a new array with uppercased strings")
}

test "fixed array map_not_none method" {
	arr := ["10", "hello", "20"] as [3]string
	result := arr.map_not_none(|el| el.i32_opt())
	t.assert_eq(result.str(), [10, 20].str(), "should return a new array with non-`none` results")

	// Ensure original array is unchanged
	t.assert_eq(arr.str(), ["10", "hello", "20"].str(), "original array should remain unmodified")
}

test "fixed array map_not_none method with empty result" {
	arr := ["hello", "world"] as [2]string
	result := arr.map_not_none(|el string| none as ?i32)
	t.assert_eq(result.str(), []i32{}.str(), "should return an empty array if all results are `none`")
}
