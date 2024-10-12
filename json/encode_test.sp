module main

import json

struct EncodePerson {
	name string
	age  i32
}

test "encode simple JSON as struct" {
	data := EncodePerson{ name: "Alice", age: 30 }
	res := json.encode(data)
	t.assert_eq(res, '{"name":"Alice","age":30}', "should be equal")
}

test "encode JSON as reference struct" {
	data := &EncodePerson{ name: "Alice", age: 30 }
	res := json.encode(data)
	t.assert_eq(res, '{"name":"Alice","age":30}', "should be equal")
}

test "encode JSON as mutable reference struct" {
	data := &mut EncodePerson{ name: "Alice", age: 30 }
	res := json.encode(data)
	t.assert_eq(res, '{"name":"Alice","age":30}', "should be equal")
}

test "encode simple JSON as array of structs" {
	arr := [
		EncodePerson{ name: "Alice", age: 30 },
		EncodePerson{ name: "Bob", age: 40 },
	]

	res := json.encode(arr)
	t.assert_eq(res, '[{"name":"Alice","age":30},{"name":"Bob","age":40}]', "should be equal")
}

struct EncodeWithOtherStruct {
	person EncodePerson
}

test "encode JSON with other struct field" {
	data := EncodeWithOtherStruct{ person: EncodePerson{ name: "Alice", age: 30 } }
	res := json.encode(data)
	t.assert_eq(res, '{"person":{"name":"Alice","age":30}}', "should be equal")
}

struct EncodeWithArrayOfOtherStruct {
	persons []EncodePerson
}

test "encode JSON with array of other struct field" {
	data := EncodeWithArrayOfOtherStruct{
		persons: [
			EncodePerson{ name: "Alice", age: 30 },
			EncodePerson{ name: "Bob", age: 40 },
		]
	}

	res := json.encode(data)
	t.assert_eq(res, '{"persons":[{"name":"Alice","age":30},{"name":"Bob","age":40}]}', "should be equal")
}

struct EncodeWithMapOfOtherStruct {
	persons map[string]EncodePerson
}

test "encode JSON with map of other struct field" {
	data := EncodeWithMapOfOtherStruct{
		persons: {
			"Alice": EncodePerson{ name: "Alice", age: 30 }
			"Bob":   EncodePerson{ name: "Bob", age: 40 }
		}
	}

	res := json.encode(data)
	// Current implementation of map is not sorted, so here first element is not guaranteed to be Alice
	t.assert_eq(res, '{"persons":{"Bob":{"name":"Bob","age":40},"Alice":{"name":"Alice","age":30}}}', "should be equal")
}

struct EncodeWithMapOfOtherStructReferences {
	persons map[string]&EncodePerson
}

test "encode JSON with map of other struct field references" {
	data := EncodeWithMapOfOtherStructReferences{
		persons: {
			"Alice": &EncodePerson{ name: "Alice", age: 30 }
			"Bob":   &EncodePerson{ name: "Bob", age: 40 }
		}
	}

	res := json.encode(data)
	// Current implementation of map is not preserve order, so here first element is not guaranteed to be Alice
	t.assert_eq(res, '{"persons":{"Bob":{"name":"Bob","age":40},"Alice":{"name":"Alice","age":30}}}', "should be equal")
}

struct EncodeWithMapOfOtherStructStringToI32 {
	persons map[string]map[string]i32
}

test "encode JSON with deep map string -> i32" {
	data := EncodeWithMapOfOtherStructStringToI32{
		persons: {
			"Alice": {
				"age": 30
			}
			"Bob": {
				"age": 40
			}
		}
	}

	res := json.encode(data)
	t.assert_eq(res, '{"persons":{"Bob":{"age":40},"Alice":{"age":30}}}', "should be equal")
}

struct EncodeWithOtherStructReference {
	person &EncodePerson
}

test "encode JSON with other struct reference field" {
	data := EncodeWithOtherStructReference{ person: &EncodePerson{ name: "Alice", age: 30 } }
	res := json.encode(data)
	t.assert_eq(res, '{"person":{"name":"Alice","age":30}}', "should be equal")
}

