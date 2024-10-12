module text

import strings
import text

// wrap_string wraps a string to a given length, breaking lines at word boundaries
// and preserving existing line breaks. If a word is longer than the given length,
// it will be NOT be broken and will be written as a single line.
//
// See [`wrap_string_to`] if you want to write result to a builder.
//
// Example:
// ```
// res := wrap_string("hello world", 5)
// assert res == "hello\nworld"
// ```
pub fn wrap_string(text string, len usize) -> string {
	mut sb := strings.new_builder(text.len)
	wrap_string_to(&mut sb, text, len)
	return sb.str_view()
}

// wrap_string_to wraps a string to a given length, breaking lines at word boundaries
// and preserving existing line breaks. If a word is longer than the given length,
// it will be NOT be broken and will be written as a single line.
//
// See [`wrap_string`] if you want to get a string result.
//
// Example:
// ```
// mut sb := strings.new_builder(100)
// wrap_string_to(&mut sb, "hello world", 5)
// assert sb.str_view() == "hello\nworld"
// ```
pub fn wrap_string_to(sb &mut strings.Builder, text string, len usize) {
	mut word_buf := strings.new_builder(10)
	mut line_sb := strings.new_builder(len)
	for ch in text {
		if ch == b` ` || ch == b`\t` {
			// if new word doesn't fit, flush line
			// and start new line with this word
			if line_sb.len + word_buf.len > len {
				sb.write(line_sb as []u8) or {}
				sb.write_u8(b`\n`)

				line_sb.clear()
				line_sb.write(word_buf as []u8) or {}
				word_buf.clear()
				continue
			}

			if line_sb.len > 0 {
				line_sb.write_u8(b` `)
			}
			line_sb.write(word_buf as []u8) or {}

			if ch == b`\n` {
				sb.write_u8(b`\n`)
			}

			word_buf.clear()
			continue
		}

		if ch == b`\n` {
			// if new word doesn't fit, flush line
			// and start new line with this word
			if line_sb.len + word_buf.len > len {
				sb.write(line_sb as []u8) or {}
				sb.write_u8(b`\n`)

				sb.write(word_buf as []u8) or {}
				sb.write_u8(b`\n`)

				line_sb.clear()
				word_buf.clear()
				continue
			}

			if line_sb.len > 0 {
				line_sb.write_u8(b` `)
			}
			line_sb.write(word_buf as []u8) or {}
			sb.write(line_sb as []u8) or {}
			sb.write_u8(ch)

			line_sb.clear()
			word_buf.clear()
			continue
		}

		word_buf.write_u8(ch)
	}

	if word_buf.len != 0 && line_sb.len == 0 {
		line_sb.write(word_buf) or {}
		word_buf.clear()
	}

	sb.write(line_sb as []u8) or {}
	if line_sb.len > 0 && word_buf.len > 0 {
		if line_sb.len + word_buf.len > len {
			sb.write_u8(b`\n`)
			sb.write(word_buf as []u8) or {}
		} else {
			sb.write_u8(b` `)
			sb.write(word_buf as []u8) or {}
		}
	}
}

// indent_text indents a text by a given number of spaces. If skip_first_line is true,
// the first line will not be indented. If the text contains no newlines and `skip_first_line`
// is true, the text will be returned as is.
//
// See [`indent_text_to`] if you want to write result to a builder.
//
// Example:
// ```
// res := text.indent_text("hello\nworld", indent: 4, skip_first_line: false)
// println(res)
// ```
// will print:
// ```text
//     hello
//     world
// ```
//
// `skip_first_line: true` usually used when you need to indent a multiline string
// and print result in a line with other text. For example:
//
// ```
// res := text.indent_text("hello\nworld", indent: 8, skip_first_line: true)
// println("prefix: " + res)
// ```
// will print:
// ```text
// prefix: hello
//         world
// ```
pub fn indent_text(text string, indent usize, skip_first_line bool) -> string {
	if !text.contains('\n') && skip_first_line {
		return text
	}

	mut sb := strings.new_builder(text.len + indent)
	indent_text_to(&mut sb, text, indent, skip_first_line)
	return sb.str_view()
}

// indent_text_to indents a text by a given number of spaces. If skip_first_line is true,
// the first line will not be indented. If the text contains no newlines and `skip_first_line`
// is true, the text will be written as is.
//
// See [`indent_text`] if you want to get a string result.
//
// Example:
// ```
// mut sb := strings.new_builder(100)
// text.indent_text_to(&mut sb, "hello\nworld", indent: 4, skip_first_line: false)
// println(sb.str_view())
// ```
// will print:
// ```text
//     hello
//     world
// ```
//
// `skip_first_line: true` usually used when you need to indent a multiline string
// and print result in a line with other text. For example:
//
// ```
// mut sb := strings.new_builder(100)
// sb.write_str("prefix: ")
// text.indent_text_to(&mut sb, "hello\nworld", indent: 8, skip_first_line: true)
// println(sb.str_view())
// ```
// will print:
// ```text
// prefix: hello
//         world
// ```
pub fn indent_text_to(sb &mut strings.Builder, text string, indent usize, skip_first_line bool) {
	if !text.contains('\n') && skip_first_line {
		sb.write_str(text)
		return
	}

	mut iter := text.split_iter('\n')
	if skip_first_line {
		if line := iter.next() {
			sb.write_str(line)
			sb.write_u8(b`\n`)
		}
	}

	for i, line in iter {
		for _ in 0 .. indent {
			sb.write_u8(b` `)
		}
		sb.write_str(line)
		sb.write_u8(b`\n`)
	}

	sb.trim(1)
}

// ordinal_suffix returns ordinal suffix for given number.
//
// Example:
// ```
// num := 11
// suffix := text.ordinal_suffix(num)
// assert '${num}${suffix}' == '11th'
// ```
pub fn ordinal_suffix(n i64) -> string {
	if n > 3 && n < 21 {
		return 'th'
	}
	return match n % 10 {
		1 => 'st'
		2 => 'nd'
		3 => 'rd'
		else => 'th'
	}
}
