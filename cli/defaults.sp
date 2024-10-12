module cli

import mem

var fake_true_val = true

const HELP_FLAG = mem.to_heap_mut[Flag](&mut Flag{
	name: 'help'
	short: `h`
	typ: .bool
	usage: 'Print this help message'
	default: none
	value: &mut fake_true_val
})

const VERSION_FLAG = mem.to_heap_mut[Flag](&mut Flag{
	name: 'version'
	short: `v`
	typ: .bool
	usage: 'Print the version'
	default: none
	value: &mut fake_true_val
})

const HELP_COMMAND = mem.to_heap_mut[Command](&mut Command{
	name: 'help'
	usage: 'Shows a list of commands or help for one command'
	args_usage: '[command]'
	action: fn (ctx &mut Context) -> ! {
		if ctx.parent == none {
			println(ctx.app.usage(ctx))
			return
		}

		if ctx.command.name != HELP_COMMAND.name {
			println(ctx.command.usage(ctx))
			return
		}

		args := ctx.args()

		// when call `app help` print the app usage
		if ctx.parent.command.is_root && args.len == 0 {
			println(ctx.app.usage(ctx))
			return
		}

		// when call `app help command` print the command usage
		if cmd_name := args.get(0) {
			parent_ctx := ctx.parent.unwrap()
			if cmd := parent_ctx.command.command(cmd_name) {
				mut cmd_ctx := Context.new(ctx.app)
				cmd_ctx.command = cmd
				cmd_ctx.parent = parent_ctx
				println(cmd.usage(cmd_ctx))
				return
			}
		}

		println(ctx.command.usage(ctx))
	}
})
