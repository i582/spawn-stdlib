module json

pub struct ParseError {
	line usize
	col  usize
	msg  string
}

pub fn ParseError.from(msg string, offset usize, content string) -> ParseError {
	mut line := 1
	mut col := 1
	for i in 0 .. offset {
		if content[i] == b`\n` {
			line++
			col = 1
		} else {
			col++
		}
	}

	return ParseError{
		line: line
		col: col
		msg: "parse error near '${msg}'"
	}
}

pub fn (e ParseError) msg() -> string {
	return "${e.msg} at ${e.line}:${e.col}"
}
