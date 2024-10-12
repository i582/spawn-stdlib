module main

import semver

test "parse constraints" {
	cases := [
		(">= 1.2", ">=", "1.2.0", false),
		("1.0", "", "1.0.0", false),
		("foo", "", "", true),
		("<= 1.2", "<=", "1.2.0", false),
		("=< 1.2", "=<", "1.2.0", false),
		("=> 1.2", "=>", "1.2.0", false),
		("v1.2", "", "1.2.0", false),
		("=1.5", "=", "1.5.0", false),
		("> 1.3", ">", "1.3.0", false),
		("< 1.4.1", "<", "1.4.1", false),
		("< 40.50.10", "<", "40.50.10", false),
	]

	for case in cases {
		input, func, encoded, should_error := case

		c := semver.Constraint.parse(input) or {
			if should_error {
				continue
			}

			t.fail("unexpected error for input: ${input}: ${err.msg()}")
			semver.Constraint{}
		}

		if should_error {
			t.fail("expected error for input: ${input}")
			continue
		}

		if c.orig_func != func {
			t.fail("expected func: ${func}, got: ${c.orig_func} for input: ${input}")
		}

		if c.con.encode() != encoded {
			t.fail("expected encoded: ${encoded}, got: ${c.con.encode()} for input: ${input}")
		}
	}
}

test "constraint check" {
	cases := [
		("=2.0.0", "1.2.3", false),
		("=2.0.0", "2.0.0", true),
		("=2.0", "1.2.3", false),
		("=2.0", "2.0.0", true),
		("=2.0", "2.0.1", true),
		("4.1", "4.1.0", true),
		("!=4.1.0", "4.1.0", false),
		("!=4.1.0", "4.1.1", true),
		("!=4.1", "4.1.0", false),
		("!=4.1", "4.1.1", false),
		("!=4.1", "5.1.0-alpha.1", false),
		("!=4.1-alpha", "4.1.0", true),
		("!=4.1", "5.1.0", true),
		("<11", "0.1.0", true),
		("<11", "11.1.0", false),
		("<1.1", "0.1.0", true),
		("<1.1", "1.1.0", false),
		("<1.1", "1.1.1", false),
		("<=11", "1.2.3", true),
		("<=11", "12.2.3", false),
		("<=11", "11.2.3", true),
		("<=1.1", "1.2.3", false),
		("<=1.1", "0.1.0", true),
		("<=1.1", "1.1.0", true),
		("<=1.1", "1.1.1", true),
		(">1.1", "4.1.0", true),
		(">1.1", "1.1.0", false),
		(">0", "0", false),
		(">0", "1", true),
		(">0", "0.0.1-alpha", false),
		(">0.0", "0.0.1-alpha", false),
		(">0-0", "0.0.1-alpha", false),
		(">0.0-0", "0.0.1-alpha", false),
		(">0", "0.0.0-alpha", false),
		(">0-0", "0.0.0-alpha", false),
		(">0.0.0-0", "0.0.0-alpha", true),
		(">1.2.3-alpha.1", "1.2.3-alpha.2", true),
		(">1.2.3-alpha.1", "1.3.3-alpha.2", true),
		(">11", "11.1.0", false),
		(">11.1", "11.1.0", false),
		(">11.1", "11.1.1", false),
		(">11.1", "11.2.1", true),
		(">=11", "11.1.2", true),
		(">=11.1", "11.1.2", true),
		(">=11.1", "11.0.2", false),
		(">=1.1", "4.1.0", true),
		(">=1.1", "1.1.0", true),
		(">=1.1", "0.0.9", false),
		(">=0", "0.0.1-alpha", false),
		(">=0.0", "0.0.1-alpha", false),
		(">=0-0", "0.0.1-alpha", true),
		(">=0.0-0", "0.0.1-alpha", true),
		(">=0", "0.0.0-alpha", false),
		(">=0-0", "0.0.0-alpha", true),
		(">=0.0.0-0", "0.0.0-alpha", true),
		(">=0.0.0-0", "1.2.3", true),
		(">=0.0.0-0", "3.4.5-beta.1", true),
		("<0", "0.0.0-alpha", false),
		("<0-z", "0.0.0-alpha", true),
		(">=0", "0", true),
		("=0", "1", false),
		("*", "1", true),
		("*", "4.5.6", true),
		("*", "1.2.3-alpha.1", false),
		("*-0", "1.2.3-alpha.1", true),
		("2.*", "1", false),
		("2.*", "3.4.5", false),
		("2.*", "2.1.1", true),
		("2.1.*", "2.1.1", true),
		("2.1.*", "2.2.1", false),
		("", "1", true),
		("", "4.5.6", true),
		("", "1.2.3-alpha.1", false),
		("2", "1", false),
		("2", "3.4.5", false),
		("2", "2.1.1", true),
		("2.1", "2.1.1", true),
		("2.1", "2.2.1", false),
		("~1.2.3", "1.2.4", true),
		("~1.2.3", "1.3.4", false),
		("~1.2", "1.2.4", true),
		("~1.2", "1.3.4", false),
		("~1", "1.2.4", true),
		("~1", "2.3.4", false),
		("~0.2.3", "0.2.5", true),
		("~0.2.3", "0.3.5", false),
		("~1.2.3-beta.2", "1.2.3-beta.4", true),
		("~1.2.3-beta.2", "1.2.4-beta.2", true),
		("~1.2.3-beta.2", "1.3.4-beta.2", false),
		("^1.2.3", "1.8.9", true),
		("^1.2.3", "2.8.9", false),
		("^1.2.3", "1.2.1", false),
		("^1.1.0", "2.1.0", false),
		("^1.2.0", "2.2.1", false),
		("^1.2.0", "1.2.1-alpha.1", false),
		("^1.2.0-alpha.0", "1.2.1-alpha.1", true),
		("^1.2.0-alpha.0", "1.2.1-alpha.0", true),
		("^1.2.0-alpha.2", "1.2.0-alpha.1", false),
		("^1.2", "1.8.9", true),
		("^1.2", "2.8.9", false),
		("^1", "1.8.9", true),
		("^1", "2.8.9", false),
		("^0.2.3", "0.2.5", true),
		("^0.2.3", "0.5.6", false),
		("^0.2", "0.2.5", true),
		("^0.2", "0.5.6", false),
		("^0.0.3", "0.0.3", true),
		("^0.0.3", "0.0.4", false),
		("^0.0", "0.0.3", true),
		("^0.0", "0.1.4", false),
		("^0.0", "1.0.4", false),
		("^0", "0.2.3", true),
		("^0", "1.1.4", false),
		("^0.2.3-beta.2", "0.2.3-beta.4", true),
		("^0.2.3-beta.2", "0.2.4-beta.2", true),
		("^0.2.3-beta.2", "0.3.4-beta.2", false),
		("^0.2.3-beta.2", "0.2.3-beta.2", true),
	]

	for case in cases {
		input, version, expected := case

		c := semver.Constraint.parse(input) or {
			t.fail("unexpected error for input: ${input}: ${err.msg()}")
			semver.Constraint{}
		}

		v := semver.Version.parse(version) or {
			t.fail("unexpected error for version: ${version}: ${err.msg()}")
			semver.Version{}
		}

		res := c.check(&v) or { false }
		if res != expected {
			t.fail("expected: ${expected}, got: ${!expected} for input: ${input} and version: ${version}")
		}
	}
}

