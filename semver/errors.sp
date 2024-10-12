module semver

pub struct EmptyInputError {}

pub fn (_ EmptyInputError) msg() -> string {
	return 'Empty input'
}

pub struct InvalidVersionFormatError {
	input string
}

pub fn (e InvalidVersionFormatError) msg() -> string {
	return 'Invalid version format: ${e.input}'
}

pub struct ErrInvalidCharacters {
	input string
}

pub fn (e ErrInvalidCharacters) msg() -> string {
	return 'Invalid characters in version: ${e.input}'
}

pub struct ErrSegmentStartsZero {
	segment string
}

pub fn (e ErrSegmentStartsZero) msg() -> string {
	return 'Version segment starts with zero: ${e.segment}'
}

pub struct ErrInvalidPrerelease {
	input string
}

pub fn (e ErrInvalidPrerelease) msg() -> string {
	return 'Invalid prerelease: ${e.input}'
}

pub struct ErrInvalidMetadata {
	input string
}

pub fn (e ErrInvalidMetadata) msg() -> string {
	return 'Invalid metadata: ${e.input}'
}

pub struct ErrInvalidConstraint {
	input string
}

pub fn (e ErrInvalidConstraint) msg() -> string {
	return 'Invalid constraint: ${e.input}'
}

pub struct ConstraintNotSatisfied {
	constraint Constraint
	version    Version
	reason     string
}

pub fn ConstraintNotSatisfied.new(c Constraint, v Version, reason string) -> ConstraintNotSatisfied {
	return ConstraintNotSatisfied{
		constraint: c
		version: v
		reason: reason
	}
}

pub fn (e ConstraintNotSatisfied) msg() -> string {
	return 'Constraint not satisfied: ${e.constraint} vs ${e.version.encode()} (${e.reason})'
}

pub struct ConstraintValidationError {
	errs []ConstraintNotSatisfied
}

pub fn (e ConstraintValidationError) msg() -> string {
	return 'Check is failed because:\n${e.errs.map(|e1| e1.msg()).join('\n')}'
}
