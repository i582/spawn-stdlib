module main

test "split_nth with empty delimiter" {
	cases := [
		('1:2:3:4', 1, ['1:2:3:4']),
		('1:2:3:4', 2, ['1', ':2:3:4']),
		('1:2:3:4', 3, ['1', ':', '2:3:4']),
		('1:2:3:4', 4, ['1', ':', '2', ':3:4']),
		('1:2:3:4', 5, ['1', ':', '2', ':', '3:4']),
	]

	for case in cases {
		input, n, expected := case
		t.assert_eq(input.split_nth('', n).str(), expected.str(), "results must be equal")
	}
}

test "split_nth with single byte delimiter" {
	cases := [
		('1:2:3:4', ':', 1, ['1:2:3:4']),
		('1:2:3:4', ':', 2, ['1', '2:3:4']),
		('1:2:3:4', ':', 3, ['1', '2', '3:4']),
		('1:2:3:4', ':', 4, ['1', '2', '3', '4']),
		('1:2:3:4', ':', 5, ['1', '2', '3', '4']),
	]

	for case in cases {
		input, delimeter, n, expected := case
		t.assert_eq(input.split_nth(delimeter, n).str(), expected.str(), "results must be equal")
	}
}

test "split_nth with several bytes delimiter" {
	cases := [
		('1::2::3::4', '::', 1, ['1::2::3::4']),
		('1::2::3::4', '::', 2, ['1', '2::3::4']),
		('1::2::3::4', '::', 3, ['1', '2', '3::4']),
		('1::2::3::4', '::', 4, ['1', '2', '3', '4']),
		('1::2::3::4', '::', 5, ['1', '2', '3', '4']),
	]

	for case in cases {
		input, delimeter, n, expected := case
		t.assert_eq(input.split_nth(delimeter, n).str(), expected.str(), "results must be equal")
	}
}

test "+= for string" {
	// In this test we check that we don't mutate the original string data
	// since it's prohibited by the language specification
	mut a := "hello"
	mut b := a.data
	a += " world"
	t.assert_eq(a, "hello world", "actual result should be equal to expected")
	prev_string_data := string.view_from_c_str(b)
	t.assert_eq(prev_string_data, "hello", "previous string data should not be changed")
}

test "cmp method" {
	cases := [
		('a', 'a', Ordering.equal),
		('a', 'b', Ordering.less),
		('b', 'a', Ordering.greater),
		('a', 'aa', Ordering.less),
		('aa', 'a', Ordering.greater),
		('aa', 'aa', Ordering.equal),
	]

	for case in cases {
		a, b, expected := case
		t.assert_eq(a.cmp(b), expected, "results must be equal")
	}
}

test "cmp_ignore_case method" {
	cases := [
		('a', 'a', Ordering.equal),
		('a', 'b', Ordering.less),
		('b', 'a', Ordering.greater),
		('a', 'aa', Ordering.less),
		('aa', 'a', Ordering.greater),
		('aa', 'aa', Ordering.equal),
		('a', 'A', Ordering.equal),
		('A', 'a', Ordering.equal),
		('A', 'B', Ordering.less),
		('B', 'A', Ordering.greater),
		('A', 'AA', Ordering.less),
		('AA', 'A', Ordering.greater),
		('AA', 'AA', Ordering.equal),
	]

	for case in cases {
		a, b, expected := case
		t.assert_eq(a.cmp_ignore_case(b), expected, "results must be equal")
	}

	cases2 := [
		('A', 'b'),
		('A', 'aa'),
		('AA', 'a'),
		('AA', 'aa'),
		('a', 'B'),
		('a', 'AA'),
		('aa', 'A'),
		('aa', 'AA'),
	]

	for case in cases2 {
		a, b := case
		a_lower, b_lower := a.to_lower(), b.to_lower()
		actual := a_lower.cmp_ignore_case(b_lower)
		expected := a.cmp_ignore_case(b)
		t.assert_eq(actual, expected, "results must be equal")
	}
}

