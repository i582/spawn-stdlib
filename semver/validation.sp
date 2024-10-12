module semver

const ALLOWED_CHARS = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-"

fn parse_num(input string) -> !u64 {
	return input.parse_uint() or {
		return error(ErrInvalidCharacters{ input: input })
	}
}

// validate_prerelease validates the prerelease segment of a version.
//
// From the spec:
// "Identifiers MUST comprise only ASCII alphanumerics and hyphen `[0-9A-Za-z-]`.
// Identifiers MUST NOT be empty. Numeric identifiers MUST NOT include leading zeroes.".
//
// These segments can be dot separated.
fn validate_prerelease(input string) -> ! {
	parts := input.split('.')
	for part in parts {
		if validate_num(part) {
			if part.len > 1 && part[0] == b`0` {
				return error(ErrSegmentStartsZero{ segment: part })
			}
			continue
		}

		if !validate_input(part) {
			return error(ErrInvalidPrerelease{ input: part })
		}
	}
}

// validate_metadata validates the build metadata segment of a version.
//
// From the spec:
// "Build metadata MAY be denoted by appending a plus sign and a series of dot
// separated identifiers immediately allowing the patch or pre-release version.
// Identifiers MUST comprise only ASCII alphanumerics and hyphen `[0-9A-Za-z-]`.
// Identifiers MUST NOT be empty."
fn validate_metadata(input string) -> ! {
	parts := input.split('.')
	for part in parts {
		if !validate_input(part) {
			return error(ErrInvalidMetadata{ input: part })
		}
	}
}

fn validate_input(input string) -> bool {
	for c in input {
		if !ALLOWED_CHARS.contains_u8(c) {
			return false
		}
	}

	return true
}

fn validate_num(input string) -> bool {
	for c in input {
		if !c.is_digit() {
			return false
		}
	}

	return true
}
