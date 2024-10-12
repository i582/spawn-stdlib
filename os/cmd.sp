module os

import strings

// Command is a builder-like struct to create and run commands.
pub struct Command {
	program string
	args    []string
}

// new creates a new [`Command`] with the given program name.
//
// Created command can be used to build a command.
// See also [`exec`] function to just run a command.
pub fn Command.new(program string) -> &mut Command {
	return &mut Command{ program: program }
}

// arg adds an argument to the command.
//
// Example:
// ```
// cmd := Command.new("ls").
//   arg("-a").
//   arg("-l")
// ```
pub fn (c &mut Command) arg(arg string) -> &mut Command {
	c.args.push(arg)
	return c
}

// args adds multiple arguments to the command.
//
// Example:
// ```
// cmd := Command.new("ls").
//   args([]string{"-a", "-l"})
// ```
pub fn (c &mut Command) args(args []string) -> &mut Command {
	c.args.push_many(args)
	return c
}

// arg_if adds an argument to the command if the condition is true.
//
// Example:
// ```
// list_all := true
// cmd := Command.new("ls").
//   arg_if(list_all, "-a")
// ```
pub fn (c &mut Command) arg_if(cond bool, arg string) -> &mut Command {
	if cond {
		c.args.push(arg)
	}
	return c
}

// as_str returns the command as a string.
//
// Example:
// ```
// cmd := Command.new("ls").
//   arg("-a").
//   arg("-l")
//
// println(cmd.as_str()) // ls -a -l
// ```
pub fn (c &mut Command) as_str() -> string {
	mut sb := strings.new_builder(100)

	sb.write_str(c.program)
	for arg in c.args {
		sb.write_str(" ")
		sb.write_str(arg)
	}

	return sb.str()
}

// Res is the result of the synchronous command execution.
pub struct Res {
	// cmd is the command that was executed.
	cmd string

	// exit_code is the exit code of the command.
	exit_code i32

	// output is the stdout content of the command.
	output string
}

// run synchronously runs the command and returns the result.
// If command cannot be executed, function returns an error.
// If command successfully executed, function returns the result where
// `exit_code` can be used to check if command was successful or not.
pub fn (c &mut Command) run() -> !Res {
	return exec(c.as_str())
}
