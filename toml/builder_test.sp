module main

import toml

test "create simple toml document" {
	mut f := toml.File.new()
	mut table := toml.Table.new(toml.Ident.new("profile"))
	table.add_entry(toml.KeyValue.new(toml.Ident.new("name"), toml.String.new("toml")))
	f.add_table(table)

	res := '[profile]
name = "toml"
'

	t.assert_eq(res, f.encode(), 'toml document should be equal to expected value')
}

test "create table with dotted key" {
	mut f := toml.File.new()
	mut table := toml.Table.new(toml.Key.new("profile.dev"))
	table.add_entry(toml.KeyValue.new(toml.Ident.new("name"), toml.String.new("toml")))
	f.add_table(table)

	res := '[profile.dev]
name = "toml"
'

	t.assert_eq(res, f.encode(), 'toml document should be equal to expected value')
}

test "create inline table" {
	mut f := toml.File.new()
	mut table := toml.Table.new(toml.Ident.new("profile"))

	mut inline_table := toml.InlineTable.new()
	inline_table.add_entry(toml.KeyValue.new(toml.Ident.new("name"), toml.String.new("toml")))

	table.add_entry(toml.KeyValue.new(toml.Ident.new("markdown"), inline_table))
	f.add_table(table)

	res := '[profile]
markdown = { name = "toml" }
'

	t.assert_eq(res, f.encode(), 'toml document should be equal to expected value')
}

test "create array value" {
	mut f := toml.File.new()
	mut table := toml.Table.new(toml.Ident.new("profile"))

	mut array := toml.TomlArray.new()
	array.add(toml.String.new("toml"))
	array.add(toml.Boolean.new(true))
	array.add(toml.Boolean.new(false))
	array.add(toml.Integer.new(100))
	array.add(toml.Float.new(156.34))

	table.add_entry(toml.KeyValue.new(toml.Ident.new("markdown"), array))
	f.add_table(table)

	res := '[profile]
markdown = ["toml", true, false, 100, 156.340000]
'

	t.assert_eq(res, f.encode(), 'toml document should be equal to expected value')
}

test "create nested array value" {
	mut f := toml.File.new()
	mut table := toml.Table.new(toml.Ident.new("profile"))

	mut array := toml.TomlArray.new()
	array.add(toml.String.new("json"))

	mut array2 := toml.TomlArray.new()
	array2.add(toml.String.new("toml"))

	mut array3 := toml.TomlArray.new()
	array3.add(array)
	array3.add(array2)

	table.add_entry(toml.KeyValue.new(toml.Ident.new("markdown"), array3))
	f.add_table(table)

	res := '[profile]
markdown = [["json"], ["toml"]]
'

	t.assert_eq(res, f.encode(), 'toml document should be equal to expected value')
}
