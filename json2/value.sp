module json2

import json2.syntax

// Null represents a JSON null value.
pub struct Null {}

// Value represents a JSON value in terms of Spawn types.
pub union Value = string |
                  f64 |
                  bool |
                  Null |
                  []Value |
                  map[string]Value

// str returns a string representation of [`Value`].
//
// The return value may look like JSON, but it is not, it
// is just a representation of the data.
pub fn (a Value) str() -> string {
	return match a {
		string => "'${a}'"
		f64 => {
			if a == a as i64 as f64 {
				return (a as i64).str()
			}
			a.str()
		}
		bool => a.str()
		Null => "null"
		[]Value => a.str()
		map[string]Value => a.str()
	}
}

// equal compares two [`Value`] for equality.
pub fn (a Value) equal(o Value) -> bool {
	if a is string && o is string {
		return a == o
	}
	if a is f64 && o is f64 {
		return a == o
	}
	if a is bool && o is bool {
		return a == o
	}
	if a is Null && o is Null {
		return true
	}
	if a is []Value && o is []Value {
		return a == o
	}
	if a is map[string]Value && o is map[string]Value {
		return a == o
	}
	return false
}

fn process_object(h syntax.Object) -> map[string]Value {
	mut res := map[string]Value{}

	mut cur := h.head
	for cur != none {
		key := cur.key
		value := process_value(cur.value)
		res[key] = value
		cur = cur.next
	}

	return res
}

fn process_array(h syntax.JsonArray) -> []Value {
	mut res := []Value{}
	mut cur := h.head

	for cur != none {
		res.push(process_value(cur.val))
		cur = cur.next
	}

	return res
}

fn process_value(h syntax.Value) -> Value {
	match h {
		string => return h
		bool => return h
		syntax.Number => return h.value.f64()
		syntax.Null => return Null{}
		syntax.JsonArray => return process_array(h)
		syntax.Object => return process_object(h)
	}

	panic('unexpected value')
}
