module toml

import toml.token
import strings

pub struct File {
	tables []Table
}

pub fn File.new() -> File {
	return File{}
}

pub fn (f &mut File) add_table(table Table) {
	f.tables.push(table)
}

pub fn (f File) encode() -> string {
	mut p := PrettyPrinter.new()
	return p.print(f)
}

fn (f File) table(name string) -> ?Table {
	for table in f.tables {
		if !table.is_array && table.key.matches(name) {
			return table
		}
	}
	return none
}

fn (f File) tables(name string) -> []Table {
	mut tables := []Table{}
	for table in f.tables {
		if !table.is_array && table.key.matches(name) {
			tables.push(table)
		}
	}
	return tables
}

fn (f File) table_ref(name string) -> ?&mut Table {
	for i in 0 .. f.tables.len {
		table := f.tables.get_mut_ptr(i)
		if !table.is_array && table.key.matches(name) {
			return table
		}
	}
	return none
}

fn (f File) table_array(name string) -> []Table {
	mut tables := []Table{}
	for table in f.tables {
		if table.is_array && table.key.matches(name) {
			tables.push(table)
		}
	}
	return tables
}

pub struct Table {
	ff       []FreeFloating
	ff_after []FreeFloating

	is_array bool

	key     Key
	entries []KeyValue
}

pub fn Table.new(key Key) -> Table {
	return Table{ key: key }
}

pub fn (t &mut Table) add_entry(entry KeyValue) {
	t.entries.push(entry)
}

pub fn (t Table) as_map() -> map[string]Value {
	mut mp := map[string]Value{}
	for entry in t.entries {
		mp[entry.key.str()] = entry.value
	}
	return mp
}

pub fn (t Table) get(name string) -> ?Value {
	for entry in t.entries {
		if entry.key.matches(name) {
			return entry.value
		}
	}
	return none
}

pub struct InlineTable {
	ff       []FreeFloating
	ff_after []FreeFloating

	entries []KeyValue
}

pub fn InlineTable.new() -> InlineTable {
	return InlineTable{}
}

pub fn (t &mut InlineTable) add_entry(entry KeyValue) {
	t.entries.push(entry)
}

pub fn (t InlineTable) as_map() -> map[string]Value {
	mut mp := map[string]Value{}
	for entry in t.entries {
		mp[entry.key.str()] = entry.value
	}
	return mp
}

pub fn (t InlineTable) get(name string) -> ?Value {
	for entry in t.entries {
		if entry.key.matches(name) {
			return entry.value
		}
	}
	return none
}

pub struct Ident {
	ff       []FreeFloating
	ff_after []FreeFloating

	pos   token.Pos
	value string
}

pub fn Ident.new(value string) -> Ident {
	return Ident{ value: value }
}

pub struct EmptyKey {}

pub union Key = Ident | String | DottedKey | EmptyKey

pub fn Key.new(value string) -> Key {
	if value.contains('.') {
		parts := value.split('.')
		mut keys := []Key{}
		for part in parts {
			keys.push(Ident.new(part))
		}
		return DottedKey{ keys: keys }
	}
	return Ident.new(value)
}

pub fn (k Key) matches(val string) -> bool {
	if val == '*' {
		return true
	}

	if k is EmptyKey {
		return val == ''
	}

	if k is Ident {
		return k.value == val
	}

	if k is String {
		return k.content() == val
	}

	val_parts := val.split('.')
	if val_parts.len != k.keys.len {
		return false
	}

	keys := k.keys
	for i, key in keys {
		val_part := val_parts[i]
		if !key.matches(val_part) {
			return false
		}
	}

	return true
}

pub fn (k Key) str() -> string {
	return match k {
		EmptyKey => ''
		Ident => k.value
		String => k.content()
		DottedKey => {
			mut sb := strings.new_builder(10)
			for i, key in k.keys {
				if i > 0 {
					sb.write_str(".")
				}
				sb.write_str(key.str())
			}
			return sb.str_view()
		}
	}
}

pub struct DottedKey {
	ff       []FreeFloating
	ff_after []FreeFloating

	keys []Key
}

pub struct KeyValue {
	ff       []FreeFloating
	ff_after []FreeFloating

	key   Key
	value Value
}

pub fn KeyValue.new(key Key, value Value) -> KeyValue {
	return KeyValue{ key: key, value: value }
}

pub union Value = String |
                  Integer |
                  Float |
                  Boolean |
                  TomlArray |
                  InlineTable

pub struct String {
	ff       []FreeFloating
	ff_after []FreeFloating

	pos   token.Pos
	tok   token.Token
	value string
}

pub fn String.new(value string) -> String {
	return String{ value: '"${value}"' }
}

pub fn (s String) content() -> string {
	if s.value.starts_with('"""') {
		return s.value[3..s.value.len - 3]
	}
	if s.value.starts_with("'''") {
		return s.value[3..s.value.len - 3]
	}
	return s.value[1..s.value.len - 1]
}

pub struct Integer {
	ff       []FreeFloating
	ff_after []FreeFloating

	pos   token.Pos
	value string
}

pub fn Integer.new(value i64) -> Integer {
	return Integer{ value: value.str() }
}

pub struct Float {
	ff       []FreeFloating
	ff_after []FreeFloating

	pos   token.Pos
	value string
}

pub fn Float.new(value f64) -> Float {
	return Float{ value: value.str() }
}

pub struct Boolean {
	ff       []FreeFloating
	ff_after []FreeFloating

	pos   token.Pos
	value bool
}

pub fn Boolean.new(value bool) -> Boolean {
	return Boolean{ value: value }
}

pub struct TomlArray {
	ff       []FreeFloating
	ff_after []FreeFloating

	values []Value
}

pub fn TomlArray.new() -> TomlArray {
	return TomlArray{}
}

pub fn (a &mut TomlArray) add(value Value) {
	a.values.push(value)
}

pub union FreeFloating = Whitespace | Comment

pub fn (ff FreeFloating) str() -> string {
	return ""
}

pub struct Whitespace {
	pos   token.Pos
	value string
}

pub struct Comment {
	inline bool
	pos    token.Pos
	value  string
}
