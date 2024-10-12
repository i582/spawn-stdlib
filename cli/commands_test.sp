module main

import cli

test "execute single command" {
	mut install_executed := false

	mut app := cli.App{
		commands: [
			&mut cli.Command{
				name: 'install'
				action: fn (_ &mut cli.Context) -> ! {
					install_executed = true
				}
			},
		]
	}

	app.run(['install']).unwrap()

	t.assert_true(install_executed, 'install command should be executed')
}

test "root action" {
	mut action_executed := false
	mut install_executed := false

	mut app := cli.App{
		action: fn (_ &mut cli.Context) -> ! {
			action_executed = true
		}
		flags: [
			&mut cli.Flag{
				typ: .bool
				name: 'flag'
			},
		]
		commands: [
			&mut cli.Command{
				name: 'install'
				action: fn (_ &mut cli.Context) -> ! {
					install_executed = true
				}
			},
		]
	}

	app.run([]).unwrap()

	t.assert_true(action_executed, 'root command should be executed')
	t.assert_false(install_executed, 'install command should not be executed')

	action_executed = false
	install_executed = false

	app.run(['--flag']).unwrap()

	t.assert_true(action_executed, 'root command should be executed')
	t.assert_false(install_executed, 'install command should not be executed')

	action_executed = false
	install_executed = false

	app.run(['install']).unwrap()

	t.assert_false(action_executed, 'root command should not be executed')
	t.assert_true(install_executed, 'install command should be executed')
}

test "execute command from several registered" {
	mut install_executed := false
	mut publish_executed := false

	mut app := cli.App{
		commands: [
			&mut cli.Command{
				name: 'install'
				action: fn (_ &mut cli.Context) -> ! {
					install_executed = true
				}
			},
			&mut cli.Command{
				name: 'publish'
				action: fn (_ &mut cli.Context) -> ! {
					publish_executed = true
				}
			},
		]
	}

	app.run(['install']).unwrap()

	t.assert_true(install_executed, 'install command should be executed')
	t.assert_false(publish_executed, 'publish command should not be executed')

	install_executed = false
	publish_executed = false
	app.run(['publish']).unwrap()

	t.assert_false(install_executed, 'install command should not be executed')
	t.assert_true(publish_executed, 'publish command should be executed')
}

test "execute single command with single bool flag" {
	mut app := cli.App{
		commands: [
			&mut cli.Command{
				name: 'install'
				flags: [
					&mut cli.Flag{
						typ: .bool
						name: 'force'
					},
				]
				action: fn (ctx &mut cli.Context) -> ! {
					force_value := ctx.get_bool('force') or { false }
					t.assert_true(force_value, 'force flag should be true')
				}
			},
		]
	}

	app.run(['install', '--force']).unwrap()
}

test "execute single command with single bool flag with explicit true value" {
	mut app := cli.App{
		commands: [
			&mut cli.Command{
				name: 'install'
				flags: [
					&mut cli.Flag{
						typ: .bool
						name: 'force'
					},
				]
				action: fn (ctx &mut cli.Context) -> ! {
					force_value := ctx.get_bool('force') or { false }
					t.assert_true(force_value, 'force flag should be true')
				}
			},
		]
	}

	app.run(['install', '--force=true']).unwrap()
}

test "execute single command with single string flag without value" {
	mut app := cli.App{
		commands: [
			&mut cli.Command{
				name: 'install'
				flags: [
					&mut cli.Flag{
						typ: .string
						name: 'name'
					},
				]
				action: fn (ctx &mut cli.Context) -> ! {
					name_value := ctx.get_string('name') or { '' }
					t.assert_eq(name_value, '', 'name flag should be empty')
				}
			},
		]
	}

	app.run(['install']).unwrap()
}

test "execute single command with single string flag without value and with default" {
	mut app := cli.App{
		commands: [
			&mut cli.Command{
				name: 'install'
				flags: [
					&mut cli.Flag{
						typ: .string
						name: 'name'
						default: 'default'
					},
				]
				action: fn (ctx &mut cli.Context) -> ! {
					name_value := ctx.get_string('name') or { '' }
					t.assert_eq(name_value, 'default', 'name flag should be empty')
				}
			},
		]
	}

	app.run(['install']).unwrap()
}

test "execute single command with several flags" {
	mut app := cli.App{
		commands: [
			&mut cli.Command{
				name: 'install'
				flags: [
					&mut cli.Flag{
						typ: .bool
						name: 'force'
						default: false
					},
					&mut cli.Flag{
						typ: .string
						name: 'name'
					},
				]
				action: fn (ctx &mut cli.Context) -> ! {
					force_value := ctx.get_bool('force') or { false }
					t.assert_true(force_value, 'force flag should be true')

					name_value := ctx.get_string('name') or { '' }
					t.assert_eq(name_value, 'test', 'name flag should be "test"')
				}
			},
		]
	}

	app.run(['install', '--force', '--name', 'test']).unwrap()
}