test "constraints creation" {
	cases := [
		(">= 1.1", 1, 1, false),
		(">40.50.60, < 50.70", 1, 2, false),
		("2.0", 1, 1, false),
		("v2.3.5-20161202202307-sha.e8fc5e5", 1, 1, false),
		(">= bar", 0, 0, true),
		("BAR >= 1.2.3", 0, 0, true),
		(">= 1.2.3 < 2.0", 1, 2, false),
		(">= 1.2.3 < 2.0 || => 3.0 < 4", 2, 2, false),
		(">= 1.2.3, < 2.0", 1, 2, false),
		(">= 1.2.3, < 2.0 || => 3.0, < 4", 2, 2, false),
		("3 - 4 || => 3.0, < 4", 2, 2, false),
		("12.3.4.1234", 0, 0, true),
		("12.23.4.1234", 0, 0, true),
		("12.3.34.1234", 0, 0, true),
		("12.3.34 ~1.2.3", 1, 2, false),
		("12.3.34~ 1.2.3", 0, 0, true),
		("1.0.0 - 2.0.0, <=2.0.0", 1, 3, false),
	]

	for case in cases {
		input, ors_count, first_or_count, should_error := case

		c := semver.Constraints.new(input) or {
			if should_error {
				continue
			}

			t.fail("unexpected error for input: ${input}: ${err.msg()}")
			semver.Constraints{}
		}

		if should_error {
			t.fail("expected error for input: ${input}")
			continue
		}

		if c.constraints.len != ors_count {
			t.fail("expected ors count: ${ors_count}, got: ${c.constraints.len} for input: ${input}")
		}

		if c.constraints[0].len != first_or_count {
			first := c.constraints[0]
			t.fail("expected first or count: ${first_or_count}, got: ${first.len} for input: ${input}")
		}
	}
}

