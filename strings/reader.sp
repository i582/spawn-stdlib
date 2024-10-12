module strings

import io

// Reader is a wrapper over a string that implements [`io.Reader`].
pub struct Reader {
	data string
	i    i64
}

// new creates a new [`Reader`] that uses the given string as its data.
pub fn Reader.new(str string) -> Reader {
	return Reader{ data: str }
}

// read reads data from the string into the given buffer.
// Returns the number of bytes read.
// If the end of the string is reached, it returns `io.EOF`.
pub fn (r &mut Reader) read(buf &mut []u8) -> !i32 {
	if r.i >= r.data.len {
		return error(io.EOF as Error)
	}

	n := buf.copy_from(r.data.as_array()[r.i..])
	r.i += n as i64
	return n as i32
}
