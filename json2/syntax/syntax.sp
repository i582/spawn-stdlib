module syntax

// File represents a whole JSON document.
//
// Example:
// ```json
// {
//   "name": "John"
//   "data": {
//     "value": 100
//   }
// }
// ```
pub struct File {
	obj Object
}

// Object represents single JSON object.
//
// Example:
// ```json
// "data": {
//   "value": 100
// }
// ```
pub struct Object {
	head ?&mut KeyValue
}

// field returns the [`Value`] of the field with [`name`], or none
//  if the field is not found.
//
// Example:
// ```
// p := syntax.Parser.new('{ "name": "John" }')
// file := p.parse_file().unwrap()
// name_field := file.obj.field('name').unwrap()
// assert name_field as string == 'John'
// ```
pub fn (o &Object) field(name string) -> ?Value {
	mut cur := o.head

	for cur != none {
		if cur.key == name {
			return cur.value
		}
		cur = cur.next
	}

	return none
}

// string_field returns the string value of the field with [`name`], or none
// if the field is not found or the field is of a different type.
//
// Example:
// ```
// p := syntax.Parser.new('{ "name": "John" }')
// file := p.parse_file().unwrap()
// assert file.obj.string_field('name').unwrap() == 'John'
// ```
pub fn (o &Object) string_field(name string) -> ?string {
	field := o.field(name)?
	return field as? string
}

// i32_field returns the i32 value of the field with [`name`], or none
// if the field is not found or the field is of a different type.
//
// Example:
// ```
// p := syntax.Parser.new('{ "age": "56" }')
// file := p.parse_file().unwrap()
// assert file.obj.i32_field('age').unwrap() == 56
// ```
pub fn (o &Object) i32_field(name string) -> ?i32 {
	field := o.field(name)?
	return (field as? Number)?.value?.i32()
}

// u64_field returns the u64 value of the field with [`name`], or none
// if the field is not found or the field is of a different type.
//
// Example:
// ```
// p := syntax.Parser.new('{ "age": "56" }')
// file := p.parse_file().unwrap()
// assert file.obj.u64_field('age').unwrap() == 56
// ```
pub fn (o &Object) u64_field(name string) -> ?u64 {
	field := o.field(name)?
	return (field as? Number)?.value?.i64() or { 0 } as u64
}

// bool_field returns the boolean value of the field with [`name`], or none
// if the field is not found or the field is of a different type.
//
// Example:
// ```
// p := syntax.Parser.new('{ "has": true }')
// file := p.parse_file().unwrap()
// assert file.obj.bool_field('has').unwrap() == 56
// ```
pub fn (o &Object) bool_field(name string) -> ?bool {
	field := o.field(name)?
	return (field as? bool)?
}

// KeyValue represents a single key value of [`Object`].
//
// Example:
// ```json
// "value": 100
// ```
pub struct KeyValue {
	key   string
	value Value = Null{}
	next  ?&mut KeyValue
}

// JsonArray represents an JSON array.
//
// Note that the array values are stored as a linked list.
//
// Example:
// ```json
// [1, 2, 3]
// [{ "name": "John" }, { "name": "Mark" }]
// ```
pub struct JsonArray {
	head ?&mut JsonArrayElement
}

// JsonArrayElement represents a single element of [`JsonArray`].
pub struct JsonArrayElement {
	val  Value = Null{}
	next ?&mut JsonArrayElement
}

// Value represents an JSON value.
pub union Value = string |
                  bool |
                  Number |
                  JsonArray |
                  Object |
                  Null

// Number represents an JSON number.
//
// Example:
// ```json
// 100
// 9999.56
// 100000.99999999999
// ```
pub struct Number {
	value string
}

// Null represents an JSON null.
//
// Example:
// ```json
// null
// ```
pub struct Null {}

// Comment represents an comment in JSON document.
// Not yet used.
pub struct Comment {
	inline bool
	value  string
}
