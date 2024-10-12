module semver

import regex
import strings

const (
	CV_REGEX = r'v?([0-9|x|X|\*]+)(\.[0-9|x|X|\*]+)?(\.[0-9|x|X|\*]+)?(-([0-9A-Za-z\-]+(\.[0-9A-Za-z\-]+)*))?(\+([0-9A-Za-z\-]+(\.[0-9A-Za-z\-]+)*))?'
	OPS      = "=||!=|>|<|>=|=>|<=|=<|~|~>|\\^"
)

const (
	VERSION_REGEX          = regex.must_compile("^${CV_REGEX}$")
	CONSTRAINT_REGEX       = regex.must_compile('^\\s*(${OPS})\\s*(${CV_REGEX})\\s*$')
	CONSTRAINT_RANGE_REGEX = regex.must_compile('\\s*(${CV_REGEX})\\s+-\\s+(${CV_REGEX})\\s*')
	FIND_CONSTRAINT_REGEX  = regex.must_compile('(${OPS})\\s*(${CV_REGEX})')
	VALID_CONSTRAINT_REGEX = regex.must_compile('^(\\s*(${OPS})\\s*(${CV_REGEX})\\s*)((?:\\s+|,\\s*)(${OPS})\\s*(${CV_REGEX})\\s*)*$')
)

// Constraints is one or more constraint that a semantic version can be
// checked against.
pub struct Constraints {
	constraints [][]Constraint
}

// new creates a new instance of Constraints. The input is a string that
// contains one or more constraints separated by a double pipe (||). Each
// constraint is a string that can contain multiple constraints separated by
// a comma.
//
// Example:
// ```
// ver := Version.parse("1.5.0").unwrap()
// c := Constraints.new(">= 1.0.0, < 2.0.0 || >= 3.0.0").unwrap()
// assert c.check(&ver)
// ```
pub fn Constraints.new(input string) -> !Constraints {
	parts := rewrite_range(input.trim_spaces()).split('||').map(|s| s.trim_spaces())

	mut ors := [][]Constraint{len: parts.len}

	for i, part in parts {
		mut result := []Constraint{}

		if part.len == 0 {
			result.push(Constraint.parse("")!)
			continue
		}

		if !VALID_CONSTRAINT_REGEX.matches(part) {
			return error(ErrInvalidConstraint{ input: part })
		}

		mut cs := FIND_CONSTRAINT_REGEX.find_all(part)
		if cs.len == 0 {
			cs.push(part)
		}

		result.ensure_cap(cs.len)

		for c in cs {
			result.push(Constraint.parse(c)!)
		}

		ors[i] = result
	}

	return Constraints{ constraints: ors }
}

// check tests if a version satisfies the constraints.
//
// Example:
// ```
// ver := Version.parse("1.5.0").unwrap()
// c := Constraints.new(">= 1.0.0, < 2.0.0 || >= 3.0.0").unwrap()
// assert c.check(&ver)
// ```
pub fn (c Constraints) check(v &Version) -> bool {
	for o in c.constraints {
		mut result := true
		for single_constraint in o {
			result = single_constraint.check(v) or { false }
			if !result {
				result = false
				break
			}
		}

		if result {
			return true
		}
	}

	return false
}

// validate checks if a version satisfies a constraint. If not an error
// with array of reasons for the failure are returned.
//
// Example:
// ```
// ver := Version.parse("1.5.0").unwrap()
// c := Constraints.new(">= 1.0.0, < 2.0.0 || >= 3.0.0").unwrap()
// res := c.validate(&ver) or {
//   for reason in err.errs {
//     println(reason)
//   }
// }
// ```
pub fn (c Constraints) validate(v &Version) -> ![bool, ConstraintValidationError] {
	mut errs := []ConstraintNotSatisfied{}

	// capture the prerelease message only once. When it happens the first time
	// this var is marked
	mut prerelease := false

	for o in c.constraints {
		mut result := true
		for single_constraint in o {
			// before running the check handle the case there the version is
			// a prerelease and the check is not searching for prereleases.
			if single_constraint.con.prerelease == "" && v.prerelease != "" {
				if !prerelease {
					errs.push(ConstraintNotSatisfied.new(single_constraint, *v, "prerelease version and the constraint is only looking for release versions"))
					prerelease = true
				}
				result = false
				continue
			}

			result = single_constraint.check(v) or {
				errs.push(err)
				false
			}
			if !result {
				result = false
			}
		}

		if result {
			return true
		}
	}

	return error(ConstraintValidationError{ errs: errs })
}

