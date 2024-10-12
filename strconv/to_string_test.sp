module main

import strconv

test "int_to_str for i64" {
	cases := [
		(1 as i64, '1'),
		(0 as i64, '0'),
		(-1 as i64, '-1'),
		(1234567890 as i64, '1234567890'),
		(-1234567890 as i64, '-1234567890'),
		(MAX_I64, '9223372036854775807'),
		(MIN_I64, '-9223372036854775808'),
	]

	for case in cases {
		i, expected := case
		result := strconv.int_to_str(i, 25)
		t.assert_eq(result, expected, 'actual should be equal to expected')
	}
}

test "int_to_str for i64 with trim" {
	cases := [
		(1 as i64, 1, '1'),
		(0 as i64, 1, '0'),
		(-1 as i64, 1, '-1'),
		(1234567890 as i64, 5, '12345'),
		(-1234567890 as i64, 5, '-12345'),
	]

	for case in cases {
		i, count_digits, expected := case
		result := strconv.int_to_str(i, count_digits)
		t.assert_eq(result, expected, 'actual should be equal to expected')
	}
}

test "int_to_hex for i64" {
	cases := [
		(1 as i64, '0x1'),
		(0 as i64, '0x0'),
		(-1 as i64, '-0x1'),
		(1234567890 as i64, '0x499602d2'),
		(-1234567890 as i64, '-0x499602d2'),
		(MAX_I64, '0x7fffffffffffffff'),
		(MIN_I64, '-0x8000000000000000'),
	]

	for case in cases {
		i, expected := case
		result := strconv.int_to_hex(i, 25, true)
		t.assert_eq(result, expected, 'actual should be equal to expected')
	}
}

test "int_to_hex for i64 with trim" {
	cases := [
		(1 as i64, 1, '0x1'),
		(0 as i64, 1, '0x0'),
		(-1 as i64, 1, '-0x1'),
		(1234567890 as i64, 5, '0x49960'),
		(-1234567890 as i64, 5, '-0x49960'),
		(MAX_I64, 5, '0x7ffff'),
		(MIN_I64, 5, '-0x80000'),
	]

	for case in cases {
		i, count_digits, expected := case
		result := strconv.int_to_hex(i, count_digits, true)
		t.assert_eq(result, expected, 'actual should be equal to expected')
	}
}

test "uint_to_str for u64" {
	cases := [
		(1 as u64, '1'),
		(0 as u64, '0'),
		(1234567890 as u64, '1234567890'),
		(MAX_U64, '18446744073709551615'),
	]

	for case in cases {
		i, expected := case
		result := strconv.uint_to_str(i, 25)
		t.assert_eq(result, expected, 'actual should be equal to expected')
	}
}

test "uint_to_str for u64 with trim" {
	cases := [
		(1 as u64, 1, '1'),
		(0 as u64, 1, '0'),
		(1234567890 as u64, 5, '12345'),
		(MAX_U64, 5, '18446'),
	]

	for case in cases {
		i, count_digits, expected := case
		result := strconv.uint_to_str(i, count_digits)
		t.assert_eq(result, expected, 'actual should be equal to expected')
	}
}

test "uint_to_hex for u64" {
	cases := [
		(1 as u64, '0x1'),
		(0 as u64, '0x0'),
		(1234567890 as u64, '0x499602d2'),
		(MAX_U64, '0xffffffffffffffff'),
	]

	for case in cases {
		i, expected := case
		result := strconv.uint_to_hex(i, 25, true)
		t.assert_eq(result, expected, 'actual should be equal to expected')
	}
}

test "uint_to_hex for u64 with trim" {
	cases := [
		(1 as u64, 1, '0x1'),
		(0 as u64, 1, '0x0'),
		(1234567890 as u64, 4, '0x4996'),
		(MAX_U64, 5, '0xfffff'),
	]

	for case in cases {
		i, count_digits, expected := case
		result := strconv.uint_to_hex(i, count_digits, true)
		t.assert_eq(result, expected, 'actual should be equal to expected')
	}
}
