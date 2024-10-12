module semver

import strings

// This module based on https://github.com/Masterminds/semver

// Version represents a single semantic version.
pub struct Version {
	original   string
	major      u64
	minor      u64
	patch      u64
	prerelease string
	metadata   string
}

// new creates a new version from the given major, minor, patch,
// prerelease and metadata.
//
// To parse a version string use [`parse`].
pub fn Version.new(major u64, minor u64, patch u64, prerelease string, metadata string) -> Version {
	mut v := Version{
		major: major
		minor: minor
		patch: patch
		prerelease: prerelease
		metadata: metadata
	}
	v.original = v.encode()
	return v
}

// Increment is an enum type that defines the increment type
// for [`Version.inc`] method.
pub enum Increment {
	major
	minor
	patch
}

// inc increments the version by the given increment type.
pub fn (v &Version) inc(what Increment) -> Version {
	return match what {
		.major => v.inc_major()
		.minor => v.inc_minor()
		.patch => v.inc_patch()
	}
}

// inc_patch produces the next patch version.
//
// If the current version does not have prerelease/metadata information,
// it unsets metadata and prerelease values, increments patch number.
// If the current version has any of prerelease or metadata information,
// it unsets both values and keeps current patch value
pub fn (v &Version) inc_patch() -> Version {
	mut next := *v

	// according to http://semver.org/#spec-item-9
	// Pre-release versions have a lower precedence than the associated normal version.
	// according to http://semver.org/#spec-item-10
	// Build metadata SHOULD be ignored when determining version precedence.
	if v.prerelease != '' {
		next.prerelease = ''
		next.metadata = ''
	} else {
		next.prerelease = ''
		next.metadata = ''
		next.patch += 1
	}

	next.original = next.encode()
	return next
}

// inc_minor produces the next minor version.
//
// Sets patch to 0.
// Increments minor number.
// Unsets metadata.
// Unsets prerelease status.
pub fn (v &Version) inc_minor() -> Version {
	mut next := *v
	next.patch = 0
	next.minor += 1
	next.metadata = ''
	next.prerelease = ''
	next.original = next.encode()
	return next
}

// inc_major produces the next major version.
//
// Sets patch to 0.
// Sets minor to 0.
// Increments major number.
// Unsets metadata.
// Unsets prerelease status.
pub fn (v &Version) inc_major() -> Version {
	mut next := *v
	next.patch = 0
	next.minor = 0
	next.major += 1
	next.metadata = ''
	next.prerelease = ''
	next.original = next.encode()
	return next
}

// set_prerelease defines the prerelease value.
//
// If prerelease is not empty it must be a valid prerelease string.
// Value must not include the required 'hyphen' prefix.
pub fn (v &Version) set_prerelease(prerelease string) -> !Version {
	mut next := *v
	if prerelease.len > 0 {
		validate_prerelease(prerelease)!
	}
	next.prerelease = prerelease
	next.original = next.encode()
	return next
}

// set_metadata defines the metadata value.
//
// If metadata is not empty it must be a valid metadata string.
// Value must not include the required 'plus' prefix.
pub fn (v &Version) set_metadata(metadata string) -> !Version {
	mut next := *v
	if metadata.len > 0 {
		validate_metadata(metadata)!
	}
	next.metadata = metadata
	next.original = next.encode()
	return next
}

// encode returns string representation of the version.
//
// The format is:
// `major.minor.patch[-prerelease][+metadata]`
//
// Note, if the original version contained a leading v this version will not.
// See the [`Version.original`] method to retrieve the original value. Semantic Versions
// don't contain a leading v per the spec. Instead it's optional on implementation.
//
// Example:
// ```
// v := Version.new(1, 2, 3, "alpha", "build")
// assert v.encode() == "1.2.3-alpha+build"
// ```
pub fn (v &Version) encode() -> string {
	mut sb := strings.new_builder(20)
	sb.write_str(v.major.str())
	sb.write_u8(b`.`)
	sb.write_str(v.minor.str())
	sb.write_u8(b`.`)
	sb.write_str(v.patch.str())

	if v.prerelease != '' {
		sb.write_u8(b`-`)
		sb.write_str(v.prerelease)
	}

	if v.metadata != '' {
		sb.write_u8(b`+`)
		sb.write_str(v.metadata)
	}

	return sb.str_view()
}

// str returns the string representation of the version.
pub fn (v &Version) str() -> string {
	return v.encode()
}

// original returns the original version string that was parsed to
// create this version.
//
// If the version was created with [`Version.new`] this will be the
// same as the value returned by [`Version.encode`].
pub fn (v &Version) original() -> string {
	return v.original
}