test "rune_at method" {
	cases := [
		("hello", 0, opt(`h`)), // First character
		("hello", 1, opt(`e`)), // Second character
		("hello", 4, opt(`o`)), // Last character
		("hello", 5, none as ?rune), // Out of bounds
		("привет", 0, opt(`п`)), // First character
		("héllò", 0, opt(`h`)), // First character
		("héllò", 1, opt(`é`)), // Multibyte character
		("héllò", 4, opt(`ò`)), // Multibyte character
		("héllò", 5, none as ?rune), // Out of bounds
		("こんにちは", 0, opt(`こ`)), // Multibyte character
		("こんにちは", 1, opt(`ん`)), // Multibyte character
		("こんにちは", 4, opt(`は`)), // Multibyte character
		("こんにちは", 5, none as ?rune), // Out of bounds
		("hεllo", 0, opt(`h`)), // ASCII character
		("hεllo", 1, opt(`ε`)), // Multibyte character
		("hεllo", 2, opt(`l`)), // ASCII character
		("hεllo", 4, opt(`o`)), // ASCII character
		("hεllo", 5, none as ?rune), // Out of bounds
		("", 0, none as ?rune), // Out of bounds
		("", 1, none as ?rune), // Out of bounds
		("a", 0, opt(`a`)), // Single ASCII character
		("a", 1, none as ?rune), // Out of bounds
		("Δ", 0, opt(`Δ`)), // Single multibyte character
		("Δ", 1, none as ?rune), // Out of bounds
	]

	for case in cases {
		s, index, expected := case
		actual := s.rune_at(index)
		t.assert_eq(actual, expected, "rune_at(${index}) should be ${expected} for string '${s}'")
	}

	if opt(1) == opt(2) {}
}

