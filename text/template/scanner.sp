module template

import text.template.token

// This file defines the scanner for the template language.

struct Scanner {
	src      string
	src_len  usize
	filepath string

	tok    token.Token = .text
	ch     rune
	offset usize

	inside_text bool = true
}

fn Scanner.new(src string, filepath string) -> &mut Scanner {
	return &mut Scanner{ src: src, src_len: src.len, filepath: filepath }
}

fn (s &mut Scanner) next() {
	if s.offset >= s.src.len {
		s.tok = .eof
		return
	}

	s.offset++
	s.ch = s.src[s.offset]
}

fn (s &mut Scanner) skip_whitespaces() {
	for s.offset < s.src_len {
		ch := s.src[s.offset]
		if ch == b` ` || ch == b`\t` || ch == b`\n` || ch == b`\r` {
			s.next()
			continue
		}

		s.ch = ch
		break
	}
}

fn (s &mut Scanner) scan() -> (token.Pos, token.Token, string) {
	mut lit := ''
	mut tok := token.Token.illegal
	mut pos := token.Pos{ offset: s.offset }

	if s.tok == .eof {
		return pos, .eof, ''
	}

	// when we lex a raw text block
	if s.inside_text {
		lit = s.scan_raw_text()
		tok = .text
	} else {
		s.skip_whitespaces()

		pos.offset = s.offset
		ch := s.ch

		match ch {
			0 => {
				tok = .eof
			}
			`{` => {
				s.next()
				if s.ch == b`{` {
					s.next()
					tok = .open_brace
					lit = '{{'
				}
			}
			`.` => {
				tok = .dot
				s.next()
			}
			`|` => {
				s.next()
				if s.ch == b`|` {
					s.next()
					tok = .cond_or
				} else {
					tok = .pipe
				}
			}
			`&` => {
				s.next()
				if s.ch == b`&` {
					s.next()
					tok = .cond_and
				} else {
					tok = .and
				}
			}
			`!` => {
				s.next()
				if s.ch == b`=` {
					s.next()
					tok = .not_equal
				} else {
					tok = .not
				}
			}
			`:` => {
				s.next()
				if s.ch == b`=` {
					s.next()
					tok = .define
				}
			}
			`=` => {
				s.next()
				if s.ch == b`=` {
					s.next()
					tok = .equal
				} else {
					tok = .assign
				}
			}
			`>` => {
				s.next()
				if s.ch == b`=` {
					s.next()
					tok = .ge
				} else {
					tok = .gt
				}
			}
			`<` => {
				s.next()
				if s.ch == b`=` {
					s.next()
					tok = .le
				} else {
					tok = .lt
				}
			}
			`+` => {
				tok = .plus
				s.next()
			}
			`-` => {
				tok = .minus
				s.next()
			}
			`*` => {
				tok = .star
				s.next()
			}
			`/` => {
				tok = .slash
				s.next()
			}
			`$` => {
				s.next()
				ident := s.scan_ident()
				tok = .variable
				lit = ident
			}
			`}` => {
				s.next()
				if s.ch == b`}` {
					s.next()
					tok = .close_brace
					lit = '}}'
					s.inside_text = true
				}
			}
		}

		if ch == `'` || ch == `"` {
			lit = s.scan_string(ch)
			tok = .string
		}

		if is_letter(ch) {
			ident := s.scan_ident()

			tok = match ident {
				'if' => .if_
				'else' => .else_
				'for' => .for_
				'template' => .template
				'end' => .end
				else => {
					lit = ident
					token.Token.ident
				}
			}
		}

		if is_digit(ch) {
			num := s.scan_number()
			lit = num
			tok = .int
		}
	}

	pos.len = s.offset - pos.offset

	return pos, tok, lit
}

fn (s &mut Scanner) scan_raw_text() -> string {
	start_offset := s.offset
	mut offset := s.offset
	s.next()

	for ; offset < s.src_len as i32; offset++ {
		ch := s.src[offset]

		if ch == b`{` {
			// possible start of a template expression
			if offset + 1 < s.src_len && s.src[offset + 1] == b`{` {
				// start of a template expression, return the raw text
				s.inside_text = false
				break
			}
		}
	}

	s.offset = offset
	return s.src[start_offset..offset]
}

fn (s &mut Scanner) scan_ident() -> string {
	start_offset := s.offset
	mut offset := s.offset
	for ; offset < s.src_len as i32; offset++ {
		ch := s.src[offset]
		if !is_letter(ch) {
			break
		}
	}

	s.offset = offset
	return s.src[start_offset..offset]
}

fn (s &mut Scanner) scan_string(quote rune) -> string {
	start_offset := s.offset
	s.next()

	mut offset := s.offset

	for ; offset < s.src_len as i32; offset++ {
		ch := s.src[offset]
		if ch == quote {
			break
		}
	}

	s.offset = offset
	s.next()

	return s.src[start_offset..offset + 1]
}

fn (s &mut Scanner) scan_number() -> string {
	start_offset := s.offset
	mut offset := s.offset
	for ; offset < s.src_len as i32; offset++ {
		ch := s.src[offset]
		if !is_digit(ch) {
			break
		}
	}

	s.offset = offset
	return s.src[start_offset..offset]
}

fn is_letter(r rune) -> bool {
	return (r >= `a` && r <= `z`) || (r >= `A` && r <= `Z`) || r == `_`
}

fn is_digit(r rune) -> bool {
	return r >= `0` && r <= `9`
}
