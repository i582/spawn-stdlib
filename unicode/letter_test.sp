module main

import unicode
import net.conv

const UPPER_CASES = [
	0x41 as rune,
	0xc0,
	0xd8,
	0x100,
	0x139,
	0x14a,
	0x178,
	0x181,
	0x376,
	0x3cf,
	0x13bd,
	0x1f2a,
	0x2102,
	0x2c00,
	0x2c10,
	0x2c20,
	0xa650,
	0xa722,
	0xff3a,
	0x10400,
	0x1d400,
	0x1d7ca,
]

const LOWER_CASES = [
	0x40 as rune,
	0x5b,
	0x61,
	0x185,
	0x1b0,
	0x377,
	0x387,
	0x2150,
	0xab7d,
	0xffff,
	0x10000,
]

const LETTER_CASES = [
	0x41 as rune,
	0x61,
	0xaa,
	0xba,
	0xc8,
	0xdb,
	0xf9,
	0x2ec,
	0x535,
	0x620,
	0x6e6,
	0x93d,
	0xa15,
	0xb99,
	0xdc0,
	0xedd,
	0x1000,
	0x1200,
	0x1312,
	0x1401,
	0x2c00,
	0xa800,
	0xf900,
	0xfa30,
	0xffda,
	0xffdc,
	0x10000,
	0x10300,
	0x10400,
	0x20000,
	0x2f800,
	0x2fa1d,
]

const NON_LETTER_CASES = [
	0x20 as rune,
	0x35,
	0x375,
	0x619,
	0x700,
	0x1885,
	0xfffe,
	0x1ffff,
	0x10ffff,
]

const DIGIT_CASES = [
	`0`,
	`𞅀`,
	`𝟯`,
]

// CSPACE_CASES cntains all the special cased Latin-1 chars.
const SPACE_CASES = [
	0x09 as rune,
	0x0a,
	0x0b,
	0x0c,
	0x0d,
	0x20,
	0x85,
	0xA0,
	0x2000,
	0x3000,
]

