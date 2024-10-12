module main

import net.urllib

test "simple values encode" {
	mut val := urllib.Values{}
	val.add("key", "value")
	val.add("key", "value2")

	t.assert_eq(val.encode(), "key=value&key=value2", "encoded value must be equal")
}

test "values encode with special characters" {
	mut val := urllib.Values{}
	val.add("key", "<value>")
	val.add("key", "???")
	val.add("key", "&&&")

	t.assert_eq(val.encode(), "key=%3Cvalue%3E&key=%3F%3F%3F&key=%26%26%26", "encoded value must be equal")
}

test "parse string values with special characters" {
	val := urllib.parse_query('key=%3Cvalue%3E&key=%3F%3F%3F&key=%26%26%26') or {
		t.fail("failed to parse query: ${err.msg()}")
		return
	}

	values := val.get_all("key")
	t.assert_eq(values[0], "<value>", "first value must be equal")
	t.assert_eq(values[1], "???", "second value must be equal")
	t.assert_eq(values[2], "&&&", "third value must be equal")
}
