module cli

import mem
import flag

pub type ActionFunc = fn (ctx &mut Context) -> !

pub struct Command {
	name        string
	aliases     []string
	usage       string
	args_usage  string
	description string

	examples []Example

	flags  []&mut Flag
	action ?ActionFunc

	// help_text_wrap sets the max width of the commands and flags
	// help text. If the text is longer than this value, it will be
	// wrapped to the next line.
	help_text_wrap usize = 60

	// skip_flag_parsing sets whether threat the flags as arguments.
	skip_flag_parsing bool

	// hide_version sets whether or not the builtin version flag should be hidden.
	hide_version bool
	// hide_help_cmd sets whether or not builtin help command should be hidden.
	hide_help_cmd bool
	// hide_help sets whether or not the builtin help flag should be hidden.
	hide_help bool

	subcommands []&mut Command

	color_mode ColorMode
	is_root    bool
}

pub fn (c &mut Command) run(ctx &mut Context, args ...string) -> ! {
	if !c.is_root {
		c.setup()
	}

	ctx.flag_set = c.parse_flags(...args)!

	args_after_flags := ctx.flag_set.args

	if first := args_after_flags.get(0) {
		if cmd := c.command(first) {
			mut new_ctx := Context.new(ctx.app)
			new_ctx.command = cmd
			new_ctx.parent = ctx
			return cmd.run(new_ctx, ...args_after_flags[1..])
		}
	}

	if c.check_help(ctx) {
		return HELP_COMMAND.action.unwrap()(ctx)
	}

	if c.is_root && !c.hide_version && c.check_version(ctx) {
		ctx.app.print_version()
		return
	}

	if c.action == none {
		return
	}

	return c.action(ctx)
}

fn (c &mut Command) check_help(ctx &mut Context) -> bool {
	return ctx.get_bool(HELP_FLAG.name).unwrap_or(false) || ctx.get_bool(HELP_FLAG.short.str()).unwrap_or(false)
}

fn (c &mut Command) check_version(ctx &mut Context) -> bool {
	return ctx.get_bool(VERSION_FLAG.name).unwrap_or(false) || ctx.get_bool(VERSION_FLAG.short.str()).unwrap_or(false)
}

fn (c &mut Command) names() -> []string {
	if c.aliases.len == 0 {
		return [c.name]
	}
	mut res := [c.name]
	res.push_many(c.aliases)
	return res
}

pub fn (c &mut Command) setup() {
	// if !c.has_cmd(HELP_COMMAND.name) && !c.hide_help {
	//     if !c.hide_help_cmd {
	//         c.append_cmd(HELP_COMMAND)
	//     }
	// }

	if !c.hide_help {
		c.append_flag(HELP_FLAG)
	}
}

fn (c &mut Command) append_flag(f &mut Flag) {
	if c.has_flag(f.name) {
		return
	}
	c.flags.push(f)
}

fn (c &mut Command) has_flag(name string) -> bool {
	for f in c.flags {
		if f.name == name {
			return true
		}
	}
	return false
}

fn (c &mut Command) append_cmd(cmd &mut Command) {
	if c.has_cmd(cmd.name) {
		return
	}
	c.subcommands.push(cmd)
}

fn (c &mut Command) has_cmd(name string) -> bool {
	for cmd in c.subcommands {
		if cmd.name == name {
			return true
		}
	}
	return false
}

fn (c &Command) parse_flags(args ...string) -> !FlagSet {
	mut fs := new_flag_set(args)

	if c.skip_flag_parsing {
		return fs
	}

	for flag in c.flags {
		mut str_val := ""
		mut i32_val := 0
		mut f32_val := 0.0
		mut bool_val := false

		if def := flag.default {
			match def {
				string => {
					str_val = def
				}
				i32 => {
					i32_val = def
				}
				f64 => {
					f32_val = def
				}
				bool => {
					bool_val = def
				}
			}
		}

		flag.value = match flag.typ {
			.string => mem.to_heap_mut(&mut str_val) as FlagValue
			.int => mem.to_heap_mut(&mut i32_val) as FlagValue
			.float => mem.to_heap_mut(&mut f32_val) as FlagValue
			.bool => mem.to_heap_mut(&mut bool_val) as FlagValue
		}

		fs.formal[flag.name] = flag
		if flag.short != 0 {
			fs.formal[flag.short.str()] = flag
		}
	}

	fs.parse()!
	return fs
}

pub fn (c &Command) command(name string) -> ?&mut Command {
	for cmd in c.subcommands {
		if name in cmd.names() {
			return cmd
		}
	}
	return none
}
