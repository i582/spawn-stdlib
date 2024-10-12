module main

test "new array" {
	arr := []i32{}
	t.assert_eq(arr.len, 0, "len should be 0")
	t.assert_eq(arr.cap, 0, "cap should be 0")
}

test "new array with len" {
	arr := []i32{len: 100}
	t.assert_eq(arr.len, 100, "len should be 100")
	t.assert_eq(arr.cap, 100, "cap should be 100")
}

test "new array with cap" {
	arr := []i32{len: 100, cap: 200}
	t.assert_eq(arr.len, 100, "len should be 100")
	t.assert_eq(arr.cap, 200, "cap should be 200")
}

test "push single element" {
	mut arr := []i32{}
	arr.push(1)

	t.assert_eq(arr.len, 1, "len should be 1")
	t.assert_eq(arr.cap, 2, "cap should be 2")

	t.assert_eq(arr[0], 1, "arr[0] should be 1")
}

test "push two elements" {
	mut arr := []i32{}
	arr.push(1)
	arr.push(2)

	t.assert_eq(arr.len, 2, "len should be 2")
	t.assert_eq(arr.cap, 2, "cap should be 2")

	t.assert_eq(arr[0], 1, "arr[0] should be 1")
	t.assert_eq(arr[1], 2, "arr[1] should be 2")
}

test "reallocation after push" {
	mut arr := []i32{len: 2, cap: 2}
	arr.push(1)

	t.assert_eq(arr.len, 3, "len should be 3")
	t.assert_eq(arr.cap, 4, "cap should be 4")
}

test "push within capacity with no more capacity" {
	mut arr := []i32{cap: 2}
	arr.push(1)
	arr.push(2)

	arr.push_within_capacity(3) or {
		// t.assert_eq(err.msg(), 'array is full, len: 2, cap: 2', 'error message should be correct')
		return
	}
	t.fail("should not be able to push within capacity")
}

test "remove element from array" {
	cases := [
		([1, 2, 3], 0, [2, 3]),
		([1, 2, 3], 1, [1, 3]),
		([1, 2, 3], 2, [1, 2]),
	]

	for case in cases {
		mut arr, index, expected := case
		arr.remove(index)
		t.assert_eq(arr.str(), expected.str(), "arr should be ${expected}")
	}
}

#[must_panic]
test "remove wrong element from array" {
	mut arr := [1, 2, 3]
	arr.remove(10)
}

test "swap remove element from array" {
	cases := [
		([1, 2, 3], 0, [3, 2]),
		([1, 2, 3], 1, [1, 3]),
		([1, 2, 3], 2, [1, 2]),
	]

	for case in cases {
		mut arr, index, expected := case
		arr.swap_remove(index)
		t.assert_eq(arr.str(), expected.str(), "arr should be ${expected}")
	}
}

#[must_panic]
test "swap remove wrong element from array" {
	mut arr := [1, 2, 3]
	arr.swap_remove(10)
}

test "swap two elements" {
	cases := [
		([1, 2, 3], 0, 0, [1, 2, 3]),
		([1, 2, 3], 0, 1, [2, 1, 3]),
		([1, 2, 3], 1, 2, [1, 3, 2]),
		([1, 2, 3], 2, 1, [1, 3, 2]),
	]

	for case in cases {
		mut arr, index1, index2, expected := case
		arr.swap(index1, index2)
		t.assert_eq(arr.str(), expected.str(), "arr should be ${expected}")
	}
}

test "copy from other array" {
	cases := [
		([1, 2, 3], [4, 5, 6], [4, 5, 6]),
		([1, 2, 3], [4, 5], [4, 5, 3]),
		([1, 2], [4, 5, 6], [4, 5]),
	]

	for case in cases {
		mut arr, other, expected := case
		arr.copy_from(other)
		t.assert_eq(arr.str(), expected.str(), "arr should be ${expected}")
	}
}

test "reverse i32 array" {
	cases := [
		([1, 2, 3], [3, 2, 1]),
		([1, 2, 3, 4], [4, 3, 2, 1]),
	]

	for case in cases {
		arr, expected := case
		new_arr := arr.reverse()
		t.assert_eq(new_arr.str(), expected.str(), "arr should be ${expected}")
	}
}

test "reverse string array" {
	cases := [
		(["a", "b", "c"], ["c", "b", "a"]),
		(["a", "b", "c", "d"], ["d", "c", "b", "a"]),
	]

	for case in cases {
		arr, expected := case
		new_arr := arr.reverse()
		t.assert_eq(new_arr.str(), expected.str(), "arr should be ${expected}")
	}
}

test "reverse inplace i32 array" {
	cases := [
		([1, 2, 3], [3, 2, 1]),
		([1, 2, 3, 4], [4, 3, 2, 1]),
	]

	for case in cases {
		mut arr, expected := case
		arr.reverse_inplace()
		t.assert_eq(arr.str(), expected.str(), "arr should be ${expected}")
	}
}

