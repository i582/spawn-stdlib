module syntax

import mem
import intrinsics

// Parser struct represent a JSON parser.
pub struct Parser {
	scan Scanner

	tok Token
	off usize
	lit string

	errors []ParseError
}

// new creates a new instance of [`Parser`].
//
// Example:
// ```
// p := syntax.Parser.new('{ "name": "John" }')
// file := p.parse_file().unwrap()
// assert file.obj.string_field('name').unwrap() == 'John'
// ```
pub fn Parser.new(str string) -> Parser {
	return Parser{ scan: Scanner.new(str) }
}

// parse_file parses the entire JSON document and returns a [`File`]
// with the document tree.
//
// If there are any errors during parsing, [`parse_file`] will return
// the first one. For other values, see the [`Parser.errors`] field.
//
// Example:
// ```
// p := syntax.Parser.new('{ "name": "John" }')
// file := p.parse_file().unwrap()
// assert file.obj.string_field('name').unwrap() == 'John'
// ```
pub fn (p &mut Parser) parse_file() -> ![File, ParseError] {
	p.scan.skip_bom()
	p.next()
	obj := p.parse_object()
	if p.scan.errors.len > 0 {
		return error(p.scan.errors.first())
	}
	if p.errors.len > 0 {
		return error(p.errors.first())
	}
	return File{ obj: obj }
}

fn (p &mut Parser) next() -> Token {
	p.off, p.tok, p.lit = p.scan.scan()
	return p.tok
}

fn (p &mut Parser) eat(t Token) -> string {
	if intrinsics.unlikely(p.tok != t) {
		p.report_unexpected(t)
	}

	val := p.lit
	p.next() // advance even this token is not expected to prevent infinite parsing
	return val
}

#[no_inline] // keep the hot path as short as possible
fn (p &mut Parser) report_unexpected(t Token) {
	p.report(p.off, "unexpected token ${p.tok}, expected ${t}")
}

#[no_inline] // keep the hot path as short as possible
fn (p &mut Parser) report(off usize, msg string) {
	p.errors.push(ParseError{ off: off, msg: msg })
}

fn (p &mut Parser) parse_object() -> Object {
	p.eat(.lbrace)
	if p.tok == .rbrace {
		// empty object literal
		p.next()
		return Object{}
	}

	// we have at least one element
	mut root := mem.to_heap_mut(&mut KeyValue{})
	mut first := root

	for p.tok != .eof {
		p.parse_key_value(first)

		if p.tok == .rbrace || p.tok == .eof {
			break
		}
		p.eat(.comma)

		next := mem.to_heap_mut(&mut KeyValue{})
		first.next = next
		first = next
	}

	p.eat(.rbrace)
	return Object{ head: root }
}

fn (p &mut Parser) parse_key_value(kv &mut KeyValue) {
	key := p.eat(.string)
	kv.key = if key.len > 2 { key[1..key.len - 1] } else { key }
	p.eat(.colon)
	kv.value = p.parse_value()
}

fn (p &mut Parser) parse_value() -> Value {
	val := match p.tok {
		.string => p.lit[1..p.lit.len - 1] as Value
		.number => Number{ value: p.lit } as Value
		.true_ => true as Value
		.false_ => false as Value
		.null => Null{} as Value
		.lbrack => return p.parse_array() as Value
		.lbrace => return p.parse_object() as Value
		else => {
			p.report(p.off, 'unexpected token ${p.tok}')
			return Null{}
		}
	}
	p.next()
	return val
}

fn (p &mut Parser) parse_array() -> JsonArray {
	p.next()

	if p.tok == .rbrack {
		// empty array literal
		p.next()
		return JsonArray{}
	}

	// we have at least one element
	mut root := mem.to_heap_mut(&mut JsonArrayElement{})
	mut first := root

	for p.tok != .eof {
		first.val = p.parse_value()

		if p.tok == .rbrack {
			break
		}

		p.eat(.comma)
		next := mem.to_heap_mut(&mut JsonArrayElement{})
		first.next = next
		first = next
	}

	p.eat(.rbrack)
	return JsonArray{ head: root }
}
