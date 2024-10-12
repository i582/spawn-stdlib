module textscanner

// TextScanner simplifies writing small scanners/parsers
// by providing safe methods to scan texts character by
// character, peek for the next characters, go back, etc.
pub struct TextScanner {
	input []u8
	len   usize
	pos   usize // current position; pos is *always* kept in `[0..len]`
}

// new returns a stack allocated instance of TextScanner for a given string.
pub fn new(input string) -> TextScanner {
	return TextScanner{ input: unsafe { input.bytes_no_copy() }, len: input.len }
}

// bytes returns a stack allocated instance of TextScanner for a given byte array.
pub fn bytes(input []u8) -> TextScanner {
	return TextScanner{ input: input, len: input.len }
}

pub fn (ss &mut TextScanner) next() -> i32 {
	if ss.pos < ss.len {
		opos := ss.pos
		ss.pos++
		return ss.input[opos]
	}
	return -1
}
