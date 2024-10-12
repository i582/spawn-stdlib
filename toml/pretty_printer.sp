module toml

import strings

pub struct PrettyPrinter {
	buf strings.Builder
}

pub fn PrettyPrinter.new() -> PrettyPrinter {
	return PrettyPrinter{ buf: strings.new_builder(100) }
}

pub fn (p &mut PrettyPrinter) print(file File) -> string {
	for i, table in file.tables {
		p.print_table(table, i)
	}

	return p.buf.str_view()
}

pub fn (p &mut PrettyPrinter) print_key(key Key) {
	match key {
		EmptyKey => ''
		Ident => p.print_ident(key)
		String => p.buf.write_str(key.value)
		DottedKey => {
			keys := key.keys
			for i, part in keys {
				p.print_key(part)
				if i < keys.len - 1 {
					p.buf.write_str(".")
				}
			}
		}
	}
}

pub fn (p &mut PrettyPrinter) print_ident(ident Ident) {
	p.print_ff(ident.ff)
	p.buf.write_str(ident.value)
	p.print_ff(ident.ff_after)
}

pub fn (p &mut PrettyPrinter) print_table(table Table, index i32) {
	if index > 0 {
		p.buf.write_str("\n")
	}

	p.print_ff(table.ff)
	p.buf.write_str("[")
	if table.is_array {
		p.buf.write_str("[")
	}

	p.print_key(table.key)

	if table.is_array {
		p.buf.write_str("]")
	}
	p.buf.write_str("]\n")
	p.print_ff(table.ff_after)

	for entry in table.entries {
		p.print_entry(entry)
	}
}

pub fn (p &mut PrettyPrinter) print_entry(entry KeyValue) {
	p.print_ff(entry.ff)
	p.print_key(entry.key)
	p.buf.write_str(" = ")
	p.print_value(entry.value)
	p.buf.write_str('\n')
}

pub fn (p &mut PrettyPrinter) print_value(value Value) {
	match value {
		String => {
			p.print_ff(value.ff)
			p.buf.write_str(value.value)
			p.print_ff(value.ff_after)
		}
		Integer => {
			p.print_ff(value.ff)
			p.buf.write_str(value.value)
			p.print_ff(value.ff_after)
		}
		Float => {
			p.print_ff(value.ff)
			p.buf.write_str(value.value)
			p.print_ff(value.ff_after)
		}
		Boolean => {
			p.print_ff(value.ff)
			p.buf.write_str(value.value.str())
			p.print_ff(value.ff_after)
		}
		TomlArray => p.print_array(value)
		InlineTable => p.print_inline_table(value)
	}
}

pub fn (p &mut PrettyPrinter) print_array(value TomlArray) {
	p.print_ff(value.ff)
	p.buf.write_str("[")
	for i, val in value.values {
		p.print_value(val)
		if i < value.values.len - 1 {
			p.buf.write_str(", ")
		}
	}
	p.buf.write_str("]")
	p.print_ff(value.ff_after)
}

pub fn (p &mut PrettyPrinter) print_inline_table(value InlineTable) {
	p.print_ff(value.ff)
	p.buf.write_str("{")
	if value.entries.len > 0 {
		p.buf.write_str(" ")
	}
	for i, entry in value.entries {
		p.print_key(entry.key)
		p.buf.write_str(" = ")
		p.print_value(entry.value)

		if i < value.entries.len - 1 {
			p.buf.write_str(", ")
		}
	}
	if value.entries.len > 0 {
		p.buf.write_str(" ")
	}
	p.buf.write_str("}")
	p.print_ff(value.ff_after)
}

pub fn (p &mut PrettyPrinter) print_ff(ffs []FreeFloating) {
	for ff in ffs {
		match ff {
			Comment => {
				// if ff.inline {
				//     p.buf.write_str(" ")
				// }
				p.buf.write_str("#")
				p.buf.write_str(ff.value)
				// if !ff.inline {
				p.buf.write_str("\n")
				// }
			}
			Whitespace => {}
		}
	}
}
