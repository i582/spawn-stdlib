module flag

import mem
import strconv
import strings
import term
import os
import text

pub struct Flag {
	name    string
	short   rune
	default string
	usage   string
	value   FlagValue
}

pub union FlagValue = &mut string |
                      &mut i32 |
                      &mut f64 |
                      &mut bool |
                      FlagCustomValue

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
		FlagCustomValue => {
			v.set(s)!
		}
	}
}

pub interface FlagCustomValue {
	fn as_str(self) -> string
	fn set(&mut self, s string) -> !
	fn value_type(self) -> string
}

struct DefaultFlagCustomValue {}

fn (v DefaultFlagCustomValue) as_str() -> string {
	return ''
}

fn (v &mut DefaultFlagCustomValue) set(s string) -> ! {
	return error("flag value is not supported")
}

fn (v DefaultFlagCustomValue) value_type() -> string {
	return 'VALUE'
}

pub enum ColorMode {
	auto
	always
	never
}

pub struct FlagSet {
	// args is the list of arguments to parse
	args []string

	parsed bool

	color_mode        ColorMode = .auto
	forbid_duplicates bool
	allow_undefined   bool
	use_unified_flags bool
	help_text_wrap    usize     = 60

	app_name        string = 'app'
	app_version     string = '1.0.0'
	app_description string

	formal map[string]&mut Flag = map[string]&mut Flag{}
	actual map[string]&mut Flag = map[string]&mut Flag{}
}

pub fn new_flag_set(args []string) -> FlagSet {
	return FlagSet{ args: args }
}

pub fn (s &mut FlagSet) app_name(name string) {
	s.app_name = name
}

pub fn (s &mut FlagSet) app_version(version string) {
	s.app_version = version
}

pub fn (s &mut FlagSet) app_description(description string) {
	s.app_description = description
}

pub fn (s &mut FlagSet) color_mode(mode ColorMode) {
	s.color_mode = mode
}

pub fn (s &mut FlagSet) forbid_duplicates() {
	s.forbid_duplicates = true
}

pub fn (s &mut FlagSet) allow_undefined() {
	s.allow_undefined = true
}

// use_unified_flags enables parsing of unified flags, e.g. -abc instead of -a -b -c
// This is useful for short flags that don't take arguments.
pub fn (s &mut FlagSet) use_unified_flags() {
	s.use_unified_flags = true
}

pub fn (s &mut FlagSet) help_text_wrap(width usize) {
	s.help_text_wrap = width
}

pub fn (s &mut FlagSet) string(name string, short rune, default string, usage string) -> &mut string {
	mut v := ''
	mut ref := &mut v
	s.string_var(ref, name, short, default, usage)
	return ref
}

pub fn (s &mut FlagSet) string_var(v &mut string, name string, short rune, default string, usage string) {
	mut f := mem.to_heap_mut(&mut Flag{
		name: name
		short: short
		default: default
		usage: usage
		value: v
	})

	if default != '' {
		// setup default value if any
		*v = default
	}

	s.formal[name] = f
	if short != 0 {
		s.formal[short.str()] = f
	}
}

pub fn (s &mut FlagSet) bool(name string, short rune, default bool, usage string) -> &mut bool {
	mut v := false
	mut ref := &mut v
	s.bool_var(ref, name, short, default, usage)
	return ref
}

pub fn (s &mut FlagSet) bool_var(v &mut bool, name string, short rune, default bool, usage string) {
	mut f := mem.to_heap_mut(&mut Flag{
		name: name
		short: short
		default: default.str()
		usage: usage
		value: v
	})

	if default {
		// setup default value if any
		*v = default
	}

	s.formal[name] = f
	if short != 0 {
		s.formal[short.str()] = f
	}
}

pub fn (s &mut FlagSet) int(name string, short rune, default i32, usage string) -> &mut i32 {
	mut v := 0
	mut ref := &mut v
	s.int_var(ref, name, short, default, usage)
	return ref
}

pub fn (s &mut FlagSet) int_var(v &mut i32, name string, short rune, default i32, usage string) {
	mut f := mem.to_heap_mut(&mut Flag{
		name: name
		short: short
		default: default.str()
		usage: usage
		value: v
	})

	if default != 0 {
		// setup default value if any
		*v = default
	}

	s.formal[name] = f
	if short != 0 {
		s.formal[short.str()] = f
	}
}

pub fn (s &mut FlagSet) float(name string, short rune, default f64, usage string) -> &mut f64 {
	mut v := 0.0
	mut ref := &mut v
	s.float_var(ref, name, short, default, usage)
	return ref
}

pub fn (s &mut FlagSet) float_var(v &mut f64, name string, short rune, default f64, usage string) {
	mut f := mem.to_heap_mut(&mut Flag{
		name: name
		short: short
		default: default.str()
		usage: usage
		value: v
	})

	if default != 0.0 {
		// setup default value if any
		*v = default
	}

	s.formal[name] = f
	if short != 0 {
		s.formal[short.str()] = f
	}
}

pub fn (s &mut FlagSet) custom_var(v FlagCustomValue, name string, short rune, usage string) {
	mut f := mem.to_heap_mut(&mut Flag{
		name: name
		short: short
		usage: usage
		value: v
	})

	s.formal[name] = f
	if short != 0 {
		s.formal[short.str()] = f
	}
}

pub fn (s &mut FlagSet) args() -> []string {
	return s.args
}