test "execute single command with int and float flags" {
	mut app := cli.App{
		commands: [
			&mut cli.Command{
				name: 'install'
				flags: [
					&mut cli.Flag{
						typ: .int
						name: 'count'
					},
					&mut cli.Flag{
						typ: .float
						name: 'frac'
					},
				]
				action: fn (ctx &mut cli.Context) -> ! {
					count_value := ctx.get_i32('count') or { 0 }
					t.assert_eq(count_value, 10, 'count flag should be 10')

					frac_value := ctx.get_f64('frac') or { 0.0 }
					t.assert_eq(frac_value, 0.5, 'frac flag should be 0.5')
				}
			},
		]
	}

	app.run(['install', '--count', '10', '--frac', '0.5']).unwrap()
}

test "execute single command with int flag with invalid value" {
	mut app := cli.App{
		commands: [
			&mut cli.Command{
				name: 'install'
				flags: [
					&mut cli.Flag{
						typ: .int
						name: 'count'
					},
				]
			},
		]
	}

	app.run(['install', '--count', 'a10']) or {
		t.assert_eq(err.msg(), 'invalid value `a10` for flag --count: invalid number `a10`', 'actual error message should be equal to expected')
		return
	}

	t.fail('install command should return an error')
}

test "execute single command with float flag with invalid value" {
	mut app := cli.App{
		commands: [
			&mut cli.Command{
				name: 'install'
				flags: [
					&mut cli.Flag{
						typ: .float
						name: 'frac'
					},
				]
			},
		]
	}

	app.run(['install', '--frac', 'a10.0']) or {
		t.assert_eq(err.msg(), 'invalid value `a10.0` for flag --frac: invalid number `a10.0`', 'actual error message should be equal to expected')
		return
	}

	t.fail('install command should return an error')
}

test "execute single command with int and float flags with defaults" {
	mut app := cli.App{
		commands: [
			&mut cli.Command{
				name: 'install'
				flags: [
					&mut cli.Flag{
						typ: .int
						name: 'count'
						default: 100
					},
					&mut cli.Flag{
						typ: .float
						name: 'frac'
						default: 0.1
					},
				]
				action: fn (ctx &mut cli.Context) -> ! {
					count_value := ctx.get_i32('count') or { 0 }
					t.assert_eq(count_value, 100, 'count flag should be 100')

					frac_value := ctx.get_f64('frac') or { 0.0 }
					t.assert_eq(frac_value, 0.1, 'frac flag should be 0.1')
				}
			},
		]
	}

	app.run(['install']).unwrap()
}

test "execute single command with string flag without value" {
	mut app := cli.App{
		commands: [
			&mut cli.Command{
				name: 'install'
				flags: [
					&mut cli.Flag{
						typ: .string
						name: 'name'
					},
				]
			},
		]
	}

	app.run(['install', '--name']) or {
		t.assert_eq(err.msg(), 'flag needs an argument: --name', 'actual error message should be equal to expected')
		return
	}

	t.fail('install command should return an error')
}

test "execute single command with arguments" {
	mut app := cli.App{
		commands: [
			&mut cli.Command{
				name: 'install'
				action: fn (ctx &mut cli.Context) -> ! {
					args := ctx.args()
					t.assert_eq(args.str(), ['spawn.sp', 'other.sp'].str(), 'args should be ["spawn.sp", "other.sp"]')
				}
			},
		]
	}

	app.run(['install', 'spawn.sp', 'other.sp']).unwrap()
}

test "execute single command with arguments after flags" {
	mut app := cli.App{
		commands: [
			&mut cli.Command{
				name: 'install'
				flags: [
					&mut cli.Flag{
						typ: .bool
						name: 'force'
					},
					&mut cli.Flag{
						typ: .string
						name: 'name'
					},
				]
				action: fn (ctx &mut cli.Context) -> ! {
					args := ctx.args()
					t.assert_eq(args.str(), ['spawn.sp', 'other.sp'].str(), 'args should be ["spawn.sp", "other.sp"]')
				}
			},
		]
	}

	app.run(['install', '--force', '--name', 'test', 'spawn.sp', 'other.sp']).unwrap()
}

