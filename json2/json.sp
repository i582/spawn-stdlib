module json2

import json2.syntax

// raw_decode parses the given JSON document and converts it to a
// `map[string]Value` where [`Value`] represents any JSON value.
//
// If the document contains errors and cannot be parsed,
// [`raw_decode`] will return the first [`syntax.ParserError`].
//
// The resulting map can be used like a regular map, to get the field
// value just use `[]` operator:
// ```
// data := json2.raw_decode('{ "name": "John" }').unwrap()
// assert data['name'] as string == 'John'
// ```
//
// Before using a field value, it should be cast to the correct type
// as shown above.
//
// You can use `if` or `match` to check that the field is of the correct type:
// ```
// data := json2.raw_decode('{ "name": "John" }').unwrap()
// name_field := data['name']
// if name_field {
//     assert name_field == 'John'
// }
//
// match name_field {
//     string -> println('Hey ${name_field}')
//     map[string]json2.Value -> {
//         real_name := name_field['data'] as? string or { 'Mr. Unknown' }
//         println('Hey ${real_name}')
//     }
//     else -> println('oops')
// }
// ```
pub fn raw_decode(data string) -> ![map[string]Value, syntax.ParseError] {
	mut p := syntax.Parser.new(data)
	file := p.parse_file()!
	return process_object(file.obj)
}

// decode parses the passed JSON document and converts it to the
// passed type [`T`].
//
// If you don't know the exact structure of the file, use [`raw_decode`]
// to get a map that stores the entire document.
//
// If the document contains errors and cannot be parsed,
// [`raw_decode`] will return the first [`syntax.ParserError`].
//
// Example:
// ```
// struct Person {
//     name string
//     age  i32
// }
//
// fn main() {
//     person := json2.decode[Person]('{ "name": "John", "age": 45 }').unwrap()
//     assert person == Person{ name: "John", age: 45 }
// }
// ```
//
// This function is mostly used with struct types that replicate the structure of
// the document being parsed. Each field named X will be initialized with the
// corresponding X field from the JSON document.
//
// ## Rename all fields to camelCase
//
// In some cases, the data uses camelCase for field names, in which case, by default,
// such documents will not be correctly mapped into the structure.
//
// To make everything work as expected, the `rename_all` attribute is used with the
// value `"camelCase"`. Any other values have no effect:
// ```
// #[rename_all("camelCase")]
// struct Person {
//     name        string
//     custom_data string
// }
//
// fn main() {
//     person := json2.decode[Person]('{ "name": "John", "customData": "some data" }').unwrap()
//     assert person == Person{ name: "John", custom_data: "some data" }
// }
// ```
//
// ## Rename single field
//
// Sometimes it is necessary to rename a field, as it may have a name that does not
// fit the name of a field in the structure. To rename a field, use the `json` attribute
// with the field name that will be used for mapping:
// ```
// #[rename_all("camelCase")]
// struct Person {
//     #[json("_ID")]
//     id   i32
//     name string
// }
//
// fn main() {
//     person := json2.decode[Person]('{ "_ID": 1, "name": "John" }').unwrap()
//     assert person == Person{ id: 1, name: "John" }
// }
// ```
//
// ## Skip parsing of some field
//
// If you need some part of the JSON not to be parsed, for example its structure is unknown,
// you can mark the string type field with the `raw` attribute. In this case, the entire JSON
// value will be saved as a single string.
pub fn decode[T](data string) -> ![T, syntax.ParseError] {
	mut p := syntax.Parser.new(data)
	file := p.parse_file()!
	return decode_value[T](file.obj)
}
