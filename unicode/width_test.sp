module main

import unicode

test "width of rune" {
	cases := [
		(`世`, 2, 2, 2),
		(`界`, 2, 2, 2),
		(`ｾ`, 1, 1, 1),
		(`ｶ`, 1, 1, 1),
		(`ｲ`, 1, 1, 1),
		(`☆`, 1, 2, 2), // double width in ambiguous
		(`☺`, 1, 1, 2),
		(`☻`, 1, 1, 2),
		(`♥`, 1, 2, 2),
		(`♦`, 1, 1, 2),
		(`♣`, 1, 2, 2),
		(`♠`, 1, 2, 2),
		(`♂`, 1, 2, 2),
		(`♀`, 1, 2, 2),
		(`♪`, 1, 2, 2),
		(`♫`, 1, 1, 2),
		(`☼`, 1, 1, 2),
		(`↕`, 1, 2, 2),
		(`‼`, 1, 1, 2),
		(`↔`, 1, 2, 2),
		(0x00 as rune, 0, 0, 0),
		(0x01 as rune, 0, 0, 0),
		(0x0300 as rune, 0, 0, 0),
		(0x2028 as rune, 0, 0, 0),
		(0x2029 as rune, 0, 0, 0),
		(`a`, 1, 1, 1), // ASCII classified as "na" (narrow)
		(`⟦`, 1, 1, 1), // non-ASCII classified as "na" (narrow)
		(`👁`, 1, 1, 2),
	]

	mut w := unicode.Width{}
	w.east_asian_width = false
	for case in cases {
		r, expected, _, _ := case
		t.assert_eq(w.rune_width(r), expected, 'actual should be equal to expected for ${r}')
	}

	w.east_asian_width = true
	for i, case in cases {
		r, _, expected, _ := case
		t.assert_eq(w.rune_width(r), expected, 'actual should be equal to expected for ${r} at ${i}-case')
	}

	w.strict_emoji_neutral = false
	for i, case in cases {
		r, _, _, expected := case
		t.assert_eq(w.rune_width(r), expected, 'actual should be equal to expected for ${r} at ${i}-case')
	}
}

test "width of string" {
	cases := [
		("■㈱の世界①", 10, 12),
		("スター☆", 7, 8),
		("つのだ☆HIRO", 11, 12),
		("カタカナ", 8, 8),
		("漢字", 4, 4),
		("한자", 4, 4),
		("अरबी लिपि", 9, 9),
		("🐈👽📛", 6, 6),
	]

	mut w := unicode.Width{}
	w.east_asian_width = false
	for case in cases {
		str, expected, _ := case
		t.assert_eq(w.string_width(str), expected, 'actual should be equal to expected for ${str}')
	}

	w.east_asian_width = true
	for case in cases {
		str, _, expected := case
		t.assert_eq(w.string_width(str), expected, 'actual should be equal to expected for ${str}')
	}
}
