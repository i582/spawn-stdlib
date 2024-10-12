module main

import bufio
import fs
import pathlib
import strings
import io

test "simple read file" {
	file := fs.open_file(pathlib.join($DIR, 'testdata', 'small_file.txt'), 'r').unwrap()
	reader := bufio.reader(file)

	mut first_word_buf := []u8{len: 5}
	read := reader.read(&mut first_word_buf).unwrap()
	t.assert_eq(read, 5, 'actual should be equal to expected')
	t.assert_eq(first_word_buf.ascii_str(), 'hello', 'actual should be equal to expected')

	new_line := reader.read_byte().unwrap()
	t.assert_eq(new_line, b`\n`, 'actual should be equal to expected')

	mut second_word_buf := []u8{len: 5}
	read2 := reader.read(&mut second_word_buf).unwrap()
	t.assert_eq(read2, 5, 'actual should be equal to expected')
	t.assert_eq(second_word_buf.ascii_str(), 'world', 'actual should be equal to expected')
}

test "read to empty buffer" {
	file := fs.open_file(pathlib.join($DIR, 'testdata', 'small_file.txt'), 'r').unwrap()
	reader := bufio.reader(file)

	mut empty_buf := []u8{cap: 5}
	read := reader.read(&mut empty_buf).unwrap()
	t.assert_eq(read, 0, 'actual should be equal to expected')
	t.assert_eq(empty_buf.len, 0, 'actual should be equal to expected')
}

test "read chunk by chunk off by 1" {
	str := strings.Reader.new('some_very_long_single_word some_very_long_single_word some_very_long_single_word some_very_long_single_word some_very_long_single_word ')
	reader := bufio.reader_sized(str, 28)

	mut i := 0

	mut buf := []u8{len: 27}
	read := reader.read(&mut buf).unwrap()
	t.assert_eq(read, 27, 'actual should be equal to expected')
	t.assert_eq(buf[..read].ascii_str(), 'some_very_long_single_word ', 'actual should be equal to expected')

	// second read will fill remaining 1 byte space
	read2 := reader.read(&mut buf).unwrap()
	t.assert_eq(read2, 1, 'actual should be equal to expected')
	t.assert_eq(buf[..read2].ascii_str(), 's', 'actual should be equal to expected')

	// and third will read whole buffer
	read3 := reader.read(&mut buf).unwrap()
	t.assert_eq(read3, 27, 'actual should be equal to expected')
	t.assert_eq(buf[..read3].ascii_str(), 'ome_very_long_single_word s', 'actual should be equal to expected')

	// and again only one
	read4 := reader.read(&mut buf).unwrap()
	t.assert_eq(read4, 1, 'actual should be equal to expected')
	t.assert_eq(buf[..read4].ascii_str(), 'o', 'actual should be equal to expected')
}

test "read chunk bigger than capacity" {
	str := strings.Reader.new('some_very_long_single_word')
	reader := bufio.reader_sized(str, 16)

	mut buf := []u8{len: 26}
	read := reader.read(&mut buf).unwrap()
	t.assert_eq(read, 26, 'actual should be equal to expected')
	t.assert_eq(buf[..read].ascii_str(), 'some_very_long_single_word', 'actual should be equal to expected')
}

test "read simple rune" {
	str := strings.Reader.new('Բարեւ')
	reader := bufio.reader_sized(str, 28)

	r, len := reader.read_rune().unwrap()
	t.assert_eq(r, `Բ`, 'actual should be equal to expected')
	t.assert_eq(len, 2, 'actual should be equal to expected')

	r2, len2 := reader.read_rune().unwrap()
	t.assert_eq(r2, `ա`, 'actual should be equal to expected')
	t.assert_eq(len2, 2, 'actual should be equal to expected')
}

test "read rune when internal buffer contains only one byte" {
	str := strings.Reader.new('some_very_long_single_word Բարեւ')
	reader := bufio.reader_sized(str, 28)

	// read all before Բ
	mut buf := []u8{len: 27}
	read := reader.read(&mut buf).unwrap()
	t.assert_eq(read, 27, 'actual should be equal to expected')
	t.assert_eq(buf[..read].ascii_str(), 'some_very_long_single_word ', 'actual should be equal to expected')

	r, len := reader.read_rune().unwrap()
	t.assert_eq(r, `Բ`, 'actual should be equal to expected')
	t.assert_eq(len, 2, 'actual should be equal to expected')

	r2, len2 := reader.read_rune().unwrap()
	t.assert_eq(r2, `ա`, 'actual should be equal to expected')
	t.assert_eq(len2, 2, 'actual should be equal to expected')
}

