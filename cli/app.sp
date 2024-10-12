module cli

import pathlib
import os
import term

pub enum ColorMode {
	auto
	always
	never
}

pub struct App {
	name    string
	version string = '1.0.0'

	args_usage  string
	usage       string
	description string

	examples []Example

	flags    []&mut Flag
	action   ?ActionFunc
	commands []&mut Command

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

	color_mode ColorMode

	root_cmd &mut Command

	did_setup bool
}

pub fn (a &mut App) run(args []string) -> ! {
	a.setup()

	ctx := Context.new(a)
	root_cmd := a.new_root_cmd()
	a.root_cmd = root_cmd
	ctx.command = root_cmd

	return a.root_cmd.run(ctx, ...args)
}

pub fn (a &mut App) run_or_exit(args []string) {
	a.run(args) or {
		if a.color_mode != .never {
			print(term.colorize(term.bright_red, 'error'))
		} else {
			print('error')
		}

		print(': ')
		println(err.msg())
		os.exit(1)
	}
}

fn (a &mut App) setup() {
	if a.did_setup {
		return
	}
	a.did_setup = true

	if a.name == '' {
		a.name = pathlib.base(os.ARGS[0])
	}

	if a.usage == '' {
		a.usage = "A new cli application"
	}

	if !a.has_cmd(HELP_COMMAND.name) && !a.hide_help {
		if !a.hide_help_cmd {
			a.append_cmd(HELP_COMMAND)
		}

		a.append_flag(HELP_FLAG)
	}

	if !a.hide_version {
		a.append_flag(VERSION_FLAG)
	}
}

pub fn (a &mut App) get_usage() -> string {
	a.setup()

	ctx := Context.new(a)
	root_cmd := a.new_root_cmd()
	a.root_cmd = root_cmd
	ctx.command = root_cmd

	return a.usage(ctx)
}

fn (a &mut App) print_version() {
	println('${a.name} version ${a.version}')
}

fn (a &mut App) append_flag(f &mut Flag) {
	if a.has_flag(f.name) {
		return
	}
	a.flags.push(f)
}

fn (a &mut App) has_flag(name string) -> bool {
	for f in a.flags {
		if f.name == name {
			return true
		}
	}
	return false
}

fn (a &mut App) append_cmd(c &mut Command) {
	if a.has_cmd(c.name) {
		return
	}
	a.commands.push(c)
}

fn (a &mut App) has_cmd(name string) -> bool {
	for c in a.commands {
		if name in c.names() {
			return true
		}
	}
	return false
}

pub fn (a &mut App) command(name string) -> ?&mut Command {
	for c in a.commands {
		if name in c.names() {
			return c
		}
	}
	return none
}

fn (a &mut App) new_root_cmd() -> &mut Command {
	return &mut Command{
		name: a.name
		usage: a.usage
		args_usage: a.args_usage
		description: a.description
		examples: a.examples
		flags: a.flags
		action: a.action
		help_text_wrap: a.help_text_wrap
		skip_flag_parsing: a.skip_flag_parsing
		hide_version: a.hide_version
		hide_help_cmd: a.hide_help_cmd
		hide_help: a.hide_help
		subcommands: a.commands
		color_mode: a.color_mode
		is_root: true
	}
}
