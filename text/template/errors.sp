module template

import text.template.token
import strings
import term
import fs

// TemplateError represents an error that occurred during template parsing or rendering.
pub union TemplateError = ParseError | RendererError | TemplateCannotBeLoaded

// msg returns the error message that suitable for logging.
pub fn (t &TemplateError) msg() -> string {
	return match t {
		ParseError => t.msg()
		RendererError => t.msg()
		TemplateCannotBeLoaded => t.msg()
	}
}

// render returns the error message that suitable for displaying to the user.
pub fn (t &TemplateError) render() -> string {
	return match t {
		ParseError => t.render()
		RendererError => t.render()
		TemplateCannotBeLoaded => t.msg()
	}
}

// ParseError represents an error that occurred during template parsing.
pub type ParseError = BaseTmplError

// RendererError represents an error that occurred during template rendering.
pub type RendererError = BaseTmplError

// TemplateCannotBeLoaded represents an error that occurred when a template cannot be loaded.
pub type TemplateCannotBeLoaded = fs.FsError

struct BaseTmplError {
	template string
	filepath string
	pos      token.Pos
	msg      string
	help     string
}

pub fn (e BaseTmplError) msg() -> string {
	return term.strip_ansi(e.render())
}

pub fn (e BaseTmplError) render() -> string {
	lines := e.template.split_into_lines()
	if lines.len == 0 {
		return "${e.msg} at ${e.pos}"
	}
	mut offset := e.pos.offset
	mut line_for_offset := 0
	mut offset_in_line := 0 as usize
	for i, line in lines {
		if offset < line.len {
			line_for_offset = i
			offset_in_line = offset
			break
		}
		offset -= line.len + 1
	}

	line := lines[line_for_offset]
	underline := if e.pos.len != 0 {
		" ".repeat(offset_in_line) + "^".repeat(e.pos.len)
	} else {
		""
	}

	mut sb := strings.new_builder(100)
	sb.write_str(term.bold("${e.filepath}:${line_for_offset + 1}:${offset_in_line}"))
	sb.write_str(": ")
	sb.write_str(e.msg)
	sb.write_str("\n")
	sb.write_str(line)
	sb.write_str("\n")
	sb.write_str(term.bright_red(underline))
	sb.write_str("\n")
	if e.help.len > 0 {
		sb.write_str(term.bold("help: "))
		sb.write_str(e.help)
		sb.write_str("\n")
	}
	return sb.str_view()
}