test "reverse inplace string array" {
	cases := [
		(["a", "b", "c"], ["c", "b", "a"]),
		(["a", "b", "c", "d"], ["d", "c", "b", "a"]),
	]

	for case in cases {
		mut arr, expected := case
		arr.reverse_inplace()
		t.assert_eq(arr.str(), expected.str(), "arr should be ${expected}")
	}
}

test "concat two i32 arrays" {
	cases := [
		([1, 2, 3], [4, 5, 6], [1, 2, 3, 4, 5, 6]),
		([1, 2, 3], [4, 5], [1, 2, 3, 4, 5]),
		([1, 2], [4, 5, 6], [1, 2, 4, 5, 6]),
	]

	for case in cases {
		arr1, arr2, expected := case
		new_arr := arr1.add(arr2)
		t.assert_eq(new_arr.str(), expected.str(), "arr should be ${expected}")
	}
}

test "concat two i32 arrays via +" {
	cases := [
		([1, 2, 3], [4, 5, 6], [1, 2, 3, 4, 5, 6]),
		([1, 2, 3], [4, 5], [1, 2, 3, 4, 5]),
		([1, 2], [4, 5, 6], [1, 2, 4, 5, 6]),
	]

	for case in cases {
		arr1, arr2, expected := case
		new_arr := arr1 + arr2
		t.assert_eq(new_arr.str(), expected.str(), "arr should be ${expected}")
	}
}

test "partition of i32 array" {
	less_than_5 := |el i32| el < 5
	is_odd := |el i32| el % 2 == 1

	cases := [
		([1, 2, 3, 4, 5, 6], less_than_5, [1, 2, 3, 4], [5, 6]),
		([1, 2, 3, 4, 5, 6], is_odd, [1, 3, 5], [2, 4, 6]),
	]

	for case in cases {
		arr, predicate, expected_first, expected_second := case
		first, second := arr.partition(predicate)
		t.assert_eq(first.str(), expected_first.str(), "first should be ${expected_first}")
		t.assert_eq(second.str(), expected_second.str(), "second should be ${expected_second}")
	}
}

test "map of i32 array" {
	to_hex_str := |el i32| el.hex_prefixed()
	mul_2 := |el i32| (el * 2).str()

	cases := [
		([1, 2, 3, 4, 5, 6], to_hex_str, ["0x1", "0x2", "0x3", "0x4", "0x5", "0x6"]),
		([1, 2, 3, 4, 5, 6], mul_2, ["2", "4", "6", "8", "10", "12"]),
	]

	for case in cases {
		arr, mapper, expected := case
		new_arr := arr.map(mapper)
		t.assert_eq(new_arr.str(), expected.str(), "new_arr should be ${expected}")
	}
}

test "map_not_none of string array" {
	nums := ["1", "2", "3", "a", "4", "aaaa5", "6"]
	real_nums := nums.map_not_none(|el| el.parse_int())
	t.assert_eq(real_nums.str(), [1, 2, 3, 4, 6].str(), "real_nums should be [1, 2, 3, 4, 6]")
}

test "filter of i32 array" {
	cases := [
		([1, 2, 3, 4, 5, 6], |el i32| el < 5, [1, 2, 3, 4]),
		([1, 2, 3, 4, 5, 6], |el i32| el % 2 == 1, [1, 3, 5]),
	]

	for case in cases {
		arr, predicate, expected := case
		new_arr := arr.filter(predicate)
		t.assert_eq(new_arr.str(), expected.str(), "new_arr should be ${expected}")
	}
}

test "reduce of i32 array" {
	sum := |acc i32, el i32| acc + el
	mul := |acc i32, el i32| acc * el

	cases := [
		([1, 2, 3, 4, 5, 6], 0, sum, 21),
		([1, 2, 3, 4, 5, 6], 1, mul, 720),
	]

	for case in cases {
		arr, init, reducer, expected := case
		result := arr.reduce(init, reducer)
		t.assert_eq(result, expected, "result should be ${expected}")
	}
}

test "find in i32 array" {
	cases := [
		([1, 2, 3, 4, 5, 6], |el i32| el == 3, opt(3)),
		([1, 2, 3, 4, 5, 6], |el i32| el == 10, none as ?i32),
	]

	for case in cases {
		arr, predicate, expected := case
		result := arr.find(predicate)
		t.assert_eq(result.str(), expected.str(), "result should be ${expected}")
	}
}

test "find index in i32 array" {
	cases := [
		([1, 2, 3, 4, 5, 6], |el i32| el == 3, opt(2)),
		([1, 2, 3, 4, 5, 6], |el i32| el == 10, none as ?i32),
	]

	for case in cases {
		arr, predicate, expected := case
		result := arr.find_index(predicate)
		t.assert_eq(result.str(), expected.str(), "result should be ${expected}")
	}
}

