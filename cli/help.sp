module cli

import term
import strings
import text
import flag

pub fn (a &mut App) usage(ctx &mut Context) -> string {
	mut sb := strings.new_builder(100)

	sb.write_str(a.name)
	sb.write_str(" v")
	sb.write_str(a.version)
	sb.write_str("\n")

	if a.description != '' {
		sb.write_str(a.description)
		sb.write_str("\n")
	}

	sb.write_str("\n")

	sb.write_str(a.root_cmd.usage(ctx))

	return sb.str_view()
}

fn (c &mut Command) has_non_help_subcommands() -> bool {
	for cmd in c.subcommands {
		if cmd.name != 'help' {
			return true
		}
	}
	return false
}

fn (c &mut Command) has_non_help_version_flags() -> bool {
	for fl in c.flags {
		if fl.name != 'help' && fl.name != 'version' {
			return true
		}
	}
	return false
}

pub fn (c &mut Command) get_usage(ctx &mut Context) -> string {
	c.setup()
	return c.usage(ctx)
}

pub fn (c &mut Command) usage(ctx &mut Context) -> string {
	c.parse_flags() or {} // populate types

	mut sb := strings.new_builder(100)

	if !c.is_root && c.usage.len > 0 {
		sb.write_str(c.usage)
		sb.write_str('\n\n')
	}

	sb.write_str(term.yellow('USAGE'))
	sb.write_str(":\n")
	sb.write_str("    ${ctx.full_cmd_name()}")

	if c.has_non_help_version_flags() {
		sb.write_str(" [FLAGS]")
	}

	if c.has_non_help_subcommands() {
		sb.write_str(" [COMMAND]")
	}

	if c.args_usage.len > 0 {
		sb.write_str(" ${c.args_usage}")
	}

	sb.write_str("\n")

	if c.examples.len > 0 {
		mut max_command_len := 0 as usize
		for example in c.examples {
			len := term.strip_ansi(example.command).len
			if len > max_command_len {
				max_command_len = len
			}
		}

		sb.write_str("\n")
		sb.write_str(term.yellow('EXAMPLES'))
		sb.write_str(":\n")

		for example in c.examples {
			sb.write_str("    ")
			sb.write_str(example.command)
			sb.write_str(" ".repeat(max_command_len - term.strip_ansi(example.command).len))
			sb.write_str("    ")
			sb.write_str(example.description)
			sb.write_str("\n")
		}
	}

	if c.flags.len > 0 {
		sb.write_str("\n")
		sb.write_str(term.yellow('FLAGS'))
		sb.write_str(":\n")
		c.print_flags(&mut sb, c.flags)
	}

	if c.subcommands.len > 0 {
		sb.write_str("\n")
		sb.write_str(term.yellow('COMMANDS'))
		sb.write_str(":\n")

		mut commands_matrix := [][]string{}

		for cmd in c.subcommands {
			mut cmd_line := []string{}

			mut cmd_sb := strings.new_builder(100)
			cmd_sb.write_str(term.green(cmd.name))

			if cmd.aliases.len != 0 {
				cmd_sb.write_str(", ")

				for idx, alias in cmd.aliases {
					cmd_sb.write_str(term.green(alias))
					if idx != cmd.aliases.len - 1 {
						cmd_sb.write_str(", ")
					}
				}
			}

			cmd_line.push(cmd_sb.str_view())
			cmd_line.push(cmd.usage)

			commands_matrix.push(cmd_line)
		}

		mut max_cmd_len := 0 as usize
		for cmd_line in commands_matrix {
			line_raw := term.strip_ansi(cmd_line[0])
			if line_raw.len > max_cmd_len {
				max_cmd_len = line_raw.len
			}
		}

		for cmd_line in commands_matrix {
			line_raw := term.strip_ansi(cmd_line[0])

			sb.write_str("    ")
			sb.write_str(cmd_line[0])
			sb.write_str(" ".repeat(max_cmd_len - line_raw.len))
			sb.write_str("    ")
			sb.write_str(cmd_line[1])
			sb.write_str("\n")
		}
	}

	if c.color_mode != .always && (!term.is_terminal(fd: 1) || c.color_mode == .never) {
		sb = term.strip_ansi_bytes(sb) as strings.Builder
	}

	return sb.str_view()
}

