module os

import fs
import strings

// input reads a line from stdin and returns it without the newline.
// If the line is empty, it returns an empty string.
//
// See also `input_opt()` to distinguish between empty input and EOF.
pub fn input(prompt string) -> string {
	return input_opt(prompt) or { '' }
}

// input_opt reads a line from stdin and returns it without the newline.
// If the line is empty, it returns `none`.
pub fn input_opt(prompt string) -> ?string {
	print(prompt)
	fs.flush_stdout()
	line := readln().trim_end("\n\r")
	if line == "" {
		return none
	}
	return line
}

// input_password reads a line from stdin without echoing the input.
// If password cannot be read safely, function returns error.
pub fn input_password(prompt string) -> !string {
	print(prompt)
	fs.flush_stdout()
	return readln_hidden()!.trim_end("\n\r")
}

// read_lines reads lines from stdin until an EOF is encountered.
pub fn read_lines() -> string {
	mut sb := strings.new_builder(100)
	for {
		line := readln()
		if line == '' {
			break
		}
		sb.write_str(line)
		sb.write_u8(b`\n`)
	}
	return sb.str_view()
}
