module urllib

import strings

struct QueryValue {
	key   string
	value string
}

// Values represents a map of query values by key.
//
// We actually use array to represent the map, since the number of keys is
// usually small, linear search is faster than all hash map overhead.
pub struct Values {
	data []QueryValue
	len  usize        // number of unique keys
}

pub fn Values.new() -> Values {
	return Values{}
}

pub fn (v &mut Values) set(key string, value string) {
	for mut el in v.data {
		if el.key == key {
			el.value = value
			return
		}
	}

	v.add(key, value)
}

pub fn (v &mut Values) add(key string, value string) {
	v.data.push(QueryValue{ key: key, value: value })
	v.len++
}

pub fn (v &Values) get(key string) -> ?string {
	for el in v.data {
		if el.key == key {
			return el.value
		}
	}
	return none
}

pub fn (v &Values) get_all(key string) -> []string {
	mut values := []string{cap: 2}
	for el in v.data {
		if el.key == key {
			values.push(el.value)
		}
	}
	return values
}

pub fn (v &mut Values) del(key string) {
	v.data = v.data.filter(|el| el.key != key)
}

pub fn (v &Values) contains(key string) -> bool {
	for el in v.data {
		if el.key == key {
			return true
		}
	}
	return false
}

pub fn (v &Values) encode() -> string {
	mut sb := strings.new_builder(100)
	for i, el in v.data {
		if i > 0 {
			sb.write_u8(b`&`)
		}
		sb.write_str(query_escape(el.key))
		sb.write_str('=')
		sb.write_str(query_escape(el.value))
	}
	return sb.str_view()
}

pub fn parse_query(query string) -> !Values {
	mut values := Values.new()
	for part in query.split_iter('&') {
		if part.len == 0 {
			continue
		}
		if part.contains(';') {
			return msg_err("invalid semicolon separator in query")
		}
		key, value := part.split_by_last('=')
		if key.len == 0 {
			continue
		}
		values.add(query_unescape(key)!, query_unescape(value)!)
	}
	return values
}