test "any for i32 array" {
	cases := [
		([1, 2, 3, 4, 5, 6], |el i32| el == 3, true),
		([1, 2, 3, 4, 5, 6], |el i32| el == 10, false),
	]

	for case in cases {
		arr, predicate, expected := case
		result := arr.any(predicate)
		t.assert_eq(result, expected, "result should be ${expected}")
	}
}

test "all for i32 array" {
	cases := [
		([1, 2, 3, 4, 5, 6], |el i32| el < 10, true),
		([1, 2, 3, 4, 5, 6], |el i32| el < 5, false),
	]

	for case in cases {
		arr, predicate, expected := case
		result := arr.all(predicate)
		t.assert_eq(result, expected, "result should be ${expected}")
	}
}

test "group_by for i32 array" {
	is_odd := |el i32| el % 2 == 1
	more_than_3 := |el i32| el > 3

	cases := [
		([1, 2, 3, 4, 5, 6], is_odd, { true: [1, 3, 5], false: [2, 4, 6] }),
		([1, 2, 3, 4, 5, 6], more_than_3, { true: [4, 5, 6], false: [1, 2, 3] }),
	]

	for case in cases {
		arr, grouper, expected := case
		result := arr.group_by(grouper)
		t.assert_eq(result.str(), expected.str(), "result should be ${expected}")
	}
}

test "to_mao for i32 array" {
	cases := [
		([1, 2, 3, 4, 5, 6], |el i32| el % 2 == 0, { false: 5, true: 6 }),
		([1, 2, 3, 4, 5, 6], |el i32| el % 2 == 1, { false: 6, true: 5 }),
	]

	for case in cases {
		arr, grouper, expected := case
		result := arr.to_map(grouper)
		t.assert_eq(result.str(), expected.str(), "result should be ${expected}")
	}
}

struct ZipPerson {
	name string
}

test "zip Person and i32 arrays" {
	persons := [ZipPerson{ name: "Alice" }, ZipPerson{ name: "Bob" }, ZipPerson{ name: "Charlie" }]
	ages := [20, 30, 40]

	expected := [
		(ZipPerson{ name: "Alice" }, 20),
		(ZipPerson{ name: "Bob" }, 30),
		(ZipPerson{ name: "Charlie" }, 40),
	]

	result := persons.zip(ages)
	t.assert_eq(result.str(), expected.str(), "result should be ${expected}")
}

test "split once for string array" {
	cases := [
		(['--flag', 'value', '--', '--flag2', 'value2'], |el string| el == '--', ['--flag', 'value'], ['--flag2', 'value2']),
		(['--flag', 'value', '--', '--flag2', 'value2'], |el string| el == 'value', ['--flag'], ['--', '--flag2', 'value2']),
		(['--flag', 'value', '--', '--flag2', 'value2'], |el string| el == '--flag', []string{}, ['value', '--', '--flag2', 'value2']),
		(['--flag', 'value', '--', '--flag2', 'value2'], |el string| el == 'value2', ['--flag', 'value', '--', '--flag2'], []string{}),
		(['--flag', 'value', '--', '--flag2', 'value2'], |el string| el == 'bla bla bla', ['--flag', 'value', '--', '--flag2', 'value2'], []string{}),
	]

	for case in cases {
		arr, predicate, expected_first, expected_second := case
		first, second := arr.split_once(predicate)
		t.assert_eq(first.str(), expected_first.str(), "first should be ${expected_first}")
		t.assert_eq(second.str(), expected_second.str(), "second should be ${expected_second}")
	}
}

test "min for i32 array" {
	arr := [1, 2, 3, 4, 5, 6]
	result := arr.min().unwrap()

	t.assert_eq(result, 1, "result should be 1")
}

test "min for empty i32 array" {
	arr := []i32{}
	result := arr.min()

	t.assert_none(result, "result should be none")
}

test "max for i32 array" {
	arr := [1, 2, 3, 4, 5, 6]
	result := arr.max().unwrap()

	t.assert_eq(result, 6, "result should be 6")
}

test "max for empty i32 array" {
	arr := []i32{}
	result := arr.max()

	t.assert_none(result, "result should be none")
}

test "push_fixed method for i32 array" {
	mut arr := [1, 2, 3]
	fixed := [4, 5, 6] as [3]i32
	arr.push_fixed(fixed, 2)
	t.assert_eq(arr.str(), [1, 2, 3, 4, 5].str(), "actual value should be equal to expected")
}

test "push_fixed method for i32 array with len > fixed array len" {
	mut arr := [1, 2, 3]
	fixed := [4, 5, 6] as [3]i32
	arr.push_fixed(fixed, 999)
	t.assert_eq(arr.str(), [1, 2, 3, 4, 5, 6].str(), "actual value should be equal to expected")
}

test "push_fixed method for string array with len > fixed array len" {
	mut arr := ["hello"]
	fixed := ["world", "!"] as [2]string
	arr.push_fixed(fixed, 5)
	t.assert_eq(arr.str(), ["hello", "world", "!"].str(), "actual value should be equal to expected")
}
