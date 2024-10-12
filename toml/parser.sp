module toml

import toml.token

pub struct Parser {
	scan &mut Scanner

	tok token.Token // 1 token look-ahead
	pos token.Pos
	lit string

	report_cb ErrorCallback
}

pub fn Parser.new(scan &mut Scanner, report_cb ErrorCallback) -> &mut Parser {
	return &mut Parser{ scan: scan, report_cb: report_cb }
}

pub fn (p &mut Parser) next() -> token.Token {
	p.pos, p.tok, p.lit = p.scan.scan()
	return p.tok
}

#[track_caller]
pub fn (p &mut Parser) expect(t token.Token) {
	if p.tok != t {
		p.report_cb(ParseError.new(p.pos, "unexpected token ${p.tok}, expected ${t}"))
	}
}

pub fn (p &mut Parser) eat_newline() {
	if p.tok != .newline && p.tok != .eof {
		p.report_cb(ParseError.new(p.pos, "unexpected token ${p.tok}, expected newline"))
		return
	}

	p.next()
}

pub fn (p &mut Parser) parse_file() -> File {
	p.skip_newlines()

	mut tables := []Table{}

	for p.tok != .eof {
		// if there is root level key-value pair
		if p.tok == .ident {
			entries := p.parse_table_key_values()
			tables.push(Table{ key: EmptyKey{}, entries: entries })
		}

		p.skip_newlines()

		if table := p.parse_table() {
			tables.push(table)
		}

		if table := p.parse_inline_array_table() {
			tables.push(table)
		}

		if p.tok == .newline {
			p.next()
			continue
		}
	}

	return File{ tables: tables }
}

pub fn (p &mut Parser) parse_table() -> ?Table {
	ff := p.parse_free_floating()
	key := p.try_parse_table_name()?

	p.skip_newlines()

	// [table]
	// [other.table]
	// ^ here
	if p.tok == .lbrack {
		return Table{
			ff: ff
			key: key
		}
	}

	entries := p.parse_table_key_values()

	ff_after := p.parse_free_floating()

	return Table{
		ff: ff
		ff_after: ff_after
		key: key
		entries: entries
	}
}

pub fn (p &mut Parser) parse_table_key_values() -> []KeyValue {
	mut entries := []KeyValue{}

	for p.tok != .lbrack && p.tok != .double_lbrack && p.tok != .eof {
		if entry := p.parse_key_value(false) {
			entries.push(entry)
		}

		p.skip_whitespace()
		p.skip_newlines()
	}

	return entries
}

pub fn (p &mut Parser) parse_inline_array_table() -> ?Table {
	ff := p.parse_free_floating()
	key := p.try_parse_array_table_name()?

	p.skip_newlines()

	if p.tok == .lbrace || p.tok == .double_lbrack {
		return Table{
			ff: ff
			key: key
			is_array: true
		}
	}

	mut entries := []KeyValue{}

	for p.tok != .lbrack && p.tok != .double_lbrack && p.tok != .eof {
		if entry := p.parse_key_value(false) {
			entries.push(entry)
		}
	}

	ff_after := p.parse_free_floating()

	return Table{
		ff: ff
		ff_after: ff_after
		key: key
		entries: entries
		is_array: true
	}
}

pub fn (p &mut Parser) try_parse_table_name() -> ?Key {
	if p.tok != .lbrack {
		return none
	}

	p.next()

	key := p.parse_full_key()

	p.expect(.rbrack)
	p.next()
	p.skip_newlines()

	return key
}

pub fn (p &mut Parser) try_parse_array_table_name() -> ?Key {
	if p.tok != .double_lbrack {
		return none
	}

	p.next()

	key := p.parse_full_key()

	p.expect(.double_rbrack)
	p.next()
	p.skip_newlines()

	return key
}

pub fn (p &mut Parser) parse_ident() -> Ident {
	ff := p.parse_free_floating()
	p.expect(.ident)
	mut ident := Ident{ ff: ff, pos: p.pos, value: p.lit }
	p.next()
	ff_after := p.parse_free_floating()
	ident.ff_after = ff_after
	return ident
}

pub fn (p &mut Parser) parse_string() -> String {
	ff := p.parse_free_floating()
	pos := p.pos
	lit := p.lit
	p.next()
	ff_after := p.parse_free_floating()
	return String{
		ff: ff
		ff_after: ff_after
		pos: pos
		value: lit
	}
}

pub fn (p &mut Parser) parse_key() -> Ident {
	return p.parse_ident()
}

pub fn (p &mut Parser) parse_full_key() -> Key {
	part := p.parse_key_part()
	p.skip_whitespace()
	if p.tok != .dot {
		return part
	}

	mut parts := [part]
	for p.tok == .dot {
		p.next()
		p.skip_whitespace()
		parts.push(p.parse_key_part())
		p.skip_whitespace()
	}

	return DottedKey{ keys: parts }
}

pub fn (p &mut Parser) parse_key_part() -> Key {
	return if p.tok == .string {
		p.parse_string() as Key
	} else if p.tok == .ident {
		p.parse_ident() as Key
	} else {
		p.report_cb(ParseError.new(p.pos, "unexpected token ${p.tok}, expected string or identifier"))
		Ident{} as Key
	}
}

