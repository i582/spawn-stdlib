module main

import utf8

test "validate string" {
	cases := [
		("", true),
		("a", true),
		("abc", true),
		("Ж", true),
		("ЖЖ", true),
		("хлеб-ЛГТМ", true),
		("☺☻☹", true),
		("aa\xe2", false),
		([66 as u8, 250].ascii_str(), false),
		("a\uFFFDb", true),
		("\xF4\x8F\xBF\xBF", true), // U+10FFFF
		("\xF4\x90\x80\x80", false), // U+10FFFF+1; out of range
		("\xF7\xBF\xBF\xBF", false), // 0x1FFFFF; out of range
		("\xFB\xBF\xBF\xBF\xBF", false), // 0x3FFFFFF; out of range
		("\xc0\x80", false), // U+0000 encoded in two bytes: incorrect
		("\xed\xa0\x80", false), // U+D800 high surrogate (sic)
		("\xed\xbf\xbf", false), // U+DFFF low surrogate (sic)
	]

	for i, case in cases {
		str, expected := case
		t.assert_eq(utf8.validate_string(str), expected, 'actual should be equal to expected for case ${i}')
	}
}
