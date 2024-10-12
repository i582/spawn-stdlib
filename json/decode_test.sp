module main

import json

struct Person {
	name string
	age  i32
}

test "decode simple JSON as struct" {
	res := json.decode[Person]('{"name":"Alice","age":30}').unwrap()
	t.assert_eq(res.name, "Alice", "name should be Alice")
	t.assert_eq(res.age, 30, "age should be 30")
}

#[skip]
test "decode simple JSON as reference struct" {
	res := json.decode[&Person]('{"name":"Alice","age":30}').unwrap()
	t.assert_eq(res.name, "Alice", "name should be Alice")
	t.assert_eq(res.age, 30, "age should be 30")
}

test "decode simple JSON as array of structs" {
	res := json.decode[[]Person]('[
        {"name":"Alice","age":30},
        {"name":"Bob","age":40}
    ]').unwrap()

	t.assert_eq(res.len, 2, "array should have 2 elements")
	t.assert_eq(res[0].name, "Alice", "name should be Alice")
	t.assert_eq(res[0].age, 30, "age should be 30")
	t.assert_eq(res[1].name, "Bob", "name should be Bob")
	t.assert_eq(res[1].age, 40, "age should be 40")
}

struct WithOtherStruct {
	person Person
}

test "decode JSON with other struct field" {
	res := json.decode[WithOtherStruct]('
        {"person": {"name": "Alice", "age": 30}}
    ').unwrap()

	t.assert_eq(res.person.name, "Alice", "name should be Alice")
	t.assert_eq(res.person.age, 30, "age should be 30")
}

struct WithArrayOfOtherStruct {
	persons []Person
}

test "decode JSON with array of other struct field" {
	res := json.decode[WithArrayOfOtherStruct]('
        {"persons": [
            {"name": "Alice", "age": 30},
            {"name": "Bob", "age": 40}
        ]}
    ').unwrap()

	t.assert_eq(res.persons.len, 2, "array should have 2 elements")
	t.assert_eq(res.persons[0].name, "Alice", "name should be Alice")
	t.assert_eq(res.persons[0].age, 30, "age should be 30")
	t.assert_eq(res.persons[1].name, "Bob", "name should be Bob")
	t.assert_eq(res.persons[1].age, 40, "age should be 40")
}

struct WithMapOfOtherStruct {
	persons map[string]Person
}

test "decode JSON with map of other struct field" {
	res := json.decode[WithMapOfOtherStruct]('{
        "persons": {
            "Alice": {"name": "Alice", "age": 30},
            "Bob": {"name": "Bob", "age": 40}
        }
    }').unwrap()

	t.assert_eq(res.persons.len, 2, "map should have 2 elements")
	t.assert_eq(res.persons["Alice"].name, "Alice", "name should be Alice")
	t.assert_eq(res.persons["Alice"].age, 30, "age should be 30")
	t.assert_eq(res.persons["Bob"].name, "Bob", "name should be Bob")
	t.assert_eq(res.persons["Bob"].age, 40, "age should be 40")
}

struct WithMapOfOtherStructReferences {
	persons map[string]&Person
}

#[skip]
test "decode JSON with map of other struct field references" {
	res := json.decode[WithMapOfOtherStructReferences]('{
        "persons": {
            "Alice": {"name": "Alice", "age": 30},
            "Bob": {"name": "Bob", "age": 40}
        }
    }').unwrap()

	t.assert_eq(res.persons.len, 2, "map should have 2 elements")
	t.assert_eq(res.persons["Alice"].name, "Alice", "name should be Alice")
	t.assert_eq(res.persons["Alice"].age, 30, "age should be 30")
	t.assert_eq(res.persons["Bob"].name, "Bob", "name should be Bob")
	t.assert_eq(res.persons["Bob"].age, 40, "age should be 40")
}

struct WithOtherStructReference {
	person &Person
}

test "decode JSON with other struct reference field" {
	res := json.decode[WithOtherStructReference]('
        {"person": {"name": "Alice", "age": 30}}
    ').unwrap()

	t.assert_eq(res.person.name, "Alice", "name should be Alice")
	t.assert_eq(res.person.age, 30, "age should be 30")
}

struct WithArrayOfOtherStructReference {
	persons []&Person
}

#[skip]
test "decode JSON with array of other struct references field" {
	res := json.decode[WithArrayOfOtherStructReference]('{
        "persons": [
            {"name": "Alice", "age": 30},
            {"name": "Bob", "age": 40}
        ]
    }').unwrap()

	t.assert_eq(res.persons.len, 2, "array should have 2 elements")
	t.assert_eq(res.persons[0].name, "Alice", "name should be Alice")
	t.assert_eq(res.persons[0].age, 30, "age should be 30")
	t.assert_eq(res.persons[1].name, "Bob", "name should be Bob")
	t.assert_eq(res.persons[1].age, 40, "age should be 40")
}

struct WithPrimitiveOption {
	some ?i32
}

test "decode JSON with primitive Option field" {
	res := json.decode[WithPrimitiveOption]('{"some": 42}').unwrap()
	t.assert_eq(res.some.unwrap(), 42, "some should be 42")

	res2 := json.decode[WithPrimitiveOption]('{}').unwrap()
	t.assert_none(res2.some, "some should be None")

	res3 := json.decode[WithPrimitiveOption]('{"some": null}').unwrap()
	t.assert_none(res3.some, "some should be None")
}

struct WithOtherStructOption {
	person ?Person
}

test "decode JSON with struct Option field" {
	res := json.decode[WithOtherStructOption]('
        {"person": {"name": "Alice", "age": 30}}
    ').unwrap()

	t.assert_eq(res.person.unwrap().name, "Alice", "name should be Alice")
	t.assert_eq(res.person.unwrap().age, 30, "age should be 30")

	res2 := json.decode[WithOtherStructOption]('{}').unwrap()
	t.assert_none(res2.person, "person should be None")

	res3 := json.decode[WithOtherStructOption]('{"person": null}').unwrap()
	t.assert_none(res3.person, "person should be None")
}

type DocumentUri = string

struct WithStringAlias {
	uri DocumentUri
}

test "decode JSON with alias for string" {
	res := json.decode[WithStringAlias]('{"uri": "file:///path/to/file"}').unwrap()
	t.assert_eq(res.uri, "file:///path/to/file", "uri should be file:///path/to/file")
}

enum Color {
	red
	green
	blue
}

struct WithEnum {
	color Color
}

test "decode JSON with enum" {
	res := json.decode[WithEnum]('{"color": 1}').unwrap()
	t.assert_eq(res.color, Color.green, "color should be green")
}

// TODO: should we throw error here?
test "decode JSON with enum with unknown value" {
	res := json.decode[WithEnum]('{"color": 999}').unwrap()
	t.assert_eq(res.color.str(), 'unknown enum variant', "color should be green")
}

struct StructWithBool {
	logical_value bool
}

test "decode JSON, struct with bool field, bool as text value" {
	res := json.decode[StructWithBool]('{"logical_value": true}').unwrap()
	t.assert_eq(res.logical_value, true, "logical_value must be true")
}

test "decode JSON, struct with bool field, bool as number value" {
	res := json.decode[StructWithBool]('{"logical_value": 1}').unwrap()
	t.assert_eq(res.logical_value, false, "logical_value must be false")
}

test "decode JSON, struct with bool field, bool field does not exists in data" {
	res := json.decode[StructWithBool]('{"no_logical_value": "true"}').unwrap()
	t.assert_eq(res.logical_value, false, "logical_value must be false")
}

struct StructWithUnsigned64Int {
	unsigned_value u64
}

test "decode JSON, struct with unsigned 64 int field" {
	res := json.decode[StructWithUnsigned64Int]('{"unsigned_value": 100}').unwrap()
	t.assert_eq(res.unsigned_value, 100, "unsigned_value must be 100")
}

test "decode JSON, struct with unsigned 64 int field, unsigned 64 int field does not exists in data" {
	res := json.decode[StructWithUnsigned64Int]('{"no_unsigned_value": 100}').unwrap()
	t.assert_eq(res.unsigned_value, 0, "unsigned_value must be 0")
}

test "decode JSON, struct with unsigned 64 int field, unsigned 64 int field is not a number" {
	res := json.decode[StructWithUnsigned64Int]('{"unsigned_value": "100"}').unwrap()
	t.assert_eq(res.unsigned_value, 0, "unsigned_value must be 0")
}

// TODO: on macOS and Linux we get different results, need to investigate
#[skip]
test "decode JSON, struct with unsigned 64 int field, unsigned 64 int field has negative int value" {
	res := json.decode[StructWithUnsigned64Int]('{"unsigned_value": -100}').unwrap()
	t.assert_eq(res.unsigned_value, -100, "unsigned_value must be 0")
}

struct DummyStruct {
	name string
}

struct StructWithReference {
	value &DummyStruct
}

test "decode JSON, struct with reference field" {
	res := json.decode[StructWithReference]('{"value": {"name": "John"}}').unwrap()
	t.assert_eq(res.value.name, "John", "name must be John")
}

// TODO: return default value for reference field
#[skip]
test "decode JSON, struct with reference field, reference field does not exists in data" {
	res := json.decode[StructWithReference]('{"noValue": {"name": "John"}}').unwrap()
	t.assert_eq(res.value.name, "", "name must be empty")
}

test "decode JSON, struct with reference field, reference field is not a struct" {
	res := json.decode[StructWithReference]('{"value": 1}').unwrap()
	t.assert_eq(res.value.name, "", "name must be empty")
}

test "decode JSON, struct with reference field, reference struct is incorrect" {
	res := json.decode[StructWithReference]('{"value": {"age": 1}}').unwrap()
	t.assert_eq(res.value.name, "", "name must be empty")
}

struct SimpleStruct {
	name string
}

struct StructWithStruct {
	value SimpleStruct
}

test "decode JSON, struct with struct field" {
	res := json.decode[StructWithStruct]('{"value": {"name": "John"}}').unwrap()
	t.assert_eq(res.value.name, "John", "name must be John")
}

test "decode JSON, struct with struct field, struct field does not exists in data" {
	res := json.decode[StructWithStruct]('{"noValue": {"name": "John"}}').unwrap()
	t.assert_eq(res.value.name, "", "name must be empty")
}

test "decode JSON, struct with struct field, struct field is not a struct" {
	res := json.decode[StructWithStruct]('{"value": 1}').unwrap()
	t.assert_eq(res.value.name, "", "name must be empty")
}

test "decode JSON, struct with struct field, inner struct is incorrect" {
	res := json.decode[StructWithStruct]('{"value": {"age": 1}}').unwrap()
	t.assert_eq(res.value.name, "", "name must be empty")
}

enum SomeEnum {
	One
	Two
	Three
}

struct StructWithEnum {
	value SomeEnum
}

test "decode JSON, struct with enum field" {
	res := json.decode[StructWithEnum]('{"value": 0}').unwrap()
	t.assert_eq(res.value, SomeEnum.One, "name must be One")
}

test "decode JSON, struct with enum field, enum field does not exists in data" {
	res := json.decode[StructWithEnum]('{"noValue": 1}').unwrap()
	t.assert_eq(res.value, SomeEnum.One, "name must be One")
}

test "decode JSON, struct with enum field, enum field is not an enum" {
	res := json.decode[StructWithEnum]('{"value": "Two"}').unwrap()
	t.assert_eq(res.value, SomeEnum.One, "name must be One")
}

struct StructWithOption {
	value ?string
}

test "decode JSON, struct with option field" {
	res := json.decode[StructWithOption]('{"value": "John"}').unwrap()
	t.assert_eq(res.value.unwrap(), "John", "name must be John")
}

test "decode JSON, struct with option field, option field does not exists in data" {
	res := json.decode[StructWithOption]('{"noValue": "John"}').unwrap()
	t.assert_none(res.value, "name must be none")
}

// TODO: current implementation fails this test, it places empty string instead of `none`, must be fixed.
#[skip]
test "decode JSON, struct with option field, option field is not a string" {
	res := json.decode[StructWithOption]('{"value": 1}').unwrap()
	t.assert_none(res.value, "name must be none")
}

struct StructWithMap {
	value map[string]i32
}

test "decode JSON, struct with map field" {
	res := json.decode[StructWithMap]('{"value": {"age": 1}}').unwrap()
	t.assert_eq(res.value["age"], 1, "age must be 1")
}

test "decode JSON, struct with map field, map field does not exists in data" {
	res := json.decode[StructWithMap]('{"noValue": {"age": 1}}').unwrap()
	t.assert_false(res.value.contains("age"), "age must not exist")
}

test "decode JSON, struct with map field, map field is not a map" {
	res := json.decode[StructWithMap]('{"value": 1}').unwrap()
	t.assert_eq(res.value.len, 0, "map must be empty")
}

struct StructWithArray {
	value []i32
}

test "decode JSON, struct with array field" {
	res := json.decode[StructWithArray]('{"value": [1, 2, 3]}').unwrap()
	t.assert_eq(res.value[0], 1, "first element must be 1")
	t.assert_eq(res.value[1], 2, "second element must be 2")
	t.assert_eq(res.value[2], 3, "third element must be 3")
}

test "decode JSON, struct with array field, array field does not exists in data" {
	res := json.decode[StructWithArray]('{"noValue": [1, 2, 3]}').unwrap()
	t.assert_eq(res.value.len, 0, "array must be empty")
}

test "decode JSON, struct with array field, array field is not an array" {
	res := json.decode[StructWithArray]('{"value": 1}').unwrap()
	t.assert_eq(res.value.len, 0, "array must be empty")
}

test "decode JSON with error" {
	json.decode[Person]('{"name":"Alice",age":30}') or {
		t.assert_eq(err.msg(), "parse error near 'ge\":30}' at 1:18", "error messages should be equal")
		return
	}

	t.fail("should return error")
}

test "decode multiline JSON with error" {
	data := '
    {
        "name": "Alice",
        "age": 30,
    }'
	json.decode[Person](data) or {
		t.assert_eq(err.msg(), "parse error near '' at 5:6", "error messages should be equal")
		return
	}

	t.fail("should return error")
}