test "constraints check" {
	cases := [
		("*", "1.2.3", true),
		("~0.0.0", "1.2.3", true),
		("0.x.x", "1.2.3", false),
		("0.0.x", "1.2.3", false),
		("0.0.0", "1.2.3", false),
		("*", "1.2.3", true),
		("^0.0.0", "1.2.3", false),
		("= 2.0", "1.2.3", false),
		("= 2.0", "2.0.0", true),
		("4.1", "4.1.0", true),
		("4.1.x", "4.1.3", true),
		("1.x", "1.4", true),
		("!=4.1", "4.1.0", false),
		("!=4.1-alpha", "4.1.0-alpha", false),
		("!=4.1-alpha", "4.1.1-alpha", false),
		("!=4.1-alpha", "4.1.0", true),
		("!=4.1", "5.1.0", true),
		("!=4.x", "5.1.0", true),
		("!=4.x", "4.1.0", false),
		("!=4.1.x", "4.2.0", true),
		("!=4.2.x", "4.2.3", false),
		(">1.1", "4.1.0", true),
		(">1.1", "1.1.0", false),
		("<1.1", "0.1.0", true),
		("<1.1", "1.1.0", false),
		("<1.1", "1.1.1", false),
		("<1.x", "1.1.1", false),
		("<1.x", "0.1.1", true),
		("<1.x", "2.0.0", false),
		("<1.1.x", "1.2.1", false),
		("<1.1.x", "1.1.500", false),
		("<1.1.x", "1.0.500", true),
		("<1.2.x", "1.1.1", true),
		(">=1.1", "4.1.0", true),
		(">=1.1", "4.1.0-beta", false),
		(">=1.1", "1.1.0", true),
		(">=1.1", "0.0.9", false),
		("<=1.1", "0.1.0", true),
		("<=1.1", "0.1.0-alpha", false),
		("<=1.1-a", "0.1.0-alpha", true),
		("<=1.1", "1.1.0", true),
		("<=1.x", "1.1.0", true),
		("<=2.x", "3.0.0", false),
		("<=1.1", "1.1.1", true),
		("<=1.1.x", "1.2.500", false),
		("<=4.5", "3.4.0", true),
		("<=4.5", "3.7.0", true),
		("<=4.5", "4.6.3", false),
		(">1.1, <2", "1.1.1", false),
		(">1.1, <2", "1.2.1", true),
		(">1.1, <3", "4.3.2", false),
		(">=1.1, <2, !=1.2.3", "1.2.3", false),
		(">1.1 <2", "1.1.1", false),
		(">1.1 <2", "1.2.1", true),
		(">1.1    <3", "4.3.2", false),
		(">=1.1    <2    !=1.2.3", "1.2.3", false),
		(">=1.1, <2, !=1.2.3 || > 3", "4.1.2", true),
		(">=1.1, <2, !=1.2.3 || > 3", "3.1.2", false),
		(">=1.1, <2, !=1.2.3 || >= 3", "3.0.0", true),
		(">=1.1, <2, !=1.2.3 || > 3", "3.0.0", false),
		(">=1.1, <2, !=1.2.3 || > 3", "1.2.3", false),
		(">=1.1 <2 !=1.2.3", "1.2.3", false),
		(">=1.1 <2 !=1.2.3 || > 3", "4.1.2", true),
		(">=1.1 <2 !=1.2.3 || > 3", "3.1.2", false),
		(">=1.1 <2 !=1.2.3 || >= 3", "3.0.0", true),
		(">=1.1 <2 !=1.2.3 || > 3", "3.0.0", false),
		(">=1.1 <2 !=1.2.3 || > 3", "1.2.3", false),
		("> 1.1, <     2", "1.1.1", false),
		(">   1.1, <2", "1.2.1", true),
		(">1.1, <  3", "4.3.2", false),
		(">= 1.1, <     2, !=1.2.3", "1.2.3", false),
		("> 1.1 < 2", "1.1.1", false),
		(">1.1 < 2", "1.2.1", true),
		("> 1.1    <3", "4.3.2", false),
		(">=1.1    < 2    != 1.2.3", "1.2.3", false),
		(">= 1.1, <2, !=1.2.3 || > 3", "4.1.2", true),
		(">= 1.1, <2, != 1.2.3 || > 3", "3.1.2", false),
		(">= 1.1, <2, != 1.2.3 || >= 3", "3.0.0", true),
		(">= 1.1, <2, !=1.2.3 || > 3", "3.0.0", false),
		(">= 1.1, <2, !=1.2.3 || > 3", "1.2.3", false),
		(">= 1.1 <2 != 1.2.3", "1.2.3", false),
		(">= 1.1 <2 != 1.2.3 || > 3", "4.1.2", true),
		(">= 1.1 <2 != 1.2.3 || > 3", "3.1.2", false),
		(">= 1.1 <2 != 1.2.3 || >= 3", "3.0.0", true),
		(">= 1.1 < 2 !=1.2.3 || > 3", "3.0.0", false),
		(">=1.1 < 2 !=1.2.3 || > 3", "1.2.3", false),
		("1.1 - 2", "1.1.1", true),
		("1.5.0 - 4.5", "3.7.0", true),
		("1.1-3", "4.3.2", false),
		("^1.1", "1.1.1", true),
		("^1.1", "4.3.2", false),
		("^1.x", "1.1.1", true),
		("^2.x", "1.1.1", false),
		("^1.x", "2.1.1", false),
		("^1.x", "1.1.1-beta1", false),
		("^1.1.2-alpha", "1.2.1-beta1", true),
		("^1.2.x-alpha", "1.1.1-beta1", false),
		("^0.0.1", "0.0.1", true),
		("^0.0.1", "0.3.1", false),
		("~*", "2.1.1", true),
		("~1", "2.1.1", false),
		("~1", "1.3.5", true),
		("~1", "1.4", true),
		("~1.x", "2.1.1", false),
		("~1.x", "1.3.5", true),
		("~1.x", "1.4", true),
		("~1.1", "1.1.1", true),
		("~1.1", "1.1.1-alpha", false),
		("~1.1-alpha", "1.1.1-beta", true),
		("~1.1.1-beta", "1.1.1-alpha", false),
		("~1.1.1-beta", "1.1.1", true),
		("~1.2.3", "1.2.5", true),
		("~1.2.3", "1.2.2", false),
		("~1.2.3", "1.3.2", false),
		("~1.1", "1.2.3", false),
		("~1.3", "2.4.5", false),
		("1.0.0 - 2.0.0 <=2.0.0", "1.5.0", true),
		("1.0.0 - 2.0.0, <=2.0.0", "1.5.0", true),
	]

	for case in cases {
		input, version, expected := case

		c := semver.Constraints.new(input) or {
			t.fail("unexpected error for input: ${input}: ${err.msg()}")
			semver.Constraints{}
		}

		v := semver.Version.parse(version) or {
			t.fail("unexpected error for version: ${version}: ${err.msg()}")
			semver.Version{}
		}

		res := c.check(&v)
		if res != expected {
			t.fail("expected: ${expected}, got: ${!expected} for input: ${input} and version: ${version}")
		}
	}
}