fn (c &mut Command) flags_max_name_width(flags []&mut Flag) -> usize {
	mut max_len := 0 as usize
	for fl in flags {
		len := term.strip_ansi(c.flag_name_string(fl)).len
		if len > max_len {
			max_len = len
		}
	}
	return max_len
}

fn (c &mut Command) print_flags(sb &mut strings.Builder, flags []&mut Flag) {
	mut groups := map[string][]&mut Flag{}
	for fl in flags {
		if fl.category == '' {
			groups.get_ptr_or_insert('General', []&mut Flag{}).push(fl)
		} else {
			groups.get_ptr_or_insert(fl.category, []&mut Flag{}).push(fl)
		}
	}

	max_name_width := c.flags_max_name_width(flags)

	if general := groups.get('General') {
		c.print_flags_group(sb, max_name_width, general)
	}

	for group_name, group_flags in groups {
		if group_name == 'General' {
			continue
		}

		sb.write_str("\n")
		sb.write_str(term.yellow(group_name))
		sb.write_str(":\n")

		c.print_flags_group(sb, max_name_width, group_flags)
	}
}

fn (c &mut Command) flag_name_string(flag &mut Flag) -> string {
	mut sb := strings.new_builder(100)

	if flag.short != 0 {
		sb.write_str(term.green("-${flag.short}"))
		sb.write_str(", ")
	} else {
		sb.write_str("    ")
	}

	sb.write_str(term.green("--${flag.name}"))

	match flag.value {
		&mut i32 => sb.write_str(term.green(" <INT> "))
		&mut f64 => sb.write_str(term.green(" <FLOAT> "))
		&mut string => sb.write_str(term.green(" <STRING> "))
		else => {
			// boolean flag value can be omitted
		}
	}

	if flag.default != none {
		if flag.typ == .bool {
			sb.write_str(' ')
		}

		sb.write_str(term.gray("(default: ${flag.default})"))
	}

	return sb.str_view()
}

fn (c &mut Command) print_flags_group(sb &mut strings.Builder, max_name_width usize, flags []&mut Flag) {
	mut flag_matrix := [][]string{}

	mut flag_names := []string{}

	mut flag_sb := strings.new_builder(100)
	for fl in flags {
		flag_names.push(c.flag_name_string(fl))
	}

	mut any_flag_has_multiline_usage := false
	for fl in flags {
		if fl.usage.len > c.help_text_wrap || fl.usage.count('\n') > 0 {
			any_flag_has_multiline_usage = true
			break
		}
	}

	for idx, fl in flags {
		indent := max_name_width + 6

		if fl.usage.len > c.help_text_wrap {
			mut usage_sb := strings.new_builder(c.help_text_wrap)
			text.wrap_string_to(&mut usage_sb, fl.usage, c.help_text_wrap)
			text.indent_text_to(&mut flag_sb, usage_sb.str_view(), indent, true)
			flag_sb.write_str("\n")
		} else if fl.usage.count('\n') > 0 {
			text.indent_text_to(&mut flag_sb, fl.usage, indent, true)
			flag_sb.write_str('\n')
		} else {
			flag_sb.write_str(fl.usage)

			if any_flag_has_multiline_usage {
				// if even one flag has multiline usage, separate all flags with an empty line
				flag_sb.write_str("\n")
			}
		}

		flag_matrix.push([flag_names[idx], flag_sb.str()])

		flag_sb.clear()
	}

	for flag_line in flag_matrix {
		line_raw := term.strip_ansi(flag_line[0])

		sb.write_str("    ")
		sb.write_str(flag_line[0])
		sb.write_str(" ".repeat(max_name_width - line_raw.len))
		sb.write_str("  ")
		sb.write_str(flag_line[1])
		sb.write_str("\n")
	}
}