// encode returns a string representation of the constraints.
//
// Example:
// ```
// c := Constraints.new(">= 1.0.0, < 2.0.0 || >= 3.0.0").unwrap()
// println(c.encode()) // >= 1.0.0, < 2.0.0 || >= 3.0.0
// ```
pub fn (c Constraints) encode() -> string {
	mut sb := strings.new_builder(100)
	for i, o in c.constraints {
		if i > 0 {
			sb.write_str(" || ")
		}

		for j, single_constraint in o {
			if j > 0 {
				sb.write_str(" ")
			}

			sb.write_str(single_constraint.str())
		}
	}

	return sb.str_view()
}

struct Constraint {
	// con is the version used in the constraint check. For example, if a constraint
	// is '<= 2.0.0' the con a version instance representing 2.0.0.
	con Version

	// orig is the original parsed version (e.g., 4.x from != 4.x)
	orig string

	// orig_func is the original operator for the constraint
	orig_func string

	// When an x is used as part of the version (e.g., 1.x)
	minor_dirty bool
	dirty       bool
	patch_dirty bool
}

fn Constraint.parse(input string) -> !Constraint {
	if input == "" {
		// special case where an empty string was passed in which
		// is equivalent to * or >=0.0.0

		ver := Version.new(0, 0, 0, "", "")

		return Constraint{
			con: ver
			orig: input
			orig_func: ""
			minor_dirty: false
			dirty: true
			patch_dirty: false
		}
	}

	md := CONSTRAINT_REGEX.find_match(input, 0) or {
		return error(ErrInvalidConstraint{ input: input })
	}

	m := md.get_all()

	mut cs := Constraint{
		orig: m[2]
		orig_func: m[1]
	}

	mut ver := m[2]
	mut minor_dirty := false
	mut patch_dirty := false
	mut dirty := false

	if is_x(m[3]) || m[3].len == 0 {
		six := m[6]
		ver = "0.0.0${six}"

		dirty = true
	} else if is_x(m[4].trim_start('.')) || m[4].len == 0 {
		six := m[6]
		three := m[3]
		ver = '${three}.0.0${six}'

		minor_dirty = true
		dirty = true
	} else if is_x(m[5].trim_start('.')) || m[5].len == 0 {
		three := m[3]
		four := m[4]
		six := m[6]
		ver = '${three}${four}.0${six}'

		patch_dirty = true
		dirty = true
	}

	con := Version.parse(ver)!
	cs.con = con
	cs.minor_dirty = minor_dirty
	cs.dirty = dirty
	cs.patch_dirty = patch_dirty

	return cs
}

fn (c &Constraint) str() -> string {
	return '${c.orig_func}${c.orig}'
}

fn (c &Constraint) check(v &Version) -> ![bool, ConstraintNotSatisfied] {
	// SAFETY: The orig_func is always a valid key in CONSTRAINT_OPS
	// TODO: this cast is unnecessary, but the compiler cannot infer return type correctly
	op := CONSTRAINT_OPS[c.orig_func] as fn (_ &Version, _ &Constraint) -> ![bool, ConstraintNotSatisfied]
	return op(v, c)
}

type CONSTRAINT_OPS_FUNC = fn (v &Version, c &Constraint) -> ![bool, ConstraintNotSatisfied]

