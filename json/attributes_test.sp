module main

import json

struct CustomPerson {
	#[json("PersonName")]
	name string

	#[json("PersonAge")]
	age i32
}

test "decode JSON, struct with field attribute with rename" {
	res := json.decode[CustomPerson]('{"PersonName": "John", "PersonAge": 30}').unwrap()
	t.assert_eq(res.name, "John", "name should be John")
	t.assert_eq(res.age, 30, "age should be 30")
}

test "decode JSON, struct with field attribute with rename with wrong names in data" {
	res := json.decode[CustomPerson]('{"name": "John", "age": 30}').unwrap()
	t.assert_eq(res.name, "", "name should be empty")
	t.assert_eq(res.age, 0, "age should be 0")
}

struct PersonWithSkip {
	#[json("PersonName")]
	name string

	#[json("PersonAge")]
	age i32

	#[skip]
	skip_field string
}

#[skip]
test "decode JSON, struct with skip" {
	res := json.decode[PersonWithSkip]('{"PersonName": "John", "PersonAge": 30, "skip_field": "skip"}').unwrap()
	t.assert_eq(res.name, "John", "name should be John")
	t.assert_eq(res.age, 30, "age should be 30")
	t.assert_eq(res.skip_field, "", "skip_field should be empty")
}

struct WithRaw {
	name string
	age  i32

	#[raw]
	other string
}

test "decode JSON, struct with raw" {
	res := json.decode[WithRaw]('{"name": "John", "age": 30, "other": {"key": "value"}}').unwrap()
	t.assert_eq(res.name, "John", "name should be John")
	t.assert_eq(res.age, 30, "age should be 30")
	t.assert_eq(res.other, '{"key":"value"}', 'other should be {"key":"value"}')
}

#[rename_all("camelCase")]
struct WithRenameAllFields {
	name                   string
	some_field             string
	maybe_some_other_field string
}

test "decode JSON, struct with rename_all with camelCase" {
	res := json.decode[WithRenameAllFields]('{"name": "John", "someField": "value", "maybeSomeOtherField": "value"}').unwrap()
	t.assert_eq(res.name, "John", "name should be John")
	t.assert_eq(res.some_field, "value", "some_field should be value")
	t.assert_eq(res.maybe_some_other_field, "value", "maybe_some_other_field should be value")
}

test "encode JSON, struct with rename_all with camelCase" {
	res := json.encode[WithRenameAllFields](WithRenameAllFields{ name: "John", some_field: "value", maybe_some_other_field: "value" })
	t.assert_eq(res, '{"name":"John","someField":"value","maybeSomeOtherField":"value"}', "encoded JSON should be correct")
}

#[rename_all("camelCase")]
struct WithRenameAllFieldsAndFieldAttribute {
	name       string
	some_field string

	#[json("MaybeSomeOtherField")]
	maybe_some_other_field string
}

test "decode JSON, struct with rename_all with camelCase and field attribute with rename" {
	res := json.decode[WithRenameAllFieldsAndFieldAttribute]('{"name": "John", "someField": "value", "MaybeSomeOtherField": "value"}').unwrap()
	t.assert_eq(res.name, "John", "name should be John")
	t.assert_eq(res.some_field, "value", "some_field should be value")
	t.assert_eq(res.maybe_some_other_field, "value", "maybe_some_other_field should be value")
}

test "encode JSON, struct with rename_all with camelCase and field attribute with rename" {
	res := json.encode[WithRenameAllFieldsAndFieldAttribute](WithRenameAllFieldsAndFieldAttribute{ name: "John", some_field: "value", maybe_some_other_field: "value" })
	t.assert_eq(res, '{"name":"John","someField":"value","MaybeSomeOtherField":"value"}', "encoded JSON should be correct")
}
