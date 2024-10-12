module main

test "rune to string" {
	cases := [
		(`a`, "a"), // Simple ASCII character
		(`Ы`, "Ы"), // Russian letter Ы
		(`日`, "日"), // Chinese character 日
		(`💖`, "💖"), // Emoji 💖
		(`€`, "€"), // Euro symbol €
		(`\n`, "\n"), // Newline character
		(`©`, "©"), // Copyright symbol ©
		(`𐍈`, "𐍈"), // Old English letter 𐍈
		(`ا`, "ا"), // Arabic letter ا
		(`Δ`, "Δ"), // Greek letter Δ
		(`ı`, "ı"), // Turkish letter ı
		(`𠀀`, "𠀀"), // CJK Ideograph 𠀀
		(`👋`, "👋"), // Emoji 👋
		(`⠤`, "⠤"), // Braille pattern ⠤
		(`々`, "々"), // Japanese repetition mark 々
	]

	for case in cases {
		r, expected_str := case
		actual_str := r.str()
		t.assert_eq(actual_str, expected_str, "string representation should be equal to expected for ${r}")
	}
}

test "rune to bytes" {
	cases := [
		(`a`, [97 as u8]), // Simple ASCII character
		(`Ы`, [0xD0 as u8, 0xAB]), // Russian letter Ы
		(`日`, [0xE6 as u8, 0x97, 0xA5]), // Chinese character 日
		(`💖`, [0xF0 as u8, 0x9F, 0x92, 0x96]), // Emoji 💖
		(`€`, [0xE2 as u8, 0x82, 0xAC]), // Euro symbol €
		(`\n`, [0x0A as u8]), // Newline character
		(`©`, [0xC2 as u8, 0xA9]), // Copyright symbol ©
		(`𐍈`, [0xF0 as u8, 0x90, 0x8D, 0x88]), // Old English letter 𐍈
		(`ا`, [0xD8 as u8, 0xA7]), // Arabic letter ا
		(`Δ`, [0xCE as u8, 0x94]), // Greek letter Δ
		(`ı`, [0xC4 as u8, 0xB1]), // Turkish letter ı
		(`𠀀`, [0xF0 as u8, 0xA0, 0x80, 0x80]), // CJK Ideograph 𠀀
		(`👋`, [0xF0 as u8, 0x9F, 0x91, 0x8B]), // Emoji 👋
		(`⠤`, [0xE2 as u8, 0xA0, 0xA4]), // Braille pattern ⠤
		(`々`, [0xE3 as u8, 0x80, 0x85]), // Japanese repetition mark 々
	]

	for case in cases {
		r, bytes := case
		t.assert_eq(r.bytes().map(|el| el.hex_prefixed()).str(), bytes.map(|el| el.hex_prefixed()).str(), "bytes should be equal to expected for ${r}")
	}
}

test "rune len" {
	cases := [
		(`a`, 1), // Simple ASCII character
		(`Ы`, 2), // Russian letter Ы
		(`日`, 3), // Chinese character 日
		(`💖`, 4), // Emoji 💖
		(`€`, 3), // Euro symbol €
		(`\n`, 1), // Newline character
		(`©`, 2), // Copyright symbol ©
		(`𐍈`, 4), // Old English letter 𐍈
		(`ا`, 2), // Arabic letter ا
		(`Δ`, 2), // Greek letter Δ
		(`ı`, 2), // Turkish letter ı
		(`𠀀`, 4), // CJK Ideograph 𠀀
		(`👋`, 4), // Emoji 👋
		(`⠤`, 3), // Braille pattern ⠤
		(`々`, 3), // Japanese repetition mark 々
		(0xD800 as rune, -1), // Surrogate half (high) - Not valid on its own
		(0xDFFF as rune, -1), // Surrogate half (low) - Not valid on its own
		(0x110000 as rune, -1), // Code point beyond the valid Unicode range
	]

	for case in cases {
		r, expected_len := case
		t.assert_eq(r.len(), expected_len as isize, "length of bytes should be equal to expected for ${r}")
	}
}

test "rune validity" {
	cases := [
		(`a`, true), // Simple ASCII character
		(`日`, true), // Chinese character 日
		(`💖`, true), // Emoji 💖
		(`€`, true), // Euro symbol €
		(`\n`, true), // Newline character
		(`𐍈`, true), // Old English letter 𐍈
		(0x10FFFF as rune, true), // Last valid Unicode code point
		(0xD800 as rune, false), // Surrogate half (high) - Not valid on its own
		(0xDFFF as rune, false), // Surrogate half (low) - Not valid on its own
		(0x110000 as rune, false), // Code point beyond the valid Unicode range
	]

	for i, case in cases {
		r, expected_validity := case
		t.assert_eq(r.is_valid(), expected_validity, "is_valid should be ${expected_validity} for ${i + 1} case")
	}
}

test "rune repeat" {
	cases := [
		(`a`, 0, ""),
		(`a`, 1, "a"),
		(`a`, 3, "aaa"),
		(`日`, 0, ""),
		(`日`, 1, "日"),
		(`日`, 2, "日日"),
		(`💖`, 0, ""),
		(`💖`, 1, "💖"),
		(`💖`, 3, "💖💖💖"),
		(`€`, 0, ""),
		(`€`, 1, "€"),
		(`€`, 2, "€€"),
		(`⠤`, 0, ""),
		(`⠤`, 1, "⠤"),
		(`⠤`, 3, "⠤⠤⠤"),
	]

	for case in cases {
		r, count, expected_str := case
		actual_str := r.repeat(count)
		t.assert_eq(actual_str, expected_str, "repeated string should be equal to expected for ${r} repeated ${count} times")
	}
}
