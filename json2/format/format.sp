module format

import json2.syntax
import strings

// format formats passed [`syntax.File`].
//
// Example:
// ```
// import json2.syntax
//
// mut p := syntax.Parser.new('{ "name": "John" }')
// file := p.parse_file().unwrap()
// println(format.format(file))
// ```
pub fn format(file syntax.File) -> string {
	mut f := Formatter{ sb: strings.new_builder(100) }
	f.format_object(file.obj)
	return f.sb.str_view()
}

// format_compact outputs passed [`syntax.File`] without any whitespaces.
//
// Example:
// ```
// import json2.syntax
//
// mut p := syntax.Parser.new('{ "name": "John" }')
// file := p.parse_file().unwrap()
// assert format.format_compact(file) == '{"name":"John"}'
// ```
pub fn format_compact(file syntax.File) -> string {
	mut f := Formatter{ sb: strings.new_builder(100), compact: true }
	f.format_object(file.obj)
	return f.sb.str_view()
}

enum ElementKind {
	object
	array
}

struct Formatter {
	sb strings.Builder

	compact   bool
	last_elem []bool
	parents   []ElementKind
	indent    i32
}

fn (f &mut Formatter) print_indents() {
	if f.compact {
		return
	}

	for i in 0 .. f.indent {
		f.sb.write_str('    ')
	}
}

fn (f &mut Formatter) print_whitespace(ch u8) {
	if f.compact {
		return
	}

	f.sb.write_u8(ch)
}

fn (f &mut Formatter) format_object(obj syntax.Object) {
	f.sb.write_u8(b`{`)
	f.print_whitespace(b`\n`)

	f.indent++
	f.parents.push(.object)

	mut cur := obj.head
	for cur != none {
		f.format_key_value(cur)

		if cur.next != none {
			f.sb.write_u8(b`,`)
		}
		value := cur.value
		if value !is syntax.Object && value !is syntax.JsonArray {
			f.print_whitespace(b`\n`)
		}
		cur = cur.unwrap().next
	}

	f.parents.remove_last()
	f.indent--

	f.print_indents()
	f.sb.write_u8(b`}`)

	is_array_element := f.parents.last_or_none() or { .object } == .array
	if !is_array_element {
		f.print_whitespace(b`\n`)
	}
}

fn (f &mut Formatter) format_key_value(kv &syntax.KeyValue) {
	f.print_indents()
	f.format_string(kv.key)
	f.sb.write_str(":")
	f.print_whitespace(b` `)
	f.format_value(kv.value)
}

fn (f &mut Formatter) format_value(val syntax.Value) {
	match val {
		string => f.format_string(val)
		bool => f.sb.write_str(val.str())
		syntax.Number => f.sb.write_str(val.value)
		syntax.JsonArray => f.format_array(val)
		syntax.Object => f.format_object(val)
		syntax.Null => f.sb.write_str("null")
	}
}

fn (f &mut Formatter) format_array(arr syntax.JsonArray) {
	f.sb.write_u8(b`[`)

	mut elements := []syntax.Value{}
	mut cur := arr.head
	for cur != none {
		elements.push(cur.val)
		cur = cur.next
	}

	multiline := elements.any(|el| el is syntax.Object || el is syntax.JsonArray)
	if multiline {
		f.print_whitespace(b`\n`)
	}

	f.indent++
	f.parents.push(.array)

	for index, elem in elements {
		if multiline {
			f.print_indents()
		}

		f.last_elem.push(index == elements.len - 1)
		f.format_value(elem)
		f.last_elem.remove_last()

		if index != elements.len - 1 {
			f.sb.write_u8(b`,`)
			if !multiline {
				f.print_whitespace(b` `)
			}
		}

		if multiline {
			if index != elements.len - 1 || elem !is syntax.JsonArray {
				f.print_whitespace(b`\n`)
			}
		}
	}

	f.parents.remove_last()
	f.indent--

	if multiline {
		f.print_indents()
	}
	f.sb.write_u8(b`]`)

	value_of_object := f.parents.last_or_none() or { .array } == .object
	last_elem := f.last_elem.last_or_none() or { false }
	if value_of_object || last_elem {
		f.print_whitespace(b`\n`)
	}
}

fn (f &mut Formatter) format_string(str string) {
	f.sb.write_u8(b`"`)
	f.sb.write_str(str)
	f.sb.write_u8(b`"`)
}