struct EncodeWithArrayOfOtherStructReference {
	persons []&EncodePerson
}

test "encode JSON with array of other struct references field" {
	data := EncodeWithArrayOfOtherStructReference{
		persons: [
			&EncodePerson{ name: "Alice", age: 30 },
			&EncodePerson{ name: "Bob", age: 40 },
		]
	}

	res := json.encode(data)
	t.assert_eq(res, '{"persons":[{"name":"Alice","age":30},{"name":"Bob","age":40}]}', "should be equal")
}

struct EncodeWithPrimitiveOption {
	some ?i32
}

test "encode JSON with primitive Option field" {
	data := EncodeWithPrimitiveOption{ some: 30 }
	res := json.encode(data)
	t.assert_eq(res, '{"some":30}', "should be equal")

	data2 := EncodeWithPrimitiveOption{ some: none }
	res2 := json.encode(data2)
	t.assert_eq(res2, '{"some":null}', "should be equal")
}

struct EncodeWithOtherStructOption {
	person ?EncodePerson
}

test "encode JSON with struct Option field" {
	data := EncodeWithOtherStructOption{ person: EncodePerson{ name: "Alice", age: 30 } }
	res := json.encode(data)
	t.assert_eq(res, '{"person":{"name":"Alice","age":30}}', "should be equal")

	data2 := EncodeWithOtherStructOption{ person: none }
	res2 := json.encode(data2)
	t.assert_eq(res2, '{"person":null}', "should be equal")
}

struct EncodeWithOtherStructOptionAndOmitEmpty {
	#[omit_empty]
	person ?EncodePerson
}

test "encode JSON with struct Option field and omit_empty attribute" {
	data := EncodeWithOtherStructOptionAndOmitEmpty{ person: none }
	res := json.encode(data)
	t.assert_eq(res, '{}', "should be equal")
}

type EncodeDocumentUri = string

struct EncodeWithStringAlias {
	uri EncodeDocumentUri
}

test "encode JSON with alias for string" {
	data := EncodeWithStringAlias{ uri: "https://example.com" }
	res := json.encode(data)
	t.assert_eq(res, '{"uri":"https://example.com"}', "should be equal")
}

enum EncodeColor {
	red
	green
	blue
}

struct EncodeWithEnum {
	color EncodeColor
}

test "encode JSON with enum" {
	data := EncodeWithEnum{ color: EncodeColor.green }
	res := json.encode(data)
	t.assert_eq(res, '{"color":1}', "should be equal")

	data2 := EncodeWithEnum{ color: EncodeColor.red }
	res2 := json.encode(data2)
	t.assert_eq(res2, '{"color":0}', "should be equal")
}

struct GenericStruct[T] {
	value T
}

test "encode JSON with generic struct" {
	t.assert_eq(json.encode(GenericStruct{ value: "" }), '{"value":""}', "should be equal")
	t.assert_eq(json.encode(GenericStruct{ value: "Alice" }), '{"value":"Alice"}', "should be equal")
	t.assert_eq(json.encode(GenericStruct{ value: 30 }), '{"value":30}', "should be equal")
	t.assert_eq(json.encode(GenericStruct{ value: 10.0 }), '{"value":10}', "should be equal")
	t.assert_eq(json.encode(GenericStruct{ value: true }), '{"value":true}', "should be equal")

	t.assert_eq(json.encode(GenericStruct{ value: EncodePerson{ name: "Alice", age: 30 } }), '{"value":{"name":"Alice","age":30}}', "should be equal")
	t.assert_eq(json.encode(GenericStruct{ value: &EncodePerson{ name: "Alice", age: 30 } }), '{"value":{"name":"Alice","age":30}}', "should be equal")
	t.assert_eq(json.encode(GenericStruct{ value: none as ?EncodePerson }), '{"value":null}', "should be equal")

	t.assert_eq(json.encode(GenericStruct{ value: EncodeColor.green }), '{"value":1}', "should be equal")
}