pub fn (s &mut FlagSet) parse() -> ! {
	_ = DefaultFlagCustomValue{} as FlagCustomValue

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

		if name.len == 0 || (name.len > 1 && name[1] != b`=`) && !s.use_unified_flags {
			return error("bad flag syntax: ${f}")
		}

		if s.use_unified_flags {
			// unified flags, e.g. -abc instead of -a -b -c
			for i in 0 .. name.len {
				flag_name := name[i].ascii_str()

				fl := s.formal.get(flag_name) or {
					if flag_name in ['h', 'v'] {
						// special case, help or version flag
						s.args = s.args[1..]
						s.parse_one()!
						return true
					}

					if s.allow_undefined {
						continue
					}

					return error("flag provided but not defined: -${flag_name}")
				}

				if s.forbid_duplicates {
					if flag_name in s.actual {
						return error("flag redefined: -${flag_name}")
					}
				}

				if fl.value is &mut bool {
					// special case, boolean flag value can be omitted
					(fl.value as FlagValue).set('true') or {
						return error("invalid boolean flag -${flag_name}")
					}
				} else {
					// It must have a value, which might be the next argument.
					if i + 1 < name.len {
						// value is the rest of the flag
						value := name[i + 1..]
						name = name[..i]
						fl.value.set(value) or {
							return error("invalid value `${value}` for flag -${flag_name}")
						}
						break
					}

					if s.args.len == 1 {
						return error("flag needs an argument: -${flag_name}")
					}

					// value is the next arg
					value := s.args.get(1) or {
						return error("flag needs an argument: -${flag_name}")
					}
					s.args = s.args[1..]
					fl.value.set(value) or {
						return error("invalid value `${value}` for flag -${flag_name}: ${err.msg()}")
					}
				}

				s.actual[flag_name] = fl
			}

			s.args = s.args[1..]
			return true
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
		if name in ['help', 'h', '?', 'H'] {
			// special case, help flag
			s.print_usage()
			os.exit(1)
		}

		if name in ['version', 'v', 'V'] {
			// special case, version flag
			s.print_version()
			os.exit(1)
		}

		if s.allow_undefined {
			return true
		}

		return error("flag provided but not defined: ${f}")
	}

	if s.forbid_duplicates {
		if name in s.actual {
			return error("flag redefined: --${name}")
		}
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

pub fn (s &mut FlagSet) print_version() {
	println("${s.app_name} v${s.app_version}")
}

pub fn (s &mut FlagSet) print_usage() {
	println(s.usage())
}

pub fn (s &mut FlagSet) usage() -> string {
	mut sb := strings.new_builder(100)

	sb.write_str(s.app_name)
	sb.write_str(" v")
	sb.write_str(s.app_version)
	sb.write_str("\n")

	if s.app_description != '' {
		sb.write_str(s.app_description)
		sb.write_str("\n")
	}

	sb.write_str("\n")

	sb.write_str(term.yellow('USAGE'))
	sb.write_str(":\n")
	sb.write_str("    ${s.app_name} [OPTIONS]\n")

	sb.write_str("\n")
	sb.write_str(term.yellow('OPTIONS'))
	sb.write_str(":\n")

	mut flags := []Flag{}

	for name, fl in s.formal {
		if name.len == 1 {
			continue
		}

		flags.push(*fl)
	}

	mut true_val := true
	flags.push(Flag{
		name: 'help'
		short: `h`
		default: ''
		usage: 'print this help message and exit'
		value: &mut true_val
	})

	flags.push(Flag{
		name: 'version'
		short: `v`
		default: ''
		usage: 'print the version and exit'
		value: &mut true_val
	})

	mut any_flag_has_multiline_usage := false
	for fl in flags {
		if fl.usage.len > s.help_text_wrap || fl.usage.count('\n') > 0 {
			any_flag_has_multiline_usage = true
			break
		}
	}

	for fl in flags {
		sb.write_str("  ")
		if fl.short != 0 {
			sb.write_str(term.green("-${fl.short}"))
			sb.write_str(", ")
		} else {
			sb.write_str("    ")
		}
		sb.write_str(term.green("--${fl.name}"))

		match fl.value {
			&mut i32 => sb.write_str(term.green(" <INT>"))
			&mut f64 => sb.write_str(term.green(" <FLOAT>"))
			&mut string => sb.write_str(term.green(" <STRING>"))
			FlagCustomValue => sb.write_str(term.green(" <${fl.value.value_type()}>"))
			else => {
				// boolean flag value can be omitted
			}
		}

		if fl.default !in ['', '0', '0.0', 'false'] {
			sb.write_str(term.gray(" (default: ${fl.default})"))
		}

		sb.write_str("\n")
		sb.write_str("        ")

		if fl.usage.len > s.help_text_wrap {
			mut usage_sb := strings.new_builder(s.help_text_wrap)
			text.wrap_string_to(&mut usage_sb, fl.usage, s.help_text_wrap)
			text.indent_text_to(&mut sb, usage_sb.str_view(), 8, true)
			sb.write_str("\n")
		} else if fl.usage.count('\n') > 0 {
			text.indent_text_to(&mut sb, fl.usage, 8, true)
			sb.write_str('\n')
		} else {
			sb.write_str(fl.usage)
			sb.write_str("\n")
		}

		if any_flag_has_multiline_usage {
			// if even one flag has multiline usage, separate all flags with an empty line
			sb.write_str("\n")
		}
	}

	if s.color_mode != .always && (!term.is_terminal(fd: 1) || s.color_mode == .never) {
		sb = term.strip_ansi_bytes(sb) as strings.Builder
	}

	return sb.str_view()
}
