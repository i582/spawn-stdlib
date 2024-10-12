module builtin

pub fn type_info[T]() -> Typ {
	return Typ{}
}

pub struct Typ {}

pub fn (t Typ) elem() -> Typ {
	return Typ{}
}

pub fn (t Typ) key() -> Typ {
	return Typ{}
}

pub fn (t Typ) value() -> Typ {
	return Typ{}
}

pub fn (t Typ) attr(name string) -> ?AttributeInfo {
	return none
}

pub fn (t Typ) is_array() -> bool {
	return false
}

pub fn (t Typ) is_map() -> bool {
	return false
}

pub fn (t Typ) is_option() -> bool {
	return false
}

pub fn (t Typ) is_enum() -> bool {
	return false
}

pub fn (t Typ) is_struct() -> bool {
	return false
}

pub fn (t Typ) is_union() -> bool {
	return false
}

pub fn (t Typ) is_ref() -> bool {
	return false
}

pub fn (t Typ) union_types() -> []Typ {
	return []
}

pub fn (t Typ) from_string[T](name string) -> ?T {
	return none
}

pub struct ReflectionStruct {
	fields []FieldInfo
}

pub struct AttributeInfo {
	name string
	args []string
}

pub fn (i AttributeInfo) value(index i32) -> string {
	return ''
}

pub struct FieldInfo {
	attrs []AttributeInfo
	name  string
	typ   Typ
}

pub fn (i FieldInfo) has_attr(name string) -> bool {
	for a in i.attrs {
		if a.name == name {
			return true
		}
	}
	return false
}

pub fn (i FieldInfo) attr(name string) -> ?AttributeInfo {
	for a in i.attrs {
		if a.name == name {
			return a
		}
	}
	return none
}

pub struct VariantInfo {
	attrs []AttributeInfo
	name  string
}

pub struct TupleElementInfo {
	index usize
	name  string
	typ   Typ
}
