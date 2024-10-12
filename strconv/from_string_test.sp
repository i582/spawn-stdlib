module main

import strconv

test "parse_int for decimal numbers" {
	cases := [
		("", none as ?i64),
		("0", opt(0 as i64)),
		("-0", opt(0 as i64)),
		("1", opt(1 as i64)),
		("-1", opt(-1 as i64)),
		("2", opt(2 as i64)),
		("9223372036854775807", opt(MAX_I64)),
		// ("-9223372036854775808", opt(MIN_I64)), // TODO
		("hello", none as ?i64),
		("-hello", none as ?i64),
		("  10", none as ?i64),
		("10.5", opt(10 as i64)),
	]

	for case in cases {
		str, expected := case
		t.assert_eq(strconv.parse_int(str, 10), expected, 'actual value should be equal to expected')
	}

	opt(1) == opt(2)
}
