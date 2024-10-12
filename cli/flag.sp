module cli

import strconv

pub union FlagValue = &mut string |
                      &mut i32 |
                      &mut f64 |
                      &mut bool

pub fn (v FlagValue) set(s string) -> ! {
	match v {
		&mut string => {
			*v = s
		}
		&mut i32 => {
			val := s.parse_int() or { return error("invalid number `${s}`") }
			*v = val as i32
		}
		&mut f64 => {
			val := strconv.parse_float(s) or { return error("invalid number `${s}`") }
			*v = val
		}
		&mut bool => {
			*v = s == 'true'
		}
	}
}

pub union FlagDefaultValue = string |
                             i32 |
                             f64 |
                             bool

pub fn (v FlagDefaultValue) str() -> string {
	return match v {
		string => v
		i32 => v.str()
		f64 => v.str()
		bool => v.str()
	}
}

pub enum FlagType {
	string
	int
	float
	bool
}

pub struct Flag {
	name    string
	short   rune
	typ     FlagType
	usage   string
	default ?FlagDefaultValue
	value   FlagValue

	category string
}

pub struct FlagSet {
	// args is the list of arguments to parse
	args []string

	parsed bool

	formal map[string]&mut Flag = map[string]&mut Flag{}
	actual map[string]&mut Flag = map[string]&mut Flag{}
}

pub fn new_flag_set(args []string) -> FlagSet {
	return FlagSet{ args: args }
}

pub fn (s &FlagSet) lookup(name string) -> ?&mut Flag {
	return s.formal.get(name)
}

pub fn (s &FlagSet) lookup_actual(name string) -> ?&mut Flag {
	return s.actual.get(name)
}

pub fn (s &mut FlagSet) parse() -> ! {
	s.parsed = true

	for {
		seen := s.parse_one()!
		if seen {
			continue
		}
		break
	}
}

fn (s &mut FlagSet) parse_one() -> !bool {
	if s.args.len == 0 {
		return false
	}

	f := s.args[0]
	if f.len < 2 || f[0] != b`-` {
		return false
	}

	mut num_minuses := 1
	if f[1] == b`-` {
		num_minuses = 2

		if f.len == 2 {
			// "--" terminates the flags
			s.args = s.args[1..]
			return false
		}
	}

	mut name := f

	if num_minuses == 1 {
		name = f[1..]

		if name.len == 0 || (name.len > 1 && name[1] != b`=`) {
			return error("bad flag syntax: ${f}")
		}
	} else {
		name = f[2..]

		if name.len == 0 || name[0] == b`-` || name[0] == b`=` {
			return error("bad flag syntax: ${f}")
		}
	}

	s.args = s.args[1..]
	mut has_value := false
	mut value := ''
	for i in 1 .. name.len {
		if name[i] == b`=` {
			has_value = true
			value = name[i + 1..]
			name = name[..i]
			break
		}
	}

	fl := s.formal.get(name) or {
		return error("flag provided but not defined: --${name}")
	}

	if fl.value is &mut bool {
		// special case, boolean flag value can be omitted
		if has_value {
			(fl.value as FlagValue).set(value) or {
				return error("invalid boolean value `${value}` for flag --${name}")
			}
		} else {
			(fl.value as FlagValue).set('true') or {
				return error("invalid boolean flag --${name}")
			}
		}
	} else {
		// It must have a value, which might be the next argument.
		if !has_value && s.args.len != 0 {
			// value is the next arg
			has_value = true
			value = s.args[0]
			s.args = s.args[1..]
		}

		if !has_value {
			return error("flag needs an argument: --${name}")
		}

		fl.value.set(value) or {
			return error("invalid value `${value}` for flag --${name}: ${err.msg()}")
		}
	}

	s.actual[name] = fl
	return true
}
