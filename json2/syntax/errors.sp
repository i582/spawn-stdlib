module syntax

import strings

// ParseError describes an error that occurs while parsing a JSON file.
pub struct ParseError {
	// off is offset in the file where errors begin
	off usize
	// msg is message of this error
	msg string
}

// msg returns description message for error.
//
// For example:
// ```text
// parse error at offset 17: Unicode escape sequence not terminated
// ```
pub fn (e ParseError) msg() -> string {
	mut sb := strings.new_builder(100)
	sb.write_str('parse error at offset ')
	sb.write_str(e.off.str())
	sb.write_str(': ')
	sb.write_str(e.msg)
	return sb.str_view()
}