pub fn (p &mut Parser) parse_key_value(inline bool) -> ?KeyValue {
	ff := p.parse_free_floating()

	if p.tok == .newline {
		p.next()
		return none
	}

	key := p.parse_full_key()

	p.expect(.assign)
	p.next()

	p.skip_whitespace()

	value := p.parse_value()

	if !inline {
		p.eat_newline()
		p.skip_newlines()
	} else if p.tok == .newline {
		p.report_cb(ParseError.new(p.pos, "unexpected newline in inline table"))
		p.next()
	}

	return KeyValue{ ff: ff, key: key, value: value }
}

pub fn (p &mut Parser) parse_value() -> Value {
	ff := p.parse_free_floating()

	match p.tok {
		.integer => {
			pos := p.pos
			lit := p.lit
			p.next()
			ff_after := p.parse_free_floating()
			return Integer{
				ff: ff
				ff_after: ff_after
				pos: pos
				value: lit
			}
		}
		.float => {
			pos := p.pos
			lit := p.lit
			p.next()
			ff_after := p.parse_free_floating()
			return Float{
				ff: ff
				ff_after: ff_after
				pos: pos
				value: lit
			}
		}
		.string, .triple_string => {
			pos := p.pos
			lit := p.lit
			tok := p.tok
			p.next()
			ff_after := p.parse_free_floating()
			return String{
				ff: ff
				ff_after: ff_after
				pos: pos
				value: lit
				tok: tok
			}
		}
		.true_ => {
			pos := p.pos
			p.next()
			ff_after := p.parse_free_floating()
			return Boolean{
				ff: ff
				ff_after: ff_after
				pos: pos
				value: true
			}
		}
		.false_ => {
			pos := p.pos
			p.next()
			ff_after := p.parse_free_floating()
			return Boolean{
				ff: ff
				ff_after: ff_after
				pos: pos
				value: false
			}
		}
		.lbrack => {
			p.next()
			return p.parse_array()
		}
		.lbrace => {
			p.next()
			return p.parse_inline_table()
		}
		else => p.report_cb(ParseError.new(p.pos, "unexpected token ${p.tok}"))
	}

	p.report_cb(ParseError.new(p.pos, "unexpected token ${p.tok}"))
	return String{}
}

pub fn (p &mut Parser) parse_array() -> TomlArray {
	ff := p.parse_free_floating()

	p.skip_whitespace()
	p.skip_newlines()

	mut values := []Value{}

	for p.tok != .rbrack {
		value := p.parse_value()
		values.push(value)

		if p.tok == .comma {
			p.next()
		}

		if p.tok == .newline {
			p.next()
		}
	}

	p.skip_whitespace()
	p.skip_newlines()

	p.expect(.rbrack)
	p.next()

	ff_after := p.parse_free_floating()

	return TomlArray{ ff: ff, ff_after: ff_after, values: values }
}

pub fn (p &mut Parser) parse_inline_table() -> InlineTable {
	ff := p.parse_free_floating()

	mut entries := []KeyValue{}

	for p.tok != .eof {
		if entry := p.parse_key_value(true) {
			entries.push(entry)
		}

		if p.tok == .rbrace {
			break
		}

		p.expect(.comma)
		p.next()

		p.skip_whitespace()

		if p.tok == .rbrace {
			p.report_cb(ParseError.new(p.pos, "trailing comma is not allowed in inline table"))
			break
		}

		if p.tok == .newline {
			p.report_cb(ParseError.new(p.pos, "unexpected newline in inline table"))
			p.next()
		}
	}

	p.expect(.rbrace)
	p.next()

	ff_after := p.parse_free_floating()

	return InlineTable{ ff: ff, ff_after: ff_after, entries: entries }
}

pub fn (p &mut Parser) parse_free_floating() -> []FreeFloating {
	mut free_floating := []FreeFloating{}

	mut was_newline := false

	for p.tok != .eof {
		if p.tok == .whitespace {
			free_floating.push(Whitespace{ pos: p.pos, value: p.lit })
			if p.lit.contains("\n") {
				was_newline = true
			}
			p.next()
		} else if p.tok == .comment {
			free_floating.push(Comment{ inline: !was_newline, pos: p.pos, value: p.lit })
			p.next()
			if p.tok == .newline {
				p.next()
			}
		} else {
			break
		}
	}

	return free_floating
}

pub fn (p &mut Parser) parse_comments() -> []Comment {
	mut comments := []Comment{}

	for p.tok == .comment {
		comments.push(Comment{ pos: p.pos, value: p.lit })
		p.next()

		p.skip_newlines()
	}

	return comments
}

pub fn (p &mut Parser) skip_newlines() {
	for p.tok == .newline {
		p.next()
	}
}

pub fn (p &mut Parser) skip_whitespace() {
	for p.tok == .whitespace {
		p.next()
	}
}

pub fn (p &mut Parser) parse() -> File {
	p.next()
	return p.parse_file()
}
