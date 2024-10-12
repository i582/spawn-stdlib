module main

import toml

test "find table" {
	cases := [
		('[deps]\n name = "hello"', "deps", true),
		('[deps.with.dotted.name]\n name = "hello"', "deps.with.dotted.name", true),
		('[deps.with.dotted.name]\n name = "hello"', "deps.with.doted.name", false),
		('[deps.with."  dot  ted".and." some string ".name]\n name = "hello"', 'deps.with."  dot  ted".and." some string ".name', true),
	]

	for case in cases {
		doc, table_name, expected := case
		mut f := toml.parse(doc)
		_ = f.table(table_name) or {
			if expected {
				t.fail("expected to find table for ${doc}")
				toml.DocTable{}
			}

			return
		}

		if !expected {
			t.fail("expected to not find table for ${doc}")
			return
		}
	}
}

test "find value in table" {
	cases := [
		('[deps]\n name = "hello"', "name", true),
		('[deps]\n name.with.dotted.key = "hello"', "name.with.dotted.key", true),
		('[deps]\n name.with.dotted.key = "hello"', "name.with.doted.key", false),
		('[deps]\n name.with."  dot  ted".and." some string ".name = "hello"', 'name.with."  dot  ted".and." some string ".name', true),
	]

	for case in cases {
		doc, key, expected := case
		mut f := toml.parse(doc)
		table := f.table("deps").unwrap()
		_ = table.get(key) or {
			if expected {
				t.fail("expected to find key for ${doc}")
			}

			return
		}

		if !expected {
			t.fail("expected to not find key for ${doc}")
		}
	}
}

test "get nested value from table" {
	data := '
[package]
name = "hello"
version = "0.1.0"

[dependencies]
toml = "0.5.8"
markdown = { version = "0.5.8", optional = true, url = "https://example.com" }
'

	mut f := toml.parse(data)
	table := f.table("dependencies").unwrap()
	markdown := table.get("markdown")?.as_table().unwrap().unwrap()
	url := markdown.get("url")?.as_string().unwrap().unwrap()
	t.assert_eq(url, "https://example.com", "expected to get nested value from array")
}

test "get all values from table" {
	data := '
[package]
name = "hello"
version = "0.1.0"

[dependencies]
toml = "0.5.8"
markdown = { version = "0.5.8", optional = true, url = "https://example.com" }
json = "0.1.8"
yaml = { optional = true }
'

	mut f := toml.parse(data)
	table := f.table("dependencies").unwrap()

	mut versions := []string{}
	for key, value in table.as_map() {
		versions.push(key)
		if str := value.as_string() {
			versions.push(str)
		}
		if inline_table := value.as_table() {
			if version := inline_table.get("version") {
				versions.push(version.as_string().unwrap())
			} else {
				versions.push("unknown")
			}
		}
	}

	expected := ["yaml", "unknown", "markdown", "0.5.8", "toml", "0.5.8", "json", "0.1.8"]
	t.assert_eq(versions.str(), expected.str(), "expected to get all values from table")
}

test "get data from table with dots" {
	data := '
[package]
name = "hello"
version = "0.1.0"

[profile.dev]
opt-level = 0

[profile.release]
opt-level = 3
'

	mut f := toml.parse(data)
	dev := f.table("profile.dev").unwrap()
	release := f.table("profile.release").unwrap()

	t.assert_eq(dev.get("opt-level")?.as_int().unwrap().unwrap(), 0, "expected to get value from table with dots")
	t.assert_eq(release.get("opt-level")?.as_int().unwrap().unwrap(), 3, "expected to get value from table with dots")
}

test "get data or default" {
	data := '
[package]
name = "hello"
version = "0.1.0"

[profile.dev]

[profile.release]
opt-level = 3
'

	mut f := toml.parse(data)
	dev := f.table("profile.dev").unwrap()
	release := f.table("profile.release").unwrap()

	dev_opt_level := dev.get("opt-level")?.as_int().unwrap_or(1).unwrap()
	t.assert_eq(dev_opt_level, 1, "expected to get value from table with dots")
	t.assert_eq(release.get("opt-level")?.as_int().unwrap().unwrap(), 3, "expected to get value from table with dots")
}

test "get all values from table array" {
	data := '
[package]
name = "hello"
version = "0.1.0"

[[dependencies]]
name = "toml"

[[dependencies]]
name = "markdown"

[[dependencies]]
name = "json"
'

	mut f := toml.parse(data)
	table := f.table_array("dependencies")
	names := table.
		map_not_none(|table| table.get("name")).
		map_not_none(|name| name.as_string())

	expected := ["toml", "markdown", "json"]
	t.assert_eq(names.str(), expected.str(), "expected to get all values from table array")
}