test "encode JSON with nested generic struct" {
	val := GenericStruct{ value: GenericStruct{ value: "Alice" } }
	t.assert_eq(json.encode(val), '{"value":{"value":"Alice"}}', "should be equal")
}

test "encode JSON with generic struct with array type" {
	t.assert_eq(json.encode(GenericStruct{ value: ["Alice", "Bob"] }), '{"value":["Alice","Bob"]}', "should be equal")
	t.assert_eq(json.encode(GenericStruct{ value: [1, 2, 3] }), '{"value":[1,2,3]}', "should be equal")

	val := GenericStruct{ value: [GenericStruct{ value: "Alice" }, GenericStruct{ value: "Bob" }] }
	t.assert_eq(json.encode(val), '{"value":[{"value":"Alice"},{"value":"Bob"}]}', "should be equal")
}

test "encode JSON with generic struct with deep array type" {
	t.assert_eq(json.encode(GenericStruct{ value: [["Alice", "Bob"]] }), '{"value":[["Alice","Bob"]]}', "should be equal")
	t.assert_eq(json.encode(GenericStruct{ value: [[1, 2, 3], [4, 5, 6]] }), '{"value":[[1,2,3],[4,5,6]]}', "should be equal")

	val := GenericStruct{ value: [[GenericStruct{ value: "Alice" }], [GenericStruct{ value: "Bob" }]] }
	t.assert_eq(json.encode(val), '{"value":[[{"value":"Alice"}],[{"value":"Bob"}]]}', "should be equal")
}

test "encode JSON with very nested generic struct" {
	val := GenericStruct{ value: GenericStruct{ value: GenericStruct{ value: "Alice" } } }
	t.assert_eq(json.encode(val), '{"value":{"value":{"value":"Alice"}}}', "should be equal")
}

struct GenericStructWithOptionField[T] {
	value ?T
}

test "encode JSON with generic struct with Option field" {
	t.assert_eq(json.encode(GenericStructWithOptionField[string]{ value: "" }), '{"value":""}', "should be equal")
	t.assert_eq(json.encode(GenericStructWithOptionField[string]{ value: "Alice" }), '{"value":"Alice"}', "should be equal")
	t.assert_eq(json.encode(GenericStructWithOptionField[i32]{ value: 30 }), '{"value":30}', "should be equal")
	t.assert_eq(json.encode(GenericStructWithOptionField[f64]{ value: 10.0 }), '{"value":10}', "should be equal")
	t.assert_eq(json.encode(GenericStructWithOptionField[bool]{ value: true }), '{"value":true}', "should be equal")

	t.assert_eq(json.encode(GenericStructWithOptionField[EncodePerson]{ value: EncodePerson{ name: "Alice", age: 30 } }), '{"value":{"name":"Alice","age":30}}', "should be equal")
	t.assert_eq(json.encode(GenericStructWithOptionField[&EncodePerson]{ value: &EncodePerson{ name: "Alice", age: 30 } }), '{"value":{"name":"Alice","age":30}}', "should be equal")

	// TODO: support this cases too
	// t.assert_eq(json.encode(GenericStructWithOptionField[EncodePerson]{ value: none }), '{"value":null}', "should be equal")
	// t.assert_eq(json.encode(GenericStructWithOptionField{ value: none as ?EncodePerson }), '{"value":null}', "should be equal")

	t.assert_eq(json.encode(GenericStructWithOptionField[EncodeColor]{ value: EncodeColor.green }), '{"value":1}', "should be equal")
}

struct ToEmbed {
	name string
}

struct WithEmbed {
	ToEmbed
	age i32
}

// TODO: this should be inlined
test "encode JSON with embedded struct" {
	data := WithEmbed{ ToEmbed: ToEmbed{ name: "Alice" }, age: 30 }
	res := json.encode(data)
	t.assert_eq(res, '{"ToEmbed":{"name":"Alice"},"age":30}', "should be equal")
}
