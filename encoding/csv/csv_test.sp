module main

import encoding.csv

test "can read record from string" {
	content := "name,age\nalice,20\nbob,30"
	mut reader := csv.Reader.from_string(content)
	record := reader.read_record().unwrap()
	t.assert_eq(record.as_array().str(), ["name", "age"].str(), "actual value should equal to expected")
}

test "can read record from string with only one line" {
	content := "alice,20"
	mut reader := csv.Reader.from_string(content)
	record := reader.read_record().unwrap()
	t.assert_eq(record.as_array().str(), ["alice", "20"].str(), "actual value should equal to expected")
}

test "can read record from string with several line for field" {
	content := '"two
line","one line","three
line
field"'
	mut reader := csv.Reader.from_string(content)
	record := reader.read_record().unwrap()
	t.assert_eq(record.as_array().str(), ["two\nline", "one line", "three\nline\nfield"].str(), "actual value should equal to expected")
}

test "can read all records from string with custom separator" {
	content := "name;age\nalice;20\nbob;30"
	mut reader := csv.Reader.from_string(content)
	reader.comma = b`;`
	records := reader.read_all().unwrap()
	t.assert_eq(records.map(|el| el.as_array()).str(), [["name", "age"], ["alice", "20"], ["bob", "30"]].str(), "actual value should equal to expected")
}

test "can read all records from string with crlf separator" {
	content := "a,b\r\nc,d\r\ne,f"
	mut reader := csv.Reader.from_string(content)
	records := reader.read_all().unwrap()
	t.assert_eq(records.map(|el| el.as_array()).str(), [["a", "b"], ["c", "d"], ["e", "f"]].str(), "actual value should equal to expected")
}

test "can read all records from string bare cr separator" {
	content := "a,b\rc,d\r\n"
	mut reader := csv.Reader.from_string(content)
	records := reader.read_all().unwrap()
	t.assert_eq(records.map(|el| el.as_array()).str(), [["a", "b\rc", "d"]].str(), "actual value should equal to expected")
}

test "can read all records from string with comments" {
	content := "name;age
# comment
# comment
alice;20
# comment
bob;30
# comment
"
	mut reader := csv.Reader.from_string(content)
	reader.comma = b`;`
	reader.comment = b`#`
	records := reader.read_all().unwrap()
	t.assert_eq(records.map(|el| el.as_array()).str(), [["name", "age"], ["alice", "20"], ["bob", "30"]].str(), "actual value should equal to expected")
}

test "can read all records from string with commented records" {
	content := "#name;age
alice;20
#bob;30
"
	mut reader := csv.Reader.from_string(content)
	reader.comma = b`;`
	reader.comment = b`#`
	records := reader.read_all().unwrap()
	t.assert_eq(records.map(|el| el.as_array()).str(), [["alice", "20"]].str(), "actual value should equal to expected")
}

test "can read all records from string with blank lines separator" {
	content := "name;age\n\nalice;20\n\nbob;30"
	mut reader := csv.Reader.from_string(content)
	reader.comma = b`;`
	records := reader.read_all().unwrap()
	t.assert_eq(records.map(|el| el.as_array()).str(), [["name", "age"], ["alice", "20"], ["bob", "30"]].str(), "actual value should equal to expected")
}

test "can read all records from string with trim spaces" {
	content := "  \tname;     age\n  \t\talice;    20\n  bob;    30"
	mut reader := csv.Reader.from_string(content)
	reader.comma = b`;`
	reader.trim_leading_space = true
	records := reader.read_all().unwrap()
	t.assert_eq(records.map(|el| el.as_array()).str(), [["name", "age"], ["alice", "20"], ["bob", "30"]].str(), "actual value should equal to expected")
}

test "can read record from string with huge width" {
	huge_string := "AAA".repeat(10000)

	content := "# ignore
${huge_string};age
alice;20
"
	mut reader := csv.Reader.from_string(content)
	reader.comma = b`;`
	reader.comment = b`#`
	record := reader.read_record().unwrap()
	t.assert_eq(record.get(0).unwrap(), huge_string, "actual value should equal to expected")
	t.assert_eq(record.get(1).unwrap(), "age", "actual value should equal to expected")

	record2 := reader.read_record().unwrap()
	t.assert_eq(record2.get(0).unwrap(), "alice", "actual value should equal to expected")
	t.assert_eq(record2.get(1).unwrap(), "20", "actual value should equal to expected")
}