test "execute single command with arguments after flags with --" {
	mut app := cli.App{
		commands: [
			&mut cli.Command{
				name: 'install'
				flags: [
					&mut cli.Flag{
						typ: .bool
						name: 'force'
					},
					&mut cli.Flag{
						typ: .string
						name: 'name'
					},
				]
				action: fn (ctx &mut cli.Context) -> ! {
					args := ctx.args()
					t.assert_eq(args.str(), ['--force', '--name', 'test', 'spawn.sp', 'other.sp'].str(), 'args should be ["spawn.sp", "other.sp"]')
				}
			},
		]
	}

	app.run(['install', '--', '--force', '--name', 'test', 'spawn.sp', 'other.sp']).unwrap()
}

test "execute nested command" {
	mut package_executed := false

	mut app := cli.App{
		commands: [
			&mut cli.Command{
				name: 'get'
				subcommands: [
					&mut cli.Command{
						name: 'package'
						action: fn (_ &mut cli.Context) -> ! {
							package_executed = true
						}
					},
				]
			},
		]
	}

	app.run(['get', 'package']).unwrap()

	t.assert_true(package_executed, 'package command should be executed')
}

test "execute nested command with flags for first level command" {
	mut package_executed := false

	mut app := cli.App{
		commands: [
			&mut cli.Command{
				name: 'get'
				flags: [
					&mut cli.Flag{
						typ: .bool
						name: 'force'
					},
				]
				subcommands: [
					&mut cli.Command{
						name: 'package'
						action: fn (ctx &mut cli.Context) -> ! {
							force_value := ctx.parent.unwrap().get_bool('force') or {
								t.fail('force flag should be set')
								true
							}

							t.assert_true(force_value, 'force flag should be true')
							package_executed = true
						}
					},
				]
			},
		]
	}

	app.run(['get', '--force', 'package']).unwrap()

	t.assert_true(package_executed, 'package command should be executed')
}

test "skip flag parsing" {
	mut app := cli.App{
		commands: [
			&mut cli.Command{
				name: 'get'
				skip_flag_parsing: true
				action: fn (ctx &mut cli.Context) -> ! {
					args := ctx.args()
					t.assert_eq(args.str(), ['--foo', '--bar=10'].str(), 'args should be ["--foo", "--bar=10"]')
				}
			},
		]
	}

	app.run(['get', '--foo', '--bar=10']).expect('flag parsing should be skipped')
}

test "don't skip flag parsing" {
	mut app := cli.App{
		commands: [
			&mut cli.Command{
				name: 'get'
				action: fn (_ &mut cli.Context) -> ! {
					t.fail('this should not be executed')
				}
			},
		]
	}

	app.run(['get', '--foo', '--bar=10']) or {
		t.assert_eq(err.msg(), 'flag provided but not defined: --foo', 'actual error message should be equal to expected')
		return
	}

	t.fail('flag parsing should not be skipped')
}

test "command with alias" {
	mut install_executed := false

	mut app := cli.App{
		commands: [
			&mut cli.Command{
				name: 'install'
				aliases: ['i']
				skip_flag_parsing: true
				action: fn (_ &mut cli.Context) -> ! {
					install_executed = true
				}
			},
		]
	}

	app.run(['i']).unwrap()

	t.assert_true(install_executed, 'install command should be executed')
}

test "subcommand with alias" {
	mut install_executed := false
	mut install_package_executed := false

	mut app := cli.App{
		commands: [
			&mut cli.Command{
				name: 'install'
				aliases: ['i']
				skip_flag_parsing: true
				action: fn (_ &mut cli.Context) -> ! {
					install_executed = true
				}
				subcommands: [
					&mut cli.Command{
						name: 'package'
						aliases: ['p']
						action: fn (_ &mut cli.Context) -> ! {
							install_package_executed = true
						}
					},
				]
			},
		]
	}

	app.run(['i', 'p']).unwrap()

	t.assert_false(install_executed, 'install command should not be executed')
	t.assert_true(install_package_executed, 'install package command should be executed')
}

test "command that return an error" {
	mut app := cli.App{
		commands: [
			&mut cli.Command{
				name: 'install'
				action: fn (_ &mut cli.Context) -> ! {
					return error('something went wrong')
				}
			},
		]
	}

	app.run(['install']) or {
		t.assert_eq(err.msg(), 'something went wrong', 'actual error message should be equal to expected')
		return
	}

	t.fail('install command should return an error')
}

test "error if flag is not set" {
	mut app := cli.App{
		commands: [
			&mut cli.Command{
				name: 'install'
				flags: [
					&mut cli.Flag{
						typ: .bool
						name: 'force'
					},
				]
				action: fn (ctx &mut cli.Context) -> ! {
					force := ctx.get_bool('force') or {
						return error('`--force` flag is not set')
					}

					t.assert_true(force, 'force flag should be true')
				}
			},
		]
	}

	app.run(['install']) or {
		t.assert_eq(err.msg(), '`--force` flag is not set', 'actual error message should be equal to expected')
		return
	}

	t.fail('install command should return an error')
}
