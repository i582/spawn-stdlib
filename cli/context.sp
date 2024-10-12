module cli

pub struct Context {
	app      &mut App
	command  &mut Command
	flag_set FlagSet

	parent ?&mut Context
}

pub fn Context.new(app &mut App) -> &mut Context {
	return &mut Context{
		app: app
		command: &mut Command{}
	}
}

pub fn (c &Context) full_cmd_name() -> string {
	if c.parent == none {
		return c.command.name
	}

	return c.parent.full_cmd_name() + " " + c.command.name
}

pub fn (c &Context) args() -> []string {
	return c.flag_set.args
}

pub fn (c &Context) get_string(name string) -> ?string {
	if f := c.flag_set.lookup_actual(name) {
		if f.value is &mut string {
			return *f.value
		}
	}

	// flag is not present, try to return the default value
	if f := c.flag_set.lookup(name) {
		if f.default != none {
			if f.value is &mut string {
				return *f.value
			}
		}
	}

	return none
}

pub fn (c &Context) get_i32(name string) -> ?i32 {
	if f := c.flag_set.lookup_actual(name) {
		if f.value is &mut i32 {
			return *f.value
		}
	}

	// flag is not present, try to return the default value
	if f := c.flag_set.lookup(name) {
		if f.default != none {
			if f.value is &mut i32 {
				return *f.value
			}
		}
	}

	return none
}

pub fn (c &Context) get_f64(name string) -> ?f64 {
	if f := c.flag_set.lookup_actual(name) {
		if f.value is &mut f64 {
			return *f.value
		}
	}

	// flag is not present, try to return the default value
	if f := c.flag_set.lookup(name) {
		if f.default != none {
			if f.value is &mut f64 {
				return *f.value
			}
		}
	}

	return none
}

pub fn (c &Context) get_bool(name string) -> ?bool {
	if f := c.flag_set.lookup_actual(name) {
		if f.value is &mut bool {
			return *f.value
		}
	}

	// flag is not present, try to return the default value
	if f := c.flag_set.lookup(name) {
		if f.default != none {
			if f.value is &mut bool {
				return *f.value
			}
		}
	}

	return none
}
