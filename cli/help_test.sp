module main

import cli

test "help for command with one subcommand without any flags" {
	mut app := cli.App{
		name: 'test-app'
		color_mode: .never
		commands: [
			&mut cli.Command{
				name: 'install'
				usage: 'Install package'
			},
		]
	}

	app.run(['']).unwrap()

	usage := app.get_usage()
	t.assert_eq(usage, 'test-app v1.0.0

USAGE:
    test-app [COMMAND]

FLAGS:
    -h, --help     Print this help message
    -v, --version  Print the version

COMMANDS:
    install    Install package
    help       Shows a list of commands or help for one command
', 'usage should be equal to expected')
}

test "help for command with one subcommand with alias" {
	mut app := cli.App{
		name: 'test-app'
		color_mode: .never
		commands: [
			&mut cli.Command{
				name: 'install'
				aliases: ['i']
				usage: 'Install package'
			},
		]
	}

	app.run(['']).unwrap()

	usage := app.get_usage()
	t.assert_eq(usage, 'test-app v1.0.0

USAGE:
    test-app [COMMAND]

FLAGS:
    -h, --help     Print this help message
    -v, --version  Print the version

COMMANDS:
    install, i    Install package
    help          Shows a list of commands or help for one command
', 'usage should be equal to expected')
}

test "help for command with one subcommand with aliases" {
	mut app := cli.App{
		name: 'test-app'
		color_mode: .never
		commands: [
			&mut cli.Command{
				name: 'install'
				aliases: ['i', 'inst']
				usage: 'Install package'
			},
		]
	}

	app.run(['']).unwrap()

	usage := app.get_usage()
	t.assert_eq(usage, 'test-app v1.0.0

USAGE:
    test-app [COMMAND]

FLAGS:
    -h, --help     Print this help message
    -v, --version  Print the version

COMMANDS:
    install, i, inst    Install package
    help                Shows a list of commands or help for one command
', 'usage should be equal to expected')
}

test "help for command with one subcommand without any flags and with disabled help and version flags" {
	mut app := cli.App{
		name: 'test-app'
		color_mode: .never
		hide_help: true
		hide_version: true
		commands: [
			&mut cli.Command{
				name: 'install'
				usage: 'Install package'
			},
		]
	}

	app.run(['']).unwrap()

	usage := app.get_usage()
	t.assert_eq(usage, 'test-app v1.0.0

USAGE:
    test-app [COMMAND]

COMMANDS:
    install    Install package
', 'usage should be equal to expected')
}

test "help for root command examples" {
	mut app := cli.App{
		name: 'test-app'
		color_mode: .never
		examples: [
			cli.Example{
				command: 'install --foo'
				description: 'Do something cool'
			},
			cli.Example{
				command: 'install other --foo'
				description: 'Do something cool too'
			},
		]
		commands: [
			&mut cli.Command{
				name: 'install'
				usage: 'Install package'
			},
		]
	}

	app.run(['']).unwrap()

	usage := app.get_usage()
	t.assert_eq(usage, 'test-app v1.0.0

USAGE:
    test-app [COMMAND]

EXAMPLES:
    install --foo          Do something cool
    install other --foo    Do something cool too

FLAGS:
    -h, --help     Print this help message
    -v, --version  Print the version

COMMANDS:
    install    Install package
    help       Shows a list of commands or help for one command
', 'usage should be equal to expected')
}

test "help for command with examples" {
	mut app := cli.App{
		name: 'test-app'
		color_mode: .never
		commands: [
			&mut cli.Command{
				name: 'install'
				usage: 'Install package'
				examples: [
					cli.Example{
						command: 'install --foo'
						description: 'Do something cool'
					},
					cli.Example{
						command: 'install other --foo'
						description: 'Do something cool too'
					},
				]
				flags: [
					&mut cli.Flag{
						typ: .bool
						name: 'foo'
						usage: 'Foo description'
					},
				]
			},
		]
	}

	app.run(['']).unwrap()

	cmd := app.command('install').unwrap()
	mut ctx := cli.Context.new(&mut app)
	ctx.command = cmd

	usage := cmd.get_usage(ctx)
	t.assert_eq(usage, 'Install package

USAGE:
    install [FLAGS]

EXAMPLES:
    install --foo          Do something cool
    install other --foo    Do something cool too

FLAGS:
        --foo   Foo description
    -h, --help  Print this help message
', 'usage should be equal to expected')
}

test "help for subcommand with examples" {
	mut app := cli.App{
		name: 'test-app'
		color_mode: .never
		commands: [
			&mut cli.Command{
				name: 'some'
				usage: 'Do something cool'
				subcommands: [
					&mut cli.Command{
						name: 'install'
						usage: 'Install package'
						examples: [
							cli.Example{
								command: 'install --foo'
								description: 'Do something cool'
							},
							cli.Example{
								command: 'install other --foo'
								description: 'Do something cool too'
							},
						]
						flags: [
							&mut cli.Flag{
								typ: .bool
								name: 'foo'
								usage: 'Foo description'
							},
						]
					},
				]
			},
		]
	}

	app.run(['']).unwrap()

	some_cmd := app.command('some').unwrap()
	mut some_ctx := cli.Context.new(&mut app)
	some_ctx.command = some_cmd

	install_cmd := some_cmd.command('install').unwrap()
	mut install_ctx := cli.Context.new(&mut app)
	install_ctx.command = install_cmd
	install_ctx.parent = some_ctx

	usage := install_cmd.get_usage(install_ctx)
	t.assert_eq(usage, 'Install package

USAGE:
    some install [FLAGS]

EXAMPLES:
    install --foo          Do something cool
    install other --foo    Do something cool too

FLAGS:
        --foo   Foo description
    -h, --help  Print this help message
', 'usage should be equal to expected')
}

test "help for command with one subcommand without any flags and with disabled help command" {
	mut app := cli.App{
		name: 'test-app'
		color_mode: .never
		hide_help_cmd: true
		commands: [
			&mut cli.Command{
				name: 'install'
				usage: 'Install package'
			},
		]
	}

	app.run(['']).unwrap()

	usage := app.get_usage()
	t.assert_eq(usage, 'test-app v1.0.0

USAGE:
    test-app [COMMAND]

FLAGS:
    -h, --help     Print this help message
    -v, --version  Print the version

COMMANDS:
    install    Install package
', 'usage should be equal to expected')
}

test "help for command with one subcommand and single bool flag" {
	mut app := cli.App{
		name: 'test-app'
		color_mode: .never
		commands: [
			&mut cli.Command{
				name: 'install'
				usage: 'Install package'
			},
		]
		flags: [
			&mut cli.Flag{
				typ: .bool
				name: 'flag'
				short: `f`
				usage: 'Flag description'
			},
		]
	}

	app.run(['']).unwrap()

	usage := app.get_usage()
	t.assert_eq(usage, 'test-app v1.0.0

USAGE:
    test-app [FLAGS] [COMMAND]

FLAGS:
    -f, --flag     Flag description
    -h, --help     Print this help message
    -v, --version  Print the version

COMMANDS:
    install    Install package
    help       Shows a list of commands or help for one command
', 'usage should be equal to expected')
}

test "root command with flags with default values" {
	mut app := cli.App{
		name: 'test-app'
		color_mode: .never
		flags: [
			&mut cli.Flag{
				typ: .bool
				name: 'flag'
				short: `f`
				usage: 'Flag description'
				default: true
			},
			&mut cli.Flag{
				typ: .string
				name: 'flag2'
				short: `g`
				usage: 'Flag2 description'
				default: 'default'
			},
			&mut cli.Flag{
				typ: .int
				name: 'flag3'
				short: `i`
				usage: 'Flag3 description'
				default: 42
			},
			&mut cli.Flag{
				typ: .float
				name: 'flag4'
				short: `j`
				usage: 'Flag4 description'
				default: 3.14
			},
		]
	}

	app.run(['']).unwrap()

	usage := app.get_usage()
	t.assert_eq(usage, 'test-app v1.0.0

USAGE:
    test-app [FLAGS]

FLAGS:
    -f, --flag (default: true)               Flag description
    -g, --flag2 <STRING> (default: default)  Flag2 description
    -i, --flag3 <INT> (default: 42)          Flag3 description
    -j, --flag4 <FLOAT> (default: 3.140000)  Flag4 description
    -h, --help                               Print this help message
    -v, --version                            Print the version

COMMANDS:
    help    Shows a list of commands or help for one command
', 'usage should be equal to expected')
}

test "help for command with one subcommand and single string flag" {
	mut app := cli.App{
		name: 'test-app'
		color_mode: .never
		commands: [
			&mut cli.Command{
				name: 'install'
				usage: 'Install package'
			},
		]
		flags: [
			&mut cli.Flag{
				typ: .string
				name: 'flag'
				short: `f`
				usage: 'Flag description'
			},
		]
	}

	app.run(['']).unwrap()

	usage := app.get_usage()
	t.assert_eq(usage, 'test-app v1.0.0

USAGE:
    test-app [FLAGS] [COMMAND]

FLAGS:
    -f, --flag <STRING>   Flag description
    -h, --help            Print this help message
    -v, --version         Print the version

COMMANDS:
    install    Install package
    help       Shows a list of commands or help for one command
', 'usage should be equal to expected')
}

test "help for command with one subcommand and several flags" {
	mut app := cli.App{
		name: 'test-app'
		color_mode: .never
		commands: [
			&mut cli.Command{
				name: 'install'
				usage: 'Install package'
			},
		]
		flags: [
			&mut cli.Flag{
				typ: .string
				name: 'flag'
				short: `f`
				usage: 'Flag description'
			},
			&mut cli.Flag{
				typ: .float
				name: 'flag2'
				usage: 'Flag2 description'
			},
		]
	}

	app.run(['']).unwrap()

	usage := app.get_usage()
	t.assert_eq(usage, 'test-app v1.0.0

USAGE:
    test-app [FLAGS] [COMMAND]

FLAGS:
    -f, --flag <STRING>   Flag description
        --flag2 <FLOAT>   Flag2 description
    -h, --help            Print this help message
    -v, --version         Print the version

COMMANDS:
    install    Install package
    help       Shows a list of commands or help for one command
', 'usage should be equal to expected')
}

test "help for command with one subcommand with several flags with categories" {
	mut app := cli.App{
		name: 'test-app'
		version: '1.5.0'
		color_mode: .never
		commands: [
			&mut cli.Command{
				name: 'install'
				usage: 'Install package'
			},
		]
		flags: [
			&mut cli.Flag{
				typ: .string
				name: 'flag'
				short: `f`
				usage: 'Flag description'
			},
			&mut cli.Flag{
				typ: .float
				name: 'flag2'
				usage: 'Flag2 description'
				category: 'Category 1'
			},
			&mut cli.Flag{
				typ: .int
				name: 'flag3'
				usage: 'Flag3 description'
				category: 'Category 1'
			},
			&mut cli.Flag{
				typ: .bool
				name: 'flag4'
				usage: 'Flag4 description'
				category: 'Category 2'
			},
			&mut cli.Flag{
				typ: .bool
				name: 'flag5'
				usage: 'Flag5 description'
				category: 'Category 2'
			},
		]
	}

	app.run(['']).unwrap()

	usage := app.get_usage()
	t.assert_eq(usage, 'test-app v1.5.0

USAGE:
    test-app [FLAGS] [COMMAND]

FLAGS:
    -f, --flag <STRING>   Flag description
    -h, --help            Print this help message
    -v, --version         Print the version

Category 1:
        --flag2 <FLOAT>   Flag2 description
        --flag3 <INT>     Flag3 description

Category 2:
        --flag4           Flag4 description
        --flag5           Flag5 description

COMMANDS:
    install    Install package
    help       Shows a list of commands or help for one command
', 'usage should be equal to expected')
}

test "help for command with custom arg usage" {
	mut app := cli.App{
		name: 'test-app'
		color_mode: .never
		args_usage: '[PACKAGES]'
		commands: [
			&mut cli.Command{
				name: 'install'
				usage: 'Install package'
			},
		]
	}

	app.run(['']).unwrap()

	usage := app.get_usage()
	t.assert_eq(usage, 'test-app v1.0.0

USAGE:
    test-app [COMMAND] [PACKAGES]

FLAGS:
    -h, --help     Print this help message
    -v, --version  Print the version

COMMANDS:
    install    Install package
    help       Shows a list of commands or help for one command
', 'usage should be equal to expected')
}

test "help for command with custom description" {
	mut app := cli.App{
		name: 'test-app'
		color_mode: .never
		description: 'Test app description'
		commands: [
			&mut cli.Command{
				name: 'install'
				usage: 'Install package'
			},
		]
	}

	app.run(['']).unwrap()

	usage := app.get_usage()
	t.assert_eq(usage, 'test-app v1.0.0
Test app description

USAGE:
    test-app [COMMAND]

FLAGS:
    -h, --help     Print this help message
    -v, --version  Print the version

COMMANDS:
    install    Install package
    help       Shows a list of commands or help for one command
', 'usage should be equal to expected')
}

test "help for command with flag with long usage" {
	value := "Set output style type (default: auto). Set this to 'basic' to disable output\
              coloring and interactive elements. Set it to 'full' to enable all effects even\
              if no interactive terminal was detected. Set this to 'nocolor' to keep the\
              interactive output without any colors. Set this to 'color' to keep the colors\
              without any interactive output. Set this to 'none' to disable all the output\
              of the tool."

	mut app := cli.App{
		name: 'test-app'
		color_mode: .never
		commands: [
			&mut cli.Command{
				name: 'install'
				usage: 'Install package'
				flags: [
					&mut cli.Flag{
						typ: .bool
						name: 'flag'
						short: `f`
						usage: value
					},
				]
			},
		]
	}

	app.run(['']).unwrap()

	cmd := app.command('install').unwrap()
	mut ctx := cli.Context.new(&mut app)
	ctx.command = cmd

	usage := cmd.get_usage(ctx)
	t.assert_eq(usage, "Install package

USAGE:
    install [FLAGS]

FLAGS:
    -f, --flag  Set output style type (default: auto). Set this to 'basic' to
                disable outputcoloring and interactive elements. Set it to
                'full' to enable all effects evenif no interactive terminal
                was detected. Set this to 'nocolor' to keep theinteractive
                output without any colors. Set this to 'color' to keep the
                colorswithout any interactive output. Set this to 'none' to
                disable all the outputof the tool.

    -h, --help  Print this help message

", 'usage should be equal to expected')
}

test "help for command with flag with long usage and wrap on 50" {
	value := "Set output style type (default: auto). Set this to 'basic' to disable output\
              coloring and interactive elements. Set it to 'full' to enable all effects even\
              if no interactive terminal was detected. Set this to 'nocolor' to keep the\
              interactive output without any colors. Set this to 'color' to keep the colors\
              without any interactive output. Set this to 'none' to disable all the output\
              of the tool."

	mut app := cli.App{
		name: 'test-app'
		color_mode: .never
		commands: [
			&mut cli.Command{
				name: 'install'
				usage: 'Install package'
				help_text_wrap: 50
				flags: [
					&mut cli.Flag{
						typ: .bool
						name: 'flag'
						short: `f`
						usage: value
					},
				]
			},
		]
	}

	app.run(['']).unwrap()

	cmd := app.command('install').unwrap()
	mut ctx := cli.Context.new(&mut app)
	ctx.command = cmd

	usage := cmd.get_usage(ctx)
	t.assert_eq(usage, "Install package

USAGE:
    install [FLAGS]

FLAGS:
    -f, --flag  Set output style type (default: auto). Set this to
                'basic' to disable outputcoloring and interactive
                elements. Set it to 'full' to enable all effects
                evenif no interactive terminal was detected. Set
                this to 'nocolor' to keep theinteractive output
                without any colors. Set this to 'color' to keep the
                colorswithout any interactive output. Set this to
                'none' to disable all the outputof the tool.

    -h, --help  Print this help message

", 'usage should be equal to expected')
}

test "help for command with flag with multiline usage" {
	mut app := cli.App{
		name: 'test-app'
		color_mode: .never
		commands: [
			&mut cli.Command{
				name: 'install'
				usage: 'Install package'
				flags: [
					&mut cli.Flag{
						typ: .bool
						name: 'flag'
						short: `f`
						usage: 'this is a\nmultiline\nusage'
					},
				]
			},
		]
	}

	app.run(['']).unwrap()

	cmd := app.command('install').unwrap()
	mut ctx := cli.Context.new(&mut app)
	ctx.command = cmd

	usage := cmd.get_usage(ctx)
	t.assert_eq(usage, "Install package

USAGE:
    install [FLAGS]

FLAGS:
    -f, --flag  this is a
                multiline
                usage

    -h, --help  Print this help message

", 'usage should be equal to expected')
}

test "command with own help flag" {
	mut app := cli.App{
		commands: [
			&mut cli.Command{
				name: 'install'
				flags: [
					&mut cli.Flag{
						typ: .bool
						name: 'help'
						short: `h`
						usage: 'show some help'
					},
				]
			},
		]
	}

	app.run(['install']).unwrap()

	cmd := app.command('install').unwrap()
	mut ctx := cli.Context.new(&mut app)
	ctx.command = cmd

	usage := cmd.get_usage(ctx)
	t.assert_eq(usage, "USAGE:
    install

FLAGS:
    -h, --help  show some help
", 'usage should be equal to expected')
}
