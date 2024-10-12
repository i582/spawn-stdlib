module main

import strings

test "max_common_prefix function" {
	cases := [
		(['foo', 'foobar', 'foobaz'], 'foo'),
		(['foo', 'bar', 'baz'], ''),
		(['foo', 'foobar', 'baz'], ''),
		(['foo', 'foo', 'foo'], 'foo'),
		(['foo', 'foo', 'foobar'], 'foo'),
	]

	for case in cases {
		input, expected := case
		actual := strings.max_common_prefix(input)
		t.assert_eq(actual, expected, 'actual should be equal to expected')
	}
}
