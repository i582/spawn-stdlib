module main

import json2.syntax
import json2.format

test "format object" {
	cases := [
		('{ "name": "John" }', '{
    "name": "John"
}'),
		('{ "name": "John", "age": 100 }', '{
    "name": "John",
    "age": 100
}'),
		('{ "true": true, "false": false, "float": 10.5, "null": null }', '{
    "true": true,
    "false": false,
    "float": 10.5,
    "null": null
}'),
	]

	for case in cases {
		data, expected := case
		mut p := syntax.Parser.new(data)
		file := p.parse_file().unwrap()
		actual := format.format(file).trim_spaces()
		t.assert_eq(actual, expected, 'actual should be equal to expected')
	}
}

test "format array" {
	cases := [
		('{ "arr": [1, 2, 3] }', '{
    "arr": [1, 2, 3]
}'),
		('{ "arr": ["first", "second"] }', '{
    "arr": ["first", "second"]
}'),
		('{ "arr": [{ "first": 1 }, { "second": 2 }] }', '{
    "arr": [
        {
            "first": 1
        },
        {
            "second": 2
        }
    ]
}'),
		('{ "name": { "data": [[1, { "data": 100.5 }], [{ "age": 100 }, 3], [4, 5], { "data": 100.5 }] } }', '{
    "name": {
        "data": [
            [
                1,
                {
                    "data": 100.5
                }
            ],
            [
                {
                    "age": 100
                },
                3
            ],
            [4, 5],
            {
                "data": 100.5
            }
        ]
    }
}'),
	]

	for case in cases {
		data, expected := case
		mut p := syntax.Parser.new(data)
		file := p.parse_file().unwrap()
		actual := format.format(file).trim_spaces()
		t.assert_eq(actual, expected, 'actual should be equal to expected')
	}
}

test "format object compact" {
	cases := [
		('{ "name": "John" }', '{"name":"John"}'),
		('{ "name": "John", "age": 100 }', '{"name":"John","age":100}'),
		('{ "true": true, "false": false, "float": 10.5, "null": null }', '{"true":true,"false":false,"float":10.5,"null":null}'),
	]

	for case in cases {
		data, expected := case
		mut p := syntax.Parser.new(data)
		file := p.parse_file().unwrap()
		actual := format.format_compact(file).trim_spaces()
		t.assert_eq(actual, expected, 'actual should be equal to expected')
	}
}

test "format array compact" {
	cases := [
		('{ "arr": [1, 2, 3] }', '{"arr":[1,2,3]}'),
		('{ "arr": ["first", "second"] }', '{"arr":["first","second"]}'),
		('{ "arr": [{ "first": 1 }, { "second": 2 }] }', '{"arr":[{"first":1},{"second":2}]}'),
		('{ "name": { "data": [[1, { "data": 100.5 }], [{"age":100},3],[4,5],{"data":100.5}]}}', '{"name":{"data":[[1,{"data":100.5}],[{"age":100},3],[4,5],{"data":100.5}]}}'),
	]

	for case in cases {
		data, expected := case
		mut p := syntax.Parser.new(data)
		file := p.parse_file().unwrap()
		actual := format.format_compact(file).trim_spaces()
		t.assert_eq(actual, expected, 'actual should be equal to expected')
	}
}
