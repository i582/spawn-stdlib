module toml

import toml.token
import strings

pub type ErrorCallback = fn (err ParseError)

pub struct ParseError {
	pos token.Pos
	msg string
}

pub fn ParseError.new(pos token.Pos, msg string) -> ParseError {
	return ParseError{ pos: pos, msg: msg }
}

pub fn (e ParseError) msg() -> string {
	return e.to_string()
}

pub fn (e ParseError) to_string() -> string {
	mut sb := strings.new_builder(100)
	sb.write_str('parse error at ')
	sb.write_str(e.pos.str())
	sb.write_str(': ')
	sb.write_str(e.msg)
	return sb.str_view()
}
