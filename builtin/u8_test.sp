module main

test "u8 is_space" {
	cases := [
		(b` `, true),
		(b`\t`, true),
		(b`\n`, true),
		(b`\v`, true),
		(b`\f`, true),
		(b`\r`, true),
		(0x85 as u8, true),
		(0xA0 as u8, true),
		(b`a`, false),
		(b`1`, false),
	]

	for case in cases {
		u, expected := case
		t.assert_eq(u.is_space(), expected, "is_space should be ${expected} for ${u.ascii_str()}")
	}
}

test "u8 is_digit" {
	cases := [
		(b`0`, true),
		(b`5`, true),
		(b`9`, true),
		(b`a`, false),
		(b`A`, false),
		(b`-`, false),
	]

	for case in cases {
		u, expected := case
		t.assert_eq(u.is_digit(), expected, "is_digit should be ${expected} for ${u.ascii_str()}")
	}
}

test "u8 is_bin_digit" {
	cases := [
		(b`0`, true),
		(b`1`, true),
		(b`2`, false),
		(b`a`, false),
	]

	for case in cases {
		u, expected := case
		t.assert_eq(u.is_bin_digit(), expected, "is_bin_digit should be ${expected} for ${u.ascii_str()}")
	}
}

test "u8 is_oct_digit" {
	cases := [
		(b`0`, true),
		(b`7`, true),
		(b`8`, false),
		(b`9`, false),
		(b`a`, false),
	]

	for case in cases {
		u, expected := case
		t.assert_eq(u.is_oct_digit(), expected, "is_oct_digit should be ${expected} for ${u.ascii_str()}")
	}
}

test "u8 is_hex_digit" {
	cases := [
		(b`0`, true),
		(b`9`, true),
		(b`a`, true),
		(b`f`, true),
		(b`A`, true),
		(b`F`, true),
		(b`g`, false),
		(b`h`, false),
	]

	for case in cases {
		u, expected := case
		t.assert_eq(u.is_hex_digit(), expected, "is_hex_digit should be ${expected} for ${u.ascii_str()}")
	}
}

test "u8 is_punctuation" {
	cases := [
		(b`!`, true),
		(b`@`, true),
		(b`[`, true),
		(b`{`, true),
		(b`a`, false),
		(b`1`, false),
	]

	for case in cases {
		u, expected := case
		t.assert_eq(u.is_punctuation(), expected, "is_punctuation should be ${expected} for ${u.ascii_str()}")
	}
}

test "u8 is_graphic" {
	cases := [
		(b`!`, true),
		(b`~`, true),
		(b` `, false),
		(b`\n`, false),
	]

	for case in cases {
		u, expected := case
		t.assert_eq(u.is_graphic(), expected, "is_graphic should be ${expected} for ${u.ascii_str()}")
	}
}

test "u8 is_control" {
	cases := [
		(b`\n`, true),
		(b`\t`, true),
		(b` `, false),
		(b`a`, false),
		(0x7F as u8, true),
	]

	for case in cases {
		u, expected := case
		t.assert_eq(u.is_control(), expected, "is_control should be ${expected} for ${u.ascii_str()}")
	}
}

test "u8 is_alpha" {
	cases := [
		(b`a`, true),
		(b`z`, true),
		(b`A`, true),
		(b`Z`, true),
		(b`1`, false),
		(b`@`, false),
	]

	for case in cases {
		u, expected := case
		t.assert_eq(u.is_alpha(), expected, "is_alpha should be ${expected} for ${u.ascii_str()}")
	}
}

test "u8 is_alphanum" {
	cases := [
		(b`a`, true),
		(b`1`, true),
		(b`A`, true),
		(b`@`, false),
	]

	for case in cases {
		u, expected := case
		t.assert_eq(u.is_alphanum(), expected, "is_alphanum should be ${expected} for ${u.ascii_str()}")
	}
}

test "u8 is_capital" {
	cases := [
		(b`A`, true),
		(b`Z`, true),
		(b`a`, false),
		(b`z`, false),
	]

	for case in cases {
		u, expected := case
		t.assert_eq(u.is_capital(), expected, "is_capital should be ${expected} for ${u.ascii_str()}")
	}
}