test "rewrite range in constraint" {
	cases := [
		("2 - 3", ">= 2, <= 3 "),
		("2 - 3, 2 - 3", ">= 2, <= 3 ,>= 2, <= 3 "),
		("2 - 3, 4.0.0 - 5.1", ">= 2, <= 3 ,>= 4.0.0, <= 5.1 "),
		("2 - 3 4.0.0 - 5.1", ">= 2, <= 3 >= 4.0.0, <= 5.1 "),
		("1.0.0 - 2.0.0 <=2.0.0", ">= 1.0.0, <= 2.0.0 <=2.0.0"),
	]

	for case in cases {
		input, expected := case

		res := semver.rewrite_range(input)
		if res != expected {
			t.fail("expected: ${expected}, got: ${res} for input: ${input}")
		}
	}
}

test "constraint to string" {
	cases := [
		("*", "*"),
		(">=1.2.3", ">=1.2.3"),
		(">= 1.2.3", ">=1.2.3"),
		("2.x,   >=1.2.3 || >4.5.6, < 5.7", "2.x >=1.2.3 || >4.5.6 <5.7"),
		("2.x,   >=1.2.3 || >4.5.6, < 5.7 || >40.50.60, < 50.70", "2.x >=1.2.3 || >4.5.6 <5.7 || >40.50.60 <50.70"),
		("1.2", "1.2"),
	]

	for case in cases {
		input, expected := case

		c := semver.Constraints.new(input) or {
			t.fail("unexpected error for input: ${input}: ${err.msg()}")
			semver.Constraints{}
		}

		res := c.encode()
		if res != expected {
			t.fail("expected: ${expected}, got: ${res} for input: ${input}")
		}

		semver.Constraints.new(res) or {
			t.fail("encoded constraint is invalid: ${res}")
		}
	}
}