const CASE_CASES = [
	// errors
	(-1, `\n`, 0xFFFD as rune),
	(unicode.UPPER_CASE, -1 as rune, -1 as rune),
	(unicode.UPPER_CASE, (1 << 30) as rune, (1 << 30) as rune),
	// ASCII (special-cased so test carefully)
	(unicode.UPPER_CASE, `\n`, `\n`),
	(unicode.UPPER_CASE, `a`, `A`),
	(unicode.UPPER_CASE, `A`, `A`),
	(unicode.UPPER_CASE, `7`, `7`),
	(unicode.LOWER_CASE, `\n`, `\n`),
	(unicode.LOWER_CASE, `a`, `a`),
	(unicode.LOWER_CASE, `A`, `a`),
	(unicode.LOWER_CASE, `7`, `7`),
	(unicode.TITLE_CASE, `\n`, `\n`),
	(unicode.TITLE_CASE, `a`, `A`),
	(unicode.TITLE_CASE, `A`, `A`),
	(unicode.TITLE_CASE, `7`, `7`),
	// Latin-1: easy to read the tests!
	(unicode.UPPER_CASE, 0x80 as rune, 0x80 as rune),
	(unicode.UPPER_CASE, `Å`, `Å`),
	(unicode.UPPER_CASE, `å`, `Å`),
	(unicode.LOWER_CASE, 0x80 as rune, 0x80 as rune),
	(unicode.LOWER_CASE, `Å`, `å`),
	(unicode.LOWER_CASE, `å`, `å`),
	(unicode.TITLE_CASE, 0x80 as rune, 0x80 as rune),
	(unicode.TITLE_CASE, `Å`, `Å`),
	(unicode.TITLE_CASE, `å`, `Å`),
	// 0131;LATIN SMALL LETTER DOTLESS I;Ll;0;L;;;;;N;;;0049;;0049
	(unicode.UPPER_CASE, 0x0131 as rune, `I`),
	(unicode.LOWER_CASE, 0x0131 as rune, 0x0131 as rune),
	(unicode.TITLE_CASE, 0x0131 as rune, `I`),
	// 0133;LATIN SMALL LIGATURE IJ;Ll;0;L;<compat> 0069 006A;;;;N;LATIN SMALL LETTER I J;;0132;;0132
	(unicode.UPPER_CASE, 0x0133 as rune, 0x0132 as rune),
	(unicode.LOWER_CASE, 0x0133 as rune, 0x0133 as rune),
	(unicode.TITLE_CASE, 0x0133 as rune, 0x0132 as rune),
	// 212A;KELVIN SIGN;Lu;0;L;004B;;;;N;DEGREES KELVIN;;;006B;
	(unicode.UPPER_CASE, 0x212A as rune, 0x212A as rune),
	(unicode.LOWER_CASE, 0x212A as rune, `k`),
	(unicode.TITLE_CASE, 0x212A as rune, 0x212A as rune),
	// From an UpperLower sequence
	// A640;CYRILLIC CAPITAL LETTER ZEMLYA;Lu;0;L;;;;;N;;;;A641;
	(unicode.UPPER_CASE, 0xA640 as rune, 0xA640 as rune),
	(unicode.LOWER_CASE, 0xA640 as rune, 0xA641 as rune),
	(unicode.TITLE_CASE, 0xA640 as rune, 0xA640 as rune),
	// A641;CYRILLIC SMALL LETTER ZEMLYA;Ll;0;L;;;;;N;;;A640;;A640
	(unicode.UPPER_CASE, 0xA641 as rune, 0xA640 as rune),
	(unicode.LOWER_CASE, 0xA641 as rune, 0xA641 as rune),
	(unicode.TITLE_CASE, 0xA641 as rune, 0xA640 as rune),
	// A64E;CYRILLIC CAPITAL LETTER NEUTRAL YER;Lu;0;L;;;;;N;;;;A64F;
	(unicode.UPPER_CASE, 0xA64E as rune, 0xA64E as rune),
	(unicode.LOWER_CASE, 0xA64E as rune, 0xA64F as rune),
	(unicode.TITLE_CASE, 0xA64E as rune, 0xA64E as rune),
	// A65F;CYRILLIC SMALL LETTER YN;Ll;0;L;;;;;N;;;A65E;;A65E
	(unicode.UPPER_CASE, 0xA65F as rune, 0xA65E as rune),
	(unicode.LOWER_CASE, 0xA65F as rune, 0xA65F as rune),
	(unicode.TITLE_CASE, 0xA65F as rune, 0xA65E as rune),
	// From another UpperLower sequence
	// 0139;LATIN CAPITAL LETTER L WITH ACUTE;Lu;0;L;004C 0301;;;;N;LATIN CAPITAL LETTER L ACUTE;;;013A;
	(unicode.UPPER_CASE, 0x0139 as rune, 0x0139 as rune),
	(unicode.LOWER_CASE, 0x0139 as rune, 0x013A as rune),
	(unicode.TITLE_CASE, 0x0139 as rune, 0x0139 as rune),
	// 013F;LATIN CAPITAL LETTER L WITH MIDDLE DOT;Lu;0;L;<compat> 004C 00B7;;;;N;;;;0140;
	(unicode.UPPER_CASE, 0x013f as rune, 0x013f as rune),
	(unicode.LOWER_CASE, 0x013f as rune, 0x0140 as rune),
	(unicode.TITLE_CASE, 0x013f as rune, 0x013f as rune),
	// 0148;LATIN SMALL LETTER N WITH CARON;Ll;0;L;006E 030C;;;;N;LATIN SMALL LETTER N HACEK;;0147;;0147
	(unicode.UPPER_CASE, 0x0148 as rune, 0x0147 as rune),
	(unicode.LOWER_CASE, 0x0148 as rune, 0x0148 as rune),
	(unicode.TITLE_CASE, 0x0148 as rune, 0x0147 as rune),
	// unicode.LOWER_CASE lower than unicode.UPPER_CASE.
	// AB78;CHEROKEE SMALL LETTER GE;Ll;0;L;;;;;N;;;13A8;;13A8
	(unicode.UPPER_CASE, 0xab78 as rune, 0x13a8 as rune),
	(unicode.LOWER_CASE, 0xab78 as rune, 0xab78 as rune),
	(unicode.TITLE_CASE, 0xab78 as rune, 0x13a8 as rune),
	(unicode.UPPER_CASE, 0x13a8 as rune, 0x13a8 as rune),
	(unicode.LOWER_CASE, 0x13a8 as rune, 0xab78 as rune),
	(unicode.TITLE_CASE, 0x13a8 as rune, 0x13a8 as rune),
	// Last block in the 5.1.0 table
	// 10400;DESERET CAPITAL LETTER LONG I;Lu;0;L;;;;;N;;;;10428;
	(unicode.UPPER_CASE, 0x10400 as rune, 0x10400 as rune),
	(unicode.LOWER_CASE, 0x10400 as rune, 0x10428 as rune),
	(unicode.TITLE_CASE, 0x10400 as rune, 0x10400 as rune),
	// 10427;DESERET CAPITAL LETTER EW;Lu;0;L;;;;;N;;;;1044F;
	(unicode.UPPER_CASE, 0x10427 as rune, 0x10427 as rune),
	(unicode.LOWER_CASE, 0x10427 as rune, 0x1044F as rune),
	(unicode.TITLE_CASE, 0x10427 as rune, 0x10427 as rune),
	// 10428;DESERET SMALL LETTER LONG I;Ll;0;L;;;;;N;;;10400;;10400
	(unicode.UPPER_CASE, 0x10428 as rune, 0x10400 as rune),
	(unicode.LOWER_CASE, 0x10428 as rune, 0x10428 as rune),
	(unicode.TITLE_CASE, 0x10428 as rune, 0x10400 as rune),
	// 1044F;DESERET SMALL LETTER EW;Ll;0;L;;;;;N;;;10427;;10427
	(unicode.UPPER_CASE, 0x1044F as rune, 0x10427 as rune),
	(unicode.LOWER_CASE, 0x1044F as rune, 0x1044F as rune),
	(unicode.TITLE_CASE, 0x1044F as rune, 0x10427 as rune),
	// First one not in the 5.1.0 table
	// 10450;SHAVIAN LETTER PEEP;Lo;0;L;;;;;N;;;;;
	(unicode.UPPER_CASE, 0x10450 as rune, 0x10450 as rune),
	(unicode.LOWER_CASE, 0x10450 as rune, 0x10450 as rune),
	(unicode.TITLE_CASE, 0x10450 as rune, 0x10450 as rune),
	// Non-letters with case.
	(unicode.LOWER_CASE, 0x2161 as rune, 0x2171 as rune),
	(unicode.UPPER_CASE, 0x0345 as rune, 0x0399 as rune),
]