test "u8 is_lower" {
	cases := [
		(b`a`, true),
		(b`z`, true),
		(b`A`, false),
		(b`Z`, false),
	]

	for case in cases {
		u, expected := case
		t.assert_eq(u.is_lower(), expected, "is_lower should be ${expected} for ${u.ascii_str()}")
	}
}

test "u8 is_ascii" {
	cases := [
		(b`a`, true),
		(b`z`, true),
		(0x7F as u8, true),
		(0x80 as u8, false),
		(0xFF as u8, false),
	]

	for case in cases {
		u, expected := case
		t.assert_eq(u.is_ascii(), expected, "is_ascii should be ${expected} for ${u.ascii_str()}")
	}
}

test "u8 ascii_str" {
	cases := [
		(b`a`, "a"),
		(b`1`, "1"),
		(b`@`, "@"),
	]

	for case in cases {
		u, expected := case
		actual_str := u.ascii_str()
		t.assert_eq(actual_str, expected, "ascii_str should be '${expected}' for ${u.ascii_str()}")
	}
}

test "u8 repeat" {
	cases := [
		(b`a`, 0, ""),
		(b`a`, 1, "a"),
		(b`a`, 3, "aaa"),
	]

	for case in cases {
		u, count, expected_str := case
		actual_str := u.repeat(count)
		t.assert_eq(actual_str, expected_str, "repeat should produce '${expected_str}' for ${u.ascii_str()} repeated ${count} times")
	}
}

test "u8 to_lower" {
	cases := [
		(b`A`, b`a`),
		(b`Z`, b`z`),
		(b`a`, b`a`),
		(b`z`, b`z`),
		(b`0`, b`0`),
	]

	for case in cases {
		u, expected := case
		t.assert_eq(u.to_lower(), expected, "to_lower should be ${expected.ascii_str()} for ${u.ascii_str()}")
	}
}

test "u8 to_upper" {
	cases := [
		(b`a`, b`A`),
		(b`z`, b`Z`),
		(b`A`, b`A`),
		(b`Z`, b`Z`),
		(b`0`, b`0`),
	]

	for case in cases {
		u, expected := case
		t.assert_eq(u.to_upper(), expected, "to_upper should be ${expected.ascii_str()} for ${u.ascii_str()}")
	}
}

test "u8 str" {
	cases := [
		(b`a`, "97"),
		(b`0`, "48"),
		(b`A`, "65"),
		(0x7F as u8, "127"),
	]

	for case in cases {
		u, expected_str := case
		t.assert_eq(u.str(), expected_str, "str should be '${expected_str}' for ${u.ascii_str()}")
	}
}

test "u8 hex" {
	cases := [
		(b`a`, "61"),
		(b`0`, "30"),
		(b`A`, "41"),
		(0x7F as u8, "7f"),
	]

	for case in cases {
		u, expected_hex := case
		t.assert_eq(u.hex(), expected_hex, "hex should be '${expected_hex}' for ${u.ascii_str()}")
	}
}

test "u8 hex_prefixed" {
	cases := [
		(b`a`, "0x61"),
		(b`0`, "0x30"),
		(b`A`, "0x41"),
		(0x7F as u8, "0x7f"),
	]

	for case in cases {
		u, expected_hex := case
		t.assert_eq(u.hex_prefixed(), expected_hex, "hex_prefixed should be '${expected_hex}' for ${u.ascii_str()}")
	}
}

test "u8 cmp" {
	cases := [
		(b`a`, b`a`, Ordering.equal),
		(b`a`, b`b`, Ordering.less),
		(b`b`, b`a`, Ordering.greater),
		(b`a`, b`1`, Ordering.greater),
		(b`1`, b`a`, Ordering.less),
	]

	for case in cases {
		u, v, expected_ordering := case
		t.assert_eq(u.cmp(v), expected_ordering, "cmp should be ${expected_ordering} for ${u.ascii_str()} compared to ${v.ascii_str()}")
	}
}
