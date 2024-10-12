module main

import strings
import io

test "string reader from string" {
	mut r := strings.Reader.new("hello world")

	mut buf := []u8{len: 5}
	mut read := r.read(&mut buf).unwrap()
	t.assert_eq(read, 5, "read should return 5")
	t.assert_eq(buf.ascii_str(), "hello", "buf should be hello")

	read = r.read(&mut buf).unwrap()
	t.assert_eq(read, 5, "read should return 5")
	t.assert_eq(buf.ascii_str(), " worl", "buf should be owor")

	read = r.read(&mut buf).unwrap()
	t.assert_eq(read, 1, "read should return 1")
	t.assert_eq(buf[..read].ascii_str(), "d", "buf should be d wor")

	r.read(&mut buf) or {
		if err !is io.Eof {
			t.fail("read should return EOF")
		}
		return
	}

	t.fail("last read should return EOF")
}
