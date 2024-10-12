module semver

// parse_strict parses a string into a [`Version`] struct.
// If the input is not a valid semver version, function returns an error.
//
// Example:
// ```
// version := semver.parse("1.2.3").unwrap()
// assert version.inc(.major).encode() == "2.0.0"
// ```
pub fn parse_strict(input string) -> !Version {
	return Version.parse_strict(input)
}

// parse parses a string into a [`Version`] struct.
// If the version is SemVer-ish it attempts to convert it to SemVer.
//
// See [`Version.parse_strict`] if you want to strictly parse a SemVer version.
//
// Example:
// ```
// version := semver.parse("1.2").unwrap()
// assert version.inc(.major).encode() == "2.0.0"
// ```
pub fn parse(input string) -> !Version {
	return Version.parse(input)
}

// parse_strict parses a string into a [`Version`] struct.
// If the input is not a valid semver version, function returns an error.
//
// See [`Version.parse`] for a more relaxed version of this function.
//
// Example:
// ```
// version := semver.parse("1.2.3").unwrap()
// assert version.inc(.major).encode() == "2.0.0"
// ```
pub fn Version.parse_strict(input string) -> !Version {
	if input.len == 0 {
		return error(EmptyInputError{})
	}

	// split the input into parts:
	// 0. version
	// 1. prerelease
	// 2. path, prerelease, build
	mut parts := input.split_nth('.', 3)
	if parts.len != 3 {
		return error(InvalidVersionFormatError{ input: input })
	}

	mut v := Version{
		original: input
	}

	if parts[2].contains_any("+-") {
		// start with the build metadata first as it needs to be on the right
		extra := parts[2].split_nth('+', 2)
		if extra.len > 1 {
			// build metadata found
			v.metadata = extra[1]
			parts[2] = extra[0]
		}

		extra2 := parts[2].split_nth('-', 2)
		if extra2.len > 1 {
			// prerelease found
			v.prerelease = extra2[1]
			parts[2] = extra2[0]
		}
	}

	// validate the number segments are valid. This includes only having positive
	// numbers and no leading 0's.
	for part in parts {
		if !validate_num(part) {
			return error(ErrInvalidCharacters{ input: part })
		}

		if part.len > 1 && part[0] == b`0` {
			return error(ErrSegmentStartsZero{ segment: part })
		}
	}

	v.major = parse_num(parts[0])!
	v.minor = parse_num(parts[1])!
	v.patch = parse_num(parts[2])!

	if v.prerelease == '' && v.metadata == '' {
		// no prerelease or build metadata found so returning now as a fastpath.
		return v
	}

	if v.prerelease != "" {
		// validate the prerelease segment
		validate_prerelease(v.prerelease)!
	}

	if v.metadata != "" {
		// validate the metadata segment
		validate_metadata(v.metadata)!
	}

	return v
}

// parse parses a string into a [`Version`] struct.
// If the version is SemVer-ish it attempts to convert it to SemVer.
//
// See [`Version.parse_strict`] if you want to strictly parse a SemVer version.
//
// Example:
// ```
// version := semver.parse("1.2").unwrap()
// assert version.inc(.major).encode() == "2.0.0"
// ```
pub fn Version.parse(input string) -> !Version {
	md := VERSION_REGEX.find_match(input, 0) or {
		return error(InvalidVersionFormatError{ input: input })
	}

	mut v := Version{
		original: input
		metadata: md.get(8) or { "" }
		prerelease: md.get(5) or { "" }
	}

	v.major = parse_num(md.get(1) or { "0" })!
	second := md.get(2) or { "" }
	if second != "" {
		v.minor = parse_num(second.trim_prefix("."))!
	}

	third := md.get(3) or { "" }
	if third != "" {
		v.patch = parse_num(third.trim_prefix("."))!
	}

	// perform some basic due diligence on the extra parts to ensure they are valid.

	if v.prerelease != "" {
		validate_prerelease(v.prerelease)!
	}

	if v.metadata != "" {
		validate_metadata(v.metadata)!
	}

	return v
}
