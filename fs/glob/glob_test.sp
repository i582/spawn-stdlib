module main

import fs.glob

test "glob matching" {
	cases := [
		("abc", "abc", true, none as ?glob.BadPattern),
		("*", "abc", true, none as ?glob.BadPattern),
		("*c", "abc", true, none as ?glob.BadPattern),
		("a*", "a", true, none as ?glob.BadPattern),
		("a*", "abc", true, none as ?glob.BadPattern),
		("a*", "ab/c", false, none as ?glob.BadPattern),
		("a*/b", "abc/b", true, none as ?glob.BadPattern),
		("a*/b", "a/c/b", false, none as ?glob.BadPattern),
		("a*b*c*d*e*/f", "axbxcxdxe/f", true, none as ?glob.BadPattern),
		("a*b*c*d*e*/f", "axbxcxdxexxx/f", true, none as ?glob.BadPattern),
		("a*b*c*d*e*/f", "axbxcxdxe/xxx/f", false, none as ?glob.BadPattern),
		("a*b*c*d*e*/f", "axbxcxdxexxx/fff", false, none as ?glob.BadPattern),
		("a*b?c*x", "abxbbxdbxebxczzx", true, none as ?glob.BadPattern),
		("a*b?c*x", "abxbbxdbxebxczzy", false, none as ?glob.BadPattern),
		("ab[c]", "abc", true, none as ?glob.BadPattern),
		("ab[b-d]", "abc", true, none as ?glob.BadPattern),
		("ab[e-g]", "abc", false, none as ?glob.BadPattern),
		("ab[^c]", "abc", false, none as ?glob.BadPattern),
		("ab[^b-d]", "abc", false, none as ?glob.BadPattern),
		("ab[^e-g]", "abc", true, none as ?glob.BadPattern),
		("a\\*b", "a*b", true, none as ?glob.BadPattern),
		("a\\*b", "ab", false, none as ?glob.BadPattern),
		("a?b", "a☺b", true, none as ?glob.BadPattern),
		("a[^a]b", "a☺b", true, none as ?glob.BadPattern),
		("a???b", "a☺b", false, none as ?glob.BadPattern),
		("a[^a][^a][^a]b", "a☺b", false, none as ?glob.BadPattern),
		("[a-ζ]*", "α", true, none as ?glob.BadPattern),
		("*[a-ζ]", "A", false, none as ?glob.BadPattern),
		("a?b", "a/b", false, none as ?glob.BadPattern),
		("a*b", "a/b", false, none as ?glob.BadPattern),
		("[\\]a]", "]", true, none as ?glob.BadPattern),
		("[\\-]", "-", true, none as ?glob.BadPattern),
		("[x\\-]", "x", true, none as ?glob.BadPattern),
		("[x\\-]", "-", true, none as ?glob.BadPattern),
		("[x\\-]", "z", false, none as ?glob.BadPattern),
		("[\\-x]", "x", true, none as ?glob.BadPattern),
		("[\\-x]", "-", true, none as ?glob.BadPattern),
		("[\\-x]", "a", false, none as ?glob.BadPattern),
		("[]a]", "]", false, opt(glob.BAD_PATTERN)),
		("[-]", "-", false, opt(glob.BAD_PATTERN)),
		("[x-]", "x", false, opt(glob.BAD_PATTERN)),
		("[x-]", "-", false, opt(glob.BAD_PATTERN)),
		("[x-]", "z", false, opt(glob.BAD_PATTERN)),
		("[-x]", "x", false, opt(glob.BAD_PATTERN)),
		("[-x]", "-", false, opt(glob.BAD_PATTERN)),
		("[-x]", "a", false, opt(glob.BAD_PATTERN)),
		("\\", "a", false, opt(glob.BAD_PATTERN)),
		("[a-b-c]", "a", false, opt(glob.BAD_PATTERN)),
		("[", "a", false, opt(glob.BAD_PATTERN)),
		("[^", "a", false, opt(glob.BAD_PATTERN)),
		("[^bc", "a", false, opt(glob.BAD_PATTERN)),
		("a[", "a", false, opt(glob.BAD_PATTERN)),
		("a[", "ab", false, opt(glob.BAD_PATTERN)),
		("a[", "x", false, opt(glob.BAD_PATTERN)),
		("a/b[", "x", false, opt(glob.BAD_PATTERN)),
		("*x", "xxx", true, none as ?glob.BadPattern),
	]

	for case in cases {
		pattern, input, expected, expected_err := case
		matches := glob.matches(pattern, input) or {
			if expected_err == none {
				t.fail('unexpected error ${err.msg()}')
				continue
			}

			t.assert_eq(expected_err.msg(), err.msg(), 'actual error should be equal expected error')
			return
		}

		t.assert_eq(expected, matches, 'expected `${expected}` but got `${matches}` for pattern `${pattern}` and input `${input}`')
	}
}