const CONSTRAINT_OPS = {
	"":   constraint_tilde_or_equal as CONSTRAINT_OPS_FUNC
	"=":  constraint_tilde_or_equal
	"!=": constraint_not_equal
	">":  constraint_greater_than
	"<":  constraint_less_than
	">=": constraint_greater_than_equal
	"<=": constraint_less_than_equal
	"~":  constraint_tilde
	"~>": constraint_tilde
	"^":  constraint_caret
}

fn constraint_not_equal(v &Version, c &Constraint) -> ![bool, ConstraintNotSatisfied] {
	if c.dirty {
		// if there is a pre-release on the version but the constraint isn't looking
		// for them assume that pre-releases are not compatible. See issue 21 for
		// more details.
		if v.prerelease != "" && c.con.prerelease == "" {
			return error(ConstraintNotSatisfied.new(*c, *v, "prerelease version and the constraint is only looking for release versions"))
		}

		if v.major != c.con.major {
			return true
		}

		if v.minor != c.con.minor && !c.minor_dirty {
			return true
		} else if c.minor_dirty {
			return error(ConstraintNotSatisfied.new(*c, *v, "minor version is equal to constraint minor version"))
		}

		if v.patch != c.con.patch && !c.patch_dirty {
			return true
		} else if c.patch_dirty {
			// need to handle prereleases if present
			if v.prerelease != "" || c.con.prerelease != "" {
				eq := compare_prerelease(v.prerelease, c.con.prerelease) != 0
				if eq {
					return true
				}
				return error(ConstraintNotSatisfied.new(*c, *v, "patch version is equal to constraint patch version"))
			}

			return error(ConstraintNotSatisfied.new(*c, *v, "patch version is equal to constraint patch version"))
		}
	}

	if v == &c.con {
		return error(ConstraintNotSatisfied.new(*c, *v, "version is equal to constraint version"))
	}

	return true
}

fn constraint_greater_than(v &Version, c &Constraint) -> ![bool, ConstraintNotSatisfied] {
	// if there is a pre-release on the version but the constraint isn't looking
	// for them assume that pre-releases are not compatible.
	if v.prerelease != "" && c.con.prerelease == "" {
		return error(ConstraintNotSatisfied.new(*c, *v, "prerelease version and the constraint is only looking for release versions"))
	}

	if !c.dirty {
		eq := v.compare(&c.con) == 1
		if eq {
			return true
		}
		return error(ConstraintNotSatisfied.new(*c, *v, "version is less than or equal to constraint version"))
	}

	if v.major > c.con.major {
		return true
	} else if v.major < c.con.major {
		return error(ConstraintNotSatisfied.new(*c, *v, "version is less than or equal to constraint version"))
	} else if c.minor_dirty {
		// this is a range case such as >11. When the version is something like
		// 11.1.0 is it not > 11. For that we would need 12 or higher
		return error(ConstraintNotSatisfied.new(*c, *v, "version is less than or equal to constraint version"))
	} else if c.patch_dirty {
		// this is for ranges such as >11.1. A version of 11.1.1 is not greater
		// which one of 11.2.1 is greater
		eq := v.minor > c.con.minor
		if eq {
			return true
		}
		return error(ConstraintNotSatisfied.new(*c, *v, "version is less than or equal to constraint version"))
	}

	// if we have gotten here we are not comparing pre-preleases and can use the
	// compare function to accomplish that.
	eq := v.compare(&c.con) == 1
	if eq {
		return true
	}

	return error(ConstraintNotSatisfied.new(*c, *v, "version is less than or equal to constraint version"))
}

fn constraint_less_than(v &Version, c &Constraint) -> ![bool, ConstraintNotSatisfied] {
	// if there is a pre-release on the version but the constraint isn't looking
	// for them assume that pre-releases are not compatible. See issue 21 for
	// more details.
	if v.prerelease != "" && c.con.prerelease == "" {
		return error(ConstraintNotSatisfied.new(*c, *v, "prerelease version and the constraint is only looking for release versions"))
	}

	eq := v.compare(&c.con) < 0
	if eq {
		return true
	}

	return error(ConstraintNotSatisfied.new(*c, *v, "version is greater than or equal to constraint version"))
}