test "is_letter function" {
	for case in UPPER_CASES {
		t.assert_true(unicode.is_letter(case), 'expected true for cases in UPPER_CASES')
	}
	for case in LETTER_CASES {
		t.assert_true(unicode.is_letter(case), 'expected true for cases in LETTER_CASES')
	}
	for case in NON_LETTER_CASES {
		t.assert_false(unicode.is_letter(case), 'expected false for cases in NON_LETTER_CASES')
	}
}

test "is_upper function" {
	for case in UPPER_CASES {
		t.assert_true(unicode.is_upper(case), 'expected true for cases in UPPER_CASES')
	}
	for case in LOWER_CASES {
		t.assert_false(unicode.is_upper(case), 'expected true for cases in LOWER_CASES')
	}
	for case in NON_LETTER_CASES {
		t.assert_false(unicode.is_upper(case), 'expected false for cases in NON_LETTER_CASES')
	}
}

test "is_digit function" {
	for case in DIGIT_CASES {
		t.assert_true(unicode.is_digit(case), 'expected true for cases in DIGIT_CASES')
	}
	for case in LETTER_CASES {
		t.assert_false(unicode.is_digit(case), 'expected true for cases in LOWER_CASES')
	}
}

test "to_upper function" {
	for case in CASE_CASES {
		to_case, val, expected := case
		if to_case != unicode.UPPER_CASE {
			continue
		}

		t.assert_eq(unicode.to_upper(val), expected, 'actual should be equal to expected')
	}
}

test "to_lower function" {
	for case in CASE_CASES {
		to_case, val, expected := case
		if to_case != unicode.LOWER_CASE {
			continue
		}

		t.assert_eq(unicode.to_lower(val), expected, 'actual should be equal to expected')
	}
}

test "to_title function" {
	for case in CASE_CASES {
		to_case, val, expected := case
		if to_case != unicode.TITLE_CASE {
			continue
		}

		t.assert_eq(unicode.to_title(val), expected, 'actual should be equal to expected')
	}
}