test "read rune when internal buffer contains only two bytes with two byte rune" {
	str := strings.Reader.new('some_very_long_single_word Բարեւ')
	reader := bufio.reader_sized(str, 29)

	// read all before Բ
	mut buf := []u8{len: 27}
	read := reader.read(&mut buf).unwrap()
	t.assert_eq(read, 27, 'actual should be equal to expected')
	t.assert_eq(buf[..read].ascii_str(), 'some_very_long_single_word ', 'actual should be equal to expected')

	r, len := reader.read_rune().unwrap()
	t.assert_eq(r, `Բ`, 'actual should be equal to expected')
	t.assert_eq(len, 2, 'actual should be equal to expected')

	r2, len2 := reader.read_rune().unwrap()
	t.assert_eq(r2, `ա`, 'actual should be equal to expected')
	t.assert_eq(len2, 2, 'actual should be equal to expected')
}

test "read rune when internal buffer contains only three bytes with three byte rune" {
	str := strings.Reader.new('some_very_long_single_word 内部')
	reader := bufio.reader_sized(str, 30)

	// read all before 内
	mut buf := []u8{len: 27}
	read := reader.read(&mut buf).unwrap()
	t.assert_eq(read, 27, 'actual should be equal to expected')
	t.assert_eq(buf[..read].ascii_str(), 'some_very_long_single_word ', 'actual should be equal to expected')

	r, len := reader.read_rune().unwrap()
	t.assert_eq(r, `内`, 'actual should be equal to expected')
	t.assert_eq(len, 3, 'actual should be equal to expected')

	r2, len2 := reader.read_rune().unwrap()
	t.assert_eq(r2, `部`, 'actual should be equal to expected')
	t.assert_eq(len2, 3, 'actual should be equal to expected')
}

test "read line with buf bigger than line length" {
	str := strings.Reader.new('some very long single word
and one more some very long single word')
	reader := bufio.reader_sized(str, 100)

	slice, is_prefix := reader.read_line().unwrap()
	t.assert_eq(slice.ascii_str(), 'some very long single word', 'actual should be equal to expected')
	t.assert_false(is_prefix, 'actual should be equal to expected')
}

test "read line with buf less than line length" {
	str := strings.Reader.new('some very long single word
and one more some very long single word')
	reader := bufio.reader_sized(str, 20)

	// read first 20 bytes
	slice, is_prefix := reader.read_line().unwrap()
	t.assert_eq(slice.ascii_str(), 'some very long singl', 'actual should be equal to expected')
	t.assert_true(is_prefix, 'actual should be equal to expected')

	// and remeining part
	end, end_is_prefix := reader.read_line().unwrap()
	t.assert_eq(end.ascii_str(), 'e word', 'actual should be equal to expected')
	t.assert_false(end_is_prefix, 'second call should read until end of line')
}

test "read line for single line string" {
	str := strings.Reader.new('some very long single word')
	reader := bufio.reader_sized(str, 100)

	slice, is_prefix := reader.read_line().unwrap()
	t.assert_eq(slice.ascii_str(), 'some very long single word', 'actual should be equal to expected')
	t.assert_false(is_prefix, 'actual should be equal to expected')
}

test "read bytes with buf less than line length" {
	str := strings.Reader.new('some very long single word
and one more some very long single word
')
	reader := bufio.reader_sized(str, 20)

	// read bytes will read whole line
	arr := reader.read_bytes(b`\n`).unwrap()
	t.assert_eq(arr.ascii_str(), 'some very long single word\n', 'actual should be equal to expected')

	// and second one
	arr2 := reader.read_bytes(b`\n`).unwrap()
	t.assert_eq(arr2.ascii_str(), 'and one more some very long single word\n', 'actual should be equal to expected')
}

test "read string with buf less than line length" {
	str := strings.Reader.new('some very long single word
and one more some very long single word
')
	reader := bufio.reader_sized(str, 20)

	// read bytes will read whole line
	str1 := reader.read_string(b`\n`).unwrap()
	t.assert_eq(str1, 'some very long single word\n', 'actual should be equal to expected')

	// and second one
	str2 := reader.read_string(b`\n`).unwrap()
	t.assert_eq(str2, 'and one more some very long single word\n', 'actual should be equal to expected')
}

test "read string with space delimeter" {
	data := 'some very long single sentence'
	str := strings.Reader.new(data)
	reader := bufio.reader_sized(str, 20)

	mut words := []string{}
	for {
		word := reader.read_string(b` `) or {
			if err is io.Eof {
				break
			}

			t.fail('unexpected error: ${err.msg()}')
			return
		}

		words.push(word[..word.len - 1])
	}

	expected_words := data.split(' ')
	t.assert_eq(words.str(), expected_words[..expected_words.len - 1].str(), 'actual should be equal to expected')
}

test "read after EOF" {
	str := strings.Reader.new('some very long single word')
	reader := bufio.reader(str)

	mut buf := []u8{len: 100}

	// read all data
	read := reader.read(&mut buf).unwrap()
	t.assert_eq(read, 26, 'actual should be equal to expected')
	t.assert_eq(buf[..read].ascii_str(), 'some very long single word', 'actual should be equal to expected')

	reader.read(&mut buf) or {
		t.assert_eq(err.msg(), 'end of file', 'actual should be equal to expected')
		return
	}

	t.fail('second read should fail')
}
