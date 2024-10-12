module main

import semver

test "strict parsing of version" {
	cases := [
		("1.2.3", false),
		("1.2.3-alpha.01", true),
		("1.2.3+test.01", false),
		("1.2.3-alpha.-1", false),
		("v1.2.3", true),
		("1.0", true),
		("v1.0", true),
		("1", true),
		("v1", true),
		("1.2.beta", true),
		("v1.2.beta", true),
		("foo", true),
		("1.2-5", true),
		("v1.2-5", true),
		("1.2-beta.5", true),
		("v1.2-beta.5", true),
		("\n1.2", true),
		("\nv1.2", true),
		("1.2.0-x.Y.0+metadata", false),
		("v1.2.0-x.Y.0+metadata", true),
		("1.2.0-x.Y.0+metadata-width-hypen", false),
		("v1.2.0-x.Y.0+metadata-width-hypen", true),
		("1.2.3-rc1-with-hypen", false),
		("v1.2.3-rc1-with-hypen", true),
		("1.2.3.4", true),
		("v1.2.3.4", true),
		("1.2.2147483648", false),
		("1.2147483648.3", false),
		("2147483648.3.0", false),
		("20221209-update-renovatejson-v4", true),
	]

	for case in cases {
		input, should_error := case
		_ = semver.parse_strict(input) or {
			if should_error {
				continue
			}

			t.fail("unexpected error for input: ${input}: ${err.msg()}")
			semver.Version{}
		}

		if should_error {
			t.fail("expected error for input: ${input}")
		}
	}
}

test "non strict parsing of version" {
	cases := [
		("1.2.3", false),
		("1.2.3-alpha.01", true),
		("1.2.3+test.01", false),
		("1.2.3-alpha.-1", false),
		("v1.2.3", false),
		("1.0", false),
		("v1.0", false),
		("1", false),
		("v1", false),
		("1.2.beta", true),
		("v1.2.beta", true),
		("foo", true),
		("1.2-5", false),
		("v1.2-5", false),
		("1.2-beta.5", false),
		("v1.2-beta.5", false),
		("\n1.2", true),
		("\nv1.2", true),
		("1.2.0-x.Y.0+metadata", false),
		("v1.2.0-x.Y.0+metadata", false),
		("1.2.0-x.Y.0+metadata-width-hypen", false),
		("v1.2.0-x.Y.0+metadata-width-hypen", false),
		("1.2.3-rc1-with-hypen", false),
		("v1.2.3-rc1-with-hypen", false),
		("1.2.3.4", true),
		("v1.2.3.4", true),
		("1.2.2147483648", false),
		("1.2147483648.3", false),
		("2147483648.3.0", false),
		("12.3.4.1234", true),
		("12.23.4.1234", true),
		("12.3.34.1234", true),
		("20221209-update-renovatejson-v4", false),
	]

	for case in cases {
		input, should_error := case
		_ = semver.parse(input) or {
			if should_error {
				continue
			}

			t.fail("unexpected error for input: ${input}: ${err.msg()}")
			semver.Version{}
		}

		if should_error {
			t.fail("expected error for input: ${input}")
		}
	}
}

test "manual creation of version" {
	v1 := semver.Version.new(1, 2, 3, "", "")
	t.assert_eq(v1.encode(), "1.2.3", "unexpected version encoding")

	v2 := semver.Version.new(1, 2, 3, "alpha.01", "test.01")
	t.assert_eq(v2.encode(), "1.2.3-alpha.01+test.01", "unexpected version encoding")
}

test "parts of version" {
	v := semver.parse("1.2.3-beta.1+build.123").unwrap()
	t.assert_eq(v.major, 1, "unexpected major version")
	t.assert_eq(v.minor, 2, "unexpected minor version")
	t.assert_eq(v.patch, 3, "unexpected patch version")
	t.assert_eq(v.prerelease, "beta.1", "unexpected prerelease version")
	t.assert_eq(v.metadata, "build.123", "unexpected metadata version")
}

test "coerce versions" {
	cases := [
		("1.2.3", "1.2.3"),
		("v1.2.3", "1.2.3"),
		("1.0", "1.0.0"),
		("v1.0", "1.0.0"),
		("1", "1.0.0"),
		("v1", "1.0.0"),
		("1.2-5", "1.2.0-5"),
		("v1.2-5", "1.2.0-5"),
		("1.2-beta.5", "1.2.0-beta.5"),
		("v1.2-beta.5", "1.2.0-beta.5"),
		("1.2.0-x.Y.0+metadata", "1.2.0-x.Y.0+metadata"),
		("v1.2.0-x.Y.0+metadata", "1.2.0-x.Y.0+metadata"),
		("1.2.0-x.Y.0+metadata-width-hypen", "1.2.0-x.Y.0+metadata-width-hypen"),
		("v1.2.0-x.Y.0+metadata-width-hypen", "1.2.0-x.Y.0+metadata-width-hypen"),
		("1.2.3-rc1-with-hypen", "1.2.3-rc1-with-hypen"),
		("v1.2.3-rc1-with-hypen", "1.2.3-rc1-with-hypen"),
	]

	for case in cases {
		input, expected := case
		v := semver.parse(input).unwrap()
		t.assert_eq(v.encode(), expected, "unexpected version encoding")
	}
}