test "trim_ident method" {
	simple_cases := [
		('', ''), // empty string
		('   \t', ''), // blank string
		('\n	\t\n', ''), // multiline blank string
		('abc\ndef', 'abc\ndef'), // zero indentation
	]

	for case in simple_cases {
		a, expected := case
		t.assert_eq(a.trim_indent(), expected, "actual value should be equal to expected")
	}

	// zero indentation and blank first and last lines
	t.assert_eq('
abc
def
'.trim_indent(), 'abc\ndef', 'actual value should be equal to expected')

	// common case, tabbed
	t.assert_eq('
		abc
		def
	'.trim_indent(), 'abc\ndef', 'actual value should be equal to expected')

	// common case, spaces
	t.assert_eq('
        abc
        def
	'.trim_indent(), 'abc\ndef', 'actual value should be equal to expected')

	// common case, tabbed with middle blank line
	t.assert_eq('
		abc

		def
	'.trim_indent(), 'abc\n\ndef', 'actual value should be equal to expected')

	// common case, tabbed with blank first line
	t.assert_eq('    \t
		abc
		def
	'.trim_indent(), 'abc\ndef', 'actual value should be equal to expected')

	// common case, tabbed with blank first and last lines
	t.assert_eq('    \t
		abc
		def
    \t	'.trim_indent(), 'abc\ndef', 'actual value should be equal to expected')

	// html
	t.assert_eq('
		<!doctype html>
		<html lang="en">
		<head>
		</head>
		<body>
			<p>
				Hello, World!
			</p>
		</body>
		</html>
	'.trim_indent(), '<!doctype html>
<html lang="en">
<head>
</head>
<body>
	<p>
		Hello, World!
	</p>
</body>
</html>', 'actual value should be equal to expected')

	// broken html
	t.assert_eq('
		<!doctype html>
		<html lang="en">
		<head>
		</head>
	<body>
			<p>
				Hello, World!
			</p>
		</body>
		</html>
	'.trim_indent(), '	<!doctype html>
	<html lang="en">
	<head>
	</head>
<body>
		<p>
			Hello, World!
		</p>
	</body>
	</html>', 'actual value should be equal to expected')

	// method documentation case
	t.assert_eq('
     Hello there,
     this is a string,
     all the leading indents are removed
     and also the first and the last lines if they are blank
'.trim_indent(), 'Hello there,
this is a string,
all the leading indents are removed
and also the first and the last lines if they are blank', 'actual value should be equal to expected')
}

test "string to_wide conversion" {
	cases := [
		("a", [0x61 as u16]),
		("Ы", [0x042B as u16]),
		("日", [0x65E5 as u16]),
		("💖", [0xD83D as u16, 0xDC96]),
		("€", [0x20AC as u16]),
		("\n", [0x000A as u16]),
		("©", [0x00A9 as u16]),
		("𐍈", [0xD800 as u16, 0xDF48]),
		("Δ", [0x0394 as u16]),
		("ı", [0x0131 as u16]),
		("𠀀", [0xD840 as u16, 0xDC00]),
		("👋", [0xD83D as u16, 0xDC4B]),
		("⠤", [0x2824 as u16]),
		("々", [0x3005 as u16]),
	]

	for case in cases {
		s, expected_wide := case
		wide := s.to_wide()
		t.assert_eq(Array.from_ptr(wide, expected_wide.len).str(), expected_wide.str(), "wide representation should be equal to expected for ${s}")
	}
}

test "string from_wide conversion" {
	cases := [
		([0x61 as u16, 0], "a"),
		([0x042B as u16, 0], "Ы"),
		([0x65E5 as u16, 0], "日"),
		([0xD83D as u16, 0xDC96, 0], "💖"),
		([0x20AC as u16, 0], "€"),
		([0x000A as u16, 0], "\n"),
		([0x00A9 as u16, 0], "©"),
		([0xD800 as u16, 0xDF48, 0], "𐍈"),
		([0x0394 as u16, 0], "Δ"),
		([0x0131 as u16, 0], "ı"),
		([0xD840 as u16, 0xDC00, 0], "𠀀"),
		([0xD83D as u16, 0xDC4B, 0], "👋"),
		([0x2824 as u16, 0], "⠤"),
		([0x3005 as u16, 0], "々"),
	]

	for case in cases {
		wide, expected_str := case
		str := string.from_wide(wide.raw())
		t.assert_eq(str, expected_str, "string representation should be equal to expected for ${wide}")
	}
}

test "string from_wide_with_len conversion" {
	cases := [
		([0x61 as u16], 1, "a"),
		([0x042B as u16], 1, "Ы"),
		([0x65E5 as u16], 1, "日"),
		([0xD83D as u16, 0xDC96], 2, "💖"),
		([0x20AC as u16], 1, "€"),
		([0x000A as u16], 1, "\n"),
		([0x00A9 as u16], 1, "©"),
		([0xD800 as u16, 0xDF48], 2, "𐍈"),
		([0x0394 as u16], 1, "Δ"),
		([0x0131 as u16], 1, "ı"),
		([0xD840 as u16, 0xDC00], 2, "𠀀"),
		([0xD83D as u16, 0xDC4B], 2, "👋"),
		([0x2824 as u16], 1, "⠤"),
		([0x3005 as u16], 1, "々"),
	]

	for case in cases {
		wide, len, expected_str := case
		str := string.from_wide_with_len(wide.raw(), len)
		t.assert_eq(str, expected_str, "string representation should be equal to expected for ${wide} with length ${len}")
	}
}

test "string to_wide conversion for string" {
	cases := [
		("hello", [104 as u16, 101, 108, 108, 111]),
		("你好", [0x4F60 as u16, 0x597D]),
		("Привет", [0x041F as u16, 0x0440, 0x0438, 0x0432, 0x0435, 0x0442]),
		("こんにちは", [0x3053 as u16, 0x3093, 0x306B, 0x3061, 0x306F]),
		("🌍💻", [0xD83C as u16, 0xDF0D, 0xD83D, 0xDCBB]),
		("", [0x0000 as u16]),
	]

	for case in cases {
		s, expected_wide := case
		wide := s.to_wide()
		t.assert_eq(Array.from_ptr(wide, expected_wide.len).str(), expected_wide.str(), "wide representation should be equal to expected for ${s}")
	}
}

test "string from_wide conversion for string" {
	cases := [
		([104 as u16, 101, 108, 108, 111, 0], "hello"),
		([0x4F60 as u16, 0x597D, 0], "你好"),
		([0x041F as u16, 0x0440, 0x0438, 0x0432, 0x0435, 0x0442, 0], "Привет"),
		([0x3053 as u16, 0x3093, 0x306B, 0x3061, 0x306F, 0], "こんにちは"),
		([0xD83C as u16, 0xDF0D, 0xD83D, 0xDCBB, 0], "🌍💻"),
		([0x0000 as u16], ""),
	]

	for case in cases {
		wide, expected_str := case
		str := string.from_wide(wide.raw())
		t.assert_eq(str, expected_str, "string representation should be equal to expected for ${wide}")
	}
}

test "string from_wide_with_len conversion for string" {
	cases := [
		([104 as u16, 101, 108, 108, 111], 5, "hello"),
		([0x4F60 as u16, 0x597D], 2, "你好"),
		([0x041F as u16, 0x0440, 0x0438, 0x0432, 0x0435, 0x0442], 6, "Привет"),
		([0x3053 as u16, 0x3093, 0x306B, 0x3061, 0x306F], 5, "こんにちは"),
		([0xD83C as u16, 0xDF0D, 0xD83D, 0xDCBB], 4, "🌍💻"),
		([0x0000 as u16], 0, ""),
	]

	for case in cases {
		wide, len, expected_str := case
		str := string.from_wide_with_len(wide.raw(), len)
		t.assert_eq(str, expected_str, "string representation should be equal to expected for ${wide} with length ${len}")
	}
}

test "reverse for different strings" {
	cases := [
		("hello", "olleh"),
		("你好", "好你"),
		("Привет", "тевирП"),
		("こんにちは", "はちにんこ"),
		("🌍💻", "💻🌍"),
		("", ""),
		("a", "a"),
	]

	for case in cases {
		s, expected := case
		actual := s.reverse()
		t.assert_eq(actual, expected, "reversed string should be equal to expected for ${s}")
	}
}

test "string to_upper conversion" {
	cases := [
		("hello", "HELLO"),
		("こんにちは", "こんにちは"), // remains the same, non-ASCII
		("你好", "你好"), // remains the same, non-ASCII
		("123abc", "123ABC"),
		("", ""), // empty string
		("ALREADY UPPER", "ALREADY UPPER"),
		("mixed UPPER and lower", "MIXED UPPER AND LOWER"),
	]

	for case in cases {
		s, expected := case
		actual := s.to_upper()
		t.assert_eq(actual, expected, "uppercase conversion should be equal to expected for ${s}")
	}
}

test "string to_lower conversion" {
	cases := [
		("HELLO", "hello"),
		("こんにちは", "こんにちは"), // remains the same, non-ASCII
		("你好", "你好"), // remains the same, non-ASCII
		("123ABC", "123abc"),
		("", ""), // empty string
		("already lower", "already lower"),
		("MIXED UPPER and lower", "mixed upper and lower"),
	]

	for case in cases {
		s, expected := case
		actual := s.to_lower()
		t.assert_eq(actual, expected, "lowercase conversion should be equal to expected for ${s}")
	}
}

test "string hash method" {
	cases := [
		("hello world", 894552257 as u64),
		("привет мир", 682109516 as u64),
		("こんにちは", 553959323 as u64),
		("你好", 695135277 as u64),
		("123ABC", 2110892385 as u64),
		("", 5381 as u64),
	]

	for case in cases {
		s, expected := case
		actual := s.hash()
		t.assert_eq(actual, expected, "lowercase conversion should be equal to expected for ${s}")
	}
}