fn constraint_greater_than_equal(v &Version, c &Constraint) -> ![bool, ConstraintNotSatisfied] {
	// if there is a pre-release on the version but the constraint isn't looking
	// for them assume that pre-releases are not compatible. See issue 21 for
	// more details.
	if v.prerelease != "" && c.con.prerelease == "" {
		return error(ConstraintNotSatisfied.new(*c, *v, "prerelease version and the constraint is only looking for release versions"))
	}

	eq := v.compare(&c.con) >= 0
	if eq {
		return true
	}

	return error(ConstraintNotSatisfied.new(*c, *v, "version is less than constraint version"))
}

fn constraint_less_than_equal(v &Version, c &Constraint) -> ![bool, ConstraintNotSatisfied] {
	// if there is a pre-release on the version but the constraint isn't looking
	// for them assume that pre-releases are not compatible. See issue 21 for
	// more details.
	if v.prerelease != "" && c.con.prerelease == "" {
		return error(ConstraintNotSatisfied.new(*c, *v, "prerelease version and the constraint is only looking for release versions"))
	}

	if !c.dirty {
		eq := v.compare(&c.con) <= 0
		if eq {
			return true
		}
		return error(ConstraintNotSatisfied.new(*c, *v, "version is greater than constraint version"))
	}

	if v.major > c.con.major {
		return error(ConstraintNotSatisfied.new(*c, *v, "version is greater than constraint version"))
	} else if v.major == c.con.major && v.minor > c.con.minor && !c.minor_dirty {
		return error(ConstraintNotSatisfied.new(*c, *v, "version is greater than constraint version"))
	}

	return true
}

// constraint_tilde is a function that checks if a version is compatible with a
// given constraint.
// ```
// ~*, ~>* --> >= 0.0.0 (any)
// ~2, ~2.x, ~2.x.x, ~>2, ~>2.x ~>2.x.x --> >=2.0.0, <3.0.0
// ~2.0, ~2.0.x, ~>2.0, ~>2.0.x --> >=2.0.0, <2.1.0
// ~1.2, ~1.2.x, ~>1.2, ~>1.2.x --> >=1.2.0, <1.3.0
// ~1.2.3, ~>1.2.3 --> >=1.2.3, <1.3.0
// ~1.2.0, ~>1.2.0 --> >=1.2.0, <1.3.0
// ```
fn constraint_tilde(v &Version, c &Constraint) -> ![bool, ConstraintNotSatisfied] {
	// if there is a pre-release on the version but the constraint isn't looking
	// for them assume that pre-releases are not compatible. See issue 21 for
	// more details.
	if v.prerelease != "" && c.con.prerelease == "" {
		return error(ConstraintNotSatisfied.new(*c, *v, "prerelease version and the constraint is only looking for release versions"))
	}

	if v < &c.con {
		return error(ConstraintNotSatisfied.new(*c, *v, "version is less than constraint version"))
	}

	// ~0.0.0 is a special case where all constraints are accepted. It's
	// equivalent to >= 0.0.0.
	if c.con.major == 0 && c.con.minor == 0 && c.con.patch == 0 && !c.minor_dirty && !c.patch_dirty {
		return true
	}

	if v.major != c.con.major {
		return error(ConstraintNotSatisfied.new(*c, *v, "does not have same major version as constraint version"))
	}

	if v.minor != c.con.minor && !c.minor_dirty {
		return error(ConstraintNotSatisfied.new(*c, *v, "does not have same major and minor version as constraint version"))
	}

	return true
}