test "compare versions" {
	cases := [
		("1.2.3", "1.5.1", -1),
		("2.2.3", "1.5.1", 1),
		("2.2.3", "2.2.2", 1),
		("3.2-beta", "3.2-beta", 0),
		("1.3", "1.1.4", 1),
		("4.2", "4.2-beta", 1),
		("4.2-beta", "4.2", -1),
		("4.2-alpha", "4.2-beta", -1),
		("4.2-alpha", "4.2-alpha", 0),
		("4.2-beta.2", "4.2-beta.1", 1),
		("4.2-beta2", "4.2-beta1", 1),
		("4.2-beta", "4.2-beta.2", -1),
		("4.2-beta", "4.2-beta.foo", -1),
		("4.2-beta.2", "4.2-beta", 1),
		("4.2-beta.foo", "4.2-beta", 1),
		("1.2+bar", "1.2+baz", 0),
		("1.0.0-beta.4", "1.0.0-beta.-2", -1),
		("1.0.0-beta.-2", "1.0.0-beta.-3", -1),
		("1.0.0-beta.-3", "1.0.0-beta.5", 1),
	]

	for case in cases {
		v1_str, v2_str, expected := case
		v1 := semver.parse(v1_str).unwrap()
		v2 := semver.parse(v2_str).unwrap()
		t.assert_eq(v1.compare(&v2), expected, "unexpected comparison result for ${v1_str} and ${v2_str}")
	}
}

test "less that versions" {
	cases := [
		("1.2.3", "1.5.1", true),
		("2.2.3", "1.5.1", false),
		("3.2-beta", "3.2-beta", false),
	]

	for case in cases {
		v1_str, v2_str, expected := case
		v1 := semver.parse(v1_str).unwrap()
		v2 := semver.parse(v2_str).unwrap()
		t.assert_eq(v1.less(&v2), expected, "unexpected comparison result for ${v1_str} and ${v2_str}")
	}
}

test "greater that versions" {
	cases := [
		("1.2.3", "1.5.1", false),
		("2.2.3", "1.5.1", true),
		("3.2-beta", "3.2-beta", false),
		("3.2.0-beta.1", "3.2.0-beta.5", false),
		("3.2-beta.4", "3.2-beta.2", true),
		("7.43.0-SNAPSHOT.99", "7.43.0-SNAPSHOT.103", false),
		("7.43.0-SNAPSHOT.FOO", "7.43.0-SNAPSHOT.103", true),
		("7.43.0-SNAPSHOT.99", "7.43.0-SNAPSHOT.BAR", false),
	]

	for case in cases {
		v1_str, v2_str, expected := case
		v1 := semver.parse(v1_str).unwrap()
		v2 := semver.parse(v2_str).unwrap()
		t.assert_eq(v1.greater(&v2), expected, "unexpected comparison result for ${v1_str} and ${v2_str}")
	}
}

test "greater equal versions" {
	cases := [
		("1.2.3", "1.5.1", false),
		("2.2.3", "1.5.1", false),
		("3.2-beta", "3.2-beta", true),
		("3.2.0-beta.1", "3.2.0-beta.5", false),
		("3.2-beta.4", "3.2-beta.2", false),
		("7.43.0-SNAPSHOT.99", "7.43.0-SNAPSHOT.103", false),
		("7.43.0-SNAPSHOT.FOO", "7.43.0-SNAPSHOT.103", false),
		("7.43.0-SNAPSHOT.99", "7.43.0-SNAPSHOT.BAR", false),
	]

	for case in cases {
		v1_str, v2_str, expected := case
		v1 := semver.parse(v1_str).unwrap()
		v2 := semver.parse(v2_str).unwrap()
		t.assert_eq(v1.equal(&v2), expected, "unexpected comparison result for ${v1_str} and ${v2_str}")
	}
}

test "inc versions" {
	cases := [
		("1.2.3", "1.2.4", semver.Increment.patch),
		("v1.2.4", "1.2.5", semver.Increment.patch),
		("1.2.3", "1.3.0", semver.Increment.minor),
		("v1.2.4", "1.3.0", semver.Increment.minor),
		("1.2.3", "2.0.0", semver.Increment.major),
		("v1.2.4", "2.0.0", semver.Increment.major),
		("1.2.3+meta", "1.2.4", semver.Increment.patch),
		("1.2.3-beta+meta", "1.2.3", semver.Increment.patch),
		("v1.2.4-beta+meta", "1.2.4", semver.Increment.patch),
		("1.2.3-beta+meta", "1.3.0", semver.Increment.minor),
		("v1.2.4-beta+meta", "1.3.0", semver.Increment.minor),
		("1.2.3-beta+meta", "2.0.0", semver.Increment.major),
		("v1.2.4-beta+meta", "2.0.0", semver.Increment.major),
	]

	for case in cases {
		actual, expected, how := case
		ver := semver.parse(actual).unwrap()
		t.assert_eq(ver.inc(how).encode(), expected, "unexpected increment result for ${actual}")
	}
}
