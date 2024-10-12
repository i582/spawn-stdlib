module semver

// satisfies checks if the version satisfies the given constraint.
// The constraint is a string that can be a simple version or a range.
// See [`Constraints.new`] for more information on the constraint format.
//
// Example:
// ```
// v := Version.parse("1.2.3").unwrap()
// if v.satisfies(">=1.0.0") {
//    // do something
// }
// ```
pub fn (v &Version) satisfies(c string) -> bool {
	cons := Constraints.new(c) or { return false }
	return cons.check(v)
}

// less tests if this version is less than another version.
//
// Example:
// ```
// v1 := Version.parse("1.2.3").unwrap()
// v2 := Version.parse("1.2.4").unwrap()
// if v1.less(v2) {
//   // do something
// }
// // or
// if v1 < v2 {
//   // do something
// }
// ```
pub fn (v &Version) less(o &Version) -> bool {
	return v.compare(o) == -1
}

// greater tests if this version is greater than another version.
//
// Example:
// ```
// v1 := Version.parse("1.2.3").unwrap()
// v2 := Version.parse("1.2.4").unwrap()
// if v2.greater(v1) {
//   // do something
// }
// // or
// if v2 > v1 {
//   // do something
// }
// ```
pub fn (v &Version) greater(o &Version) -> bool {
	return v.compare(o) == 1
}

// equal tests if two versions are equal to each other.
//
// Note, versions can be equal with different metadata since metadata
// is not considered part of the comparable version.
//
// Example:
// ```
// v1 := Version.parse("1.2.3").unwrap()
// v2 := Version.parse("1.2.3").unwrap()
// if v1.equal(v2) {
//   // do something
// }
// // or
// if v1 == v2 {
//   // do something
// }
// ```
pub fn (v &Version) equal(o &Version) -> bool {
	if v as *Version as usize == o as *Version as usize {
		// fast path, both references are the same
		return true
	}

	return v.compare(o) == 0
}

// compare compares this version to another one. It returns -1, 0, or 1 if
// the version smaller, equal, or larger than the other version.
//
// Versions are compared by X.Y.Z. Build metadata is ignored. Prerelease is
// lower than the version without a prerelease. Compare always takes into account
// prereleases. If you want to work with ranges using typical range syntaxes that
// skip prereleases if the range is not looking for them use constraints.
//
// Example:
// ```
// v1 := Version.parse("1.2.3").unwrap()
// v2 := Version.parse("1.2.4").unwrap()
// match v1.compare(v2) {
//     -1 -> println("v1 is less than v2")
//     0 -> println("v1 is equal to v2")
//     1 -> println("v1 is greater than v2")
// }
// ```
pub fn (v &Version) compare(o &Version) -> i32 {
	mjr := compare_segment(v.major, o.major)
	if mjr != 0 {
		return mjr
	}

	mnr := compare_segment(v.minor, o.minor)
	if mnr != 0 {
		return mnr
	}

	patch := compare_segment(v.patch, o.patch)
	if patch != 0 {
		return patch
	}

	ps := v.prerelease
	po := o.prerelease

	if ps == "" && po == "" {
		return 0
	}

	if ps == "" {
		return 1
	}

	if po == "" {
		return -1
	}

	return compare_prerelease(ps, po)
}

fn compare_prerelease(v string, o string) -> i32 {
	// split the prerelease versions by their part. The separator, per the spec, is a `.`
	sparts := v.split(".")
	oparts := o.split(".")

	// find the longer length of the parts to know how many loop iterations to
	// go through.

	slen := sparts.len
	olen := oparts.len

	l := olen.max(slen)

	for i in 0 .. l {
		// since the length of the parts can be different we need to create
		// a placeholder. This is to avoid out of bounds issues.
		mut stemp := ""
		if i < slen {
			stemp = sparts[i]
		}

		mut otemp := ""
		if i < olen {
			otemp = oparts[i]
		}

		d := compare_pre_part(stemp, otemp)
		if d != 0 {
			return d
		}
	}

	// reaching here means two versions are of equal value but have different
	// metadata (the part following a +). They are not identical in string form
	// but the version comparison finds them to be equal.
	return 0
}

fn compare_pre_part(s string, o string) -> i32 {
	if s == o {
		// fast path
		return 0
	}

	if s == "" {
		return -1
	}

	if o == "" {
		return 1
	}

	// When comparing strings "99" is greater than "103". To handle
	// cases like this we need to detect numbers and compare them. According
	// to the semver spec, numbers are always positive. If there is a - at the
	// start like -99 this is to be evaluated as an alphanum. numbers always
	// have precedence over alphanum. Parsing as uint because negative numbers
	// are ignored.

	s_parsed := s.parse_uint()
	o_parsed := o.parse_uint()

	// both are numbers
	if s_parsed != none && o_parsed != none {
		if s_parsed > o_parsed {
			return 1
		}
		return -1
	}

	// both are strings
	if s_parsed == none && o_parsed == none {
		if s > o {
			return 1
		}
		return -1
	}

	if o_parsed == none {
		// o is string and s is number
		return -1
	}

	if s_parsed == none {
		// s is string and o is number
		return 1
	}

	return 0
}

fn compare_segment(v u64, o u64) -> i32 {
	return if v < o { -1 } else if v > o { 1 } else { 0 }
}