// constraint_tilde_or_equal is a function that checks if a version is compatible
// with a given constraint.
//
// When there is a .x (dirty) status it automatically opts in to `~`. Otherwise
// it's a straight `=`
fn constraint_tilde_or_equal(v &Version, c &Constraint) -> ![bool, ConstraintNotSatisfied] {
	// if there is a pre-release on the version but the constraint isn't looking
	// for them assume that pre-releases are not compatible. See issue 21 for
	// more details.
	if v.prerelease != "" && c.con.prerelease == "" {
		return error(ConstraintNotSatisfied.new(*c, *v, "prerelease version and the constraint is only looking for release versions"))
	}

	if c.dirty {
		return constraint_tilde(v, c)
	}

	eq := v == &c.con
	if eq {
		return true
	}

	return error(ConstraintNotSatisfied.new(*c, *v, "version is not equal to constraint version"))
}

// constraint_caret is a function that checks if a version is compatible with a
// given constraint.
// ```
// ^*      -->  (any)
// ^1.2.3  -->  >=1.2.3 <2.0.0
// ^1.2    -->  >=1.2.0 <2.0.0
// ^1      -->  >=1.0.0 <2.0.0
// ^0.2.3  -->  >=0.2.3 <0.3.0
// ^0.2    -->  >=0.2.0 <0.3.0
// ^0.0.3  -->  >=0.0.3 <0.0.4
// ^0.0    -->  >=0.0.0 <0.1.0
// ^0      -->  >=0.0.0 <1.0.0
// ```
fn constraint_caret(v &Version, c &Constraint) -> ![bool, ConstraintNotSatisfied] {
	// if there is a pre-release on the version but the constraint isn't looking
	// for them assume that pre-releases are not compatible. See issue 21 for
	// more details.
	if v.prerelease != "" && c.con.prerelease == "" {
		return error(ConstraintNotSatisfied.new(*c, *v, "prerelease version and the constraint is only looking for release versions"))
	}

	// this less than handles prereleases
	if v < &c.con {
		return error(ConstraintNotSatisfied.new(*c, *v, "version is less than constraint version"))
	}

	// ^ when the major > 0 is >=x.y.z < x+1
	if c.con.major > 0 || c.minor_dirty {
		// ^ has to be within a major range for > 0. Everything less than was
		// filtered out with the LessThan call above. This filters out those
		// that greater but not within the same major range.
		eq := v.major == c.con.major
		if eq {
			return true
		}
		return error(ConstraintNotSatisfied.new(*c, *v, "does not have same major version as constraint version"))
	}

	// ^ when the major is 0 and minor > 0 is >=0.y.z < 0.y+1
	if c.con.major == 0 && v.major > 0 {
		return error(ConstraintNotSatisfied.new(*c, *v, "does not have same major version as constraint version"))
	}

	// if the con minor is > 0 it is not dirty
	if c.con.minor > 0 || c.patch_dirty {
		eq := v.minor == c.con.minor
		if eq {
			return true
		}
		return error(ConstraintNotSatisfied.new(*c, *v, "does not have same minor version as constraint version. Expected minor versions to match when constraint major version is 0"))
	}

	// ^ when the minor is 0 and minor > 0 is =0.0.z
	if c.con.minor == 0 && v.minor > 0 {
		return error(ConstraintNotSatisfied.new(*c, *v, "does not have same minor version as constraint version"))
	}

	// at this point the major is 0 and the minor is 0 and not dirty. The patch
	// is not dirty so we need to check if they are equal. If they are not equal
	eq := c.con.patch == v.patch
	if eq {
		return true
	}

	return error(ConstraintNotSatisfied.new(*c, *v, "does not equal constraint version. Expect version and constraint to equal when major and minor versions are 0"))
}

fn is_x(s string) -> bool {
	return s in ['*', 'x', 'X']
}

fn rewrite_range(input string) -> string {
	m := CONSTRAINT_RANGE_REGEX.find_n_matchdata(input, -1).map(|m| m.get_all())
	mut res := input
	for el in m {
		first := el[1]
		eleven := el[11]
		t := ">= ${first}, <= ${eleven} "

		res = res.replace_first(el[0], t)
	}
	return res
}
