module toml

import strconv

pub struct DocTable {
	table Table
}

pub fn (t DocTable) get(key string) -> ?DocValue {
	return DocValue{ value: t.table.get(key)? }
}

pub fn (t DocTable) as_map() -> map[string]DocValue {
	mut m := map[string]DocValue{}
	for key, value in t.table.as_map() {
		m[key] = DocValue{ value: value }
	}
	return m
}

pub struct DocInlineTable {
	table InlineTable
}

pub fn (t DocInlineTable) get(key string) -> ?DocValue {
	return DocValue{ value: t.table.get(key)? }
}

pub fn (t DocInlineTable) as_map() -> map[string]DocValue {
	mut m := map[string]DocValue{}
	for key, value in t.table.as_map() {
		m[key] = DocValue{ value: value }
	}
	return m
}

pub struct DocValue {
	value Value
}

pub fn (v DocValue) as_string() -> ?string {
	if v.value is String {
		return v.value.content()
	}
	return none
}

pub fn (v DocValue) as_int() -> ?i64 {
	if v.value is Integer {
		return v.value.value.i64()
	}
	return none
}

pub fn (v DocValue) as_float() -> ?f64 {
	if v.value is Float {
		return strconv.parse_float(v.value.value)
	}
	return none
}

pub fn (v DocValue) as_table() -> ?DocInlineTable {
	if v.value is InlineTable {
		return DocInlineTable{ table: v.value }
	}
	return none
}

pub struct Doc {
	file File
}

pub fn (d Doc) table(name string) -> ?DocTable {
	return DocTable{ table: d.file.table(name)? }
}

pub fn (d Doc) tables(name string) -> []Table {
	return d.file.tables(name)
}

pub fn (d Doc) table_ref(name string) -> ?&mut Table {
	return d.file.table_ref(name)?
}

pub fn (d Doc) table_array(name string) -> []DocTable {
	tables := d.file.table_array(name)
	return tables.map(|t| DocTable{ table: t })
}

pub fn parse(input string) -> Doc {
	s := Scanner.new(input, fn (err ParseError) {})
	p := Parser.new(s, fn (err ParseError) {})
	return Doc{ file: p.parse() }
}
