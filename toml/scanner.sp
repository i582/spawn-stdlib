module toml

import toml.token

const EOF = 0

pub struct Scanner {
	src     string
	src_len usize

	tok token.Token = .illegal

	ch     rune
	offset usize

	report_cb ErrorCallback
}

pub fn Scanner.new(src string, report_cb ErrorCallback) -> &mut Scanner {
	return &mut Scanner{
		src: src
		src_len: src.len
		ch: src[0]
		report_cb: report_cb
	}
}

pub fn (s &mut Scanner) next() {
	if s.offset >= s.src.len {
		s.tok = .eof
		s.ch = EOF
		return
	}

	s.offset++
	s.ch = s.src[s.offset]
}

pub fn (s &mut Scanner) lookahead(count usize) -> rune {
	offset := s.offset + count
	if offset >= s.src.len {
		return EOF
	}

	return s.src[offset]
}

fn (s &mut Scanner) skip_whitespaces() {
	for s.offset < s.src_len {
		ch := s.src[s.offset]
		if ch == b` ` || ch == b`\t` || ch == b`\r` {
			s.next()
			continue
		}

		s.ch = ch
		break
	}
}

pub fn (s &mut Scanner) scan() -> (token.Pos, token.Token, string) {
	s.ch = s.src[s.offset]
	mut ch := s.ch

	if ch == b` ` || ch == b`\t` || ch == b`\r` {
		start := s.offset
		for s.offset < s.src_len && s.ch != EOF {
			cur_ch := s.src[s.offset]
			if cur_ch == b` ` || cur_ch == b`\t` || cur_ch == b`\r` {
				s.next()
				continue
			}

			break
		}

		lit := s.src[start..s.offset]
		return token.Pos{ offset: start, len: s.offset - start }, .whitespace, lit
	}

	mut lit := ''
	mut tok := token.Token.illegal
	mut pos := token.Pos{ offset: s.offset }

	match {
		is_key_symbol(ch) && !is_digit(ch) && ch != b`-` => {
			ident := s.scan_ident()

			tok = match ident {
				'true' => .true_
				'false' => .false_
				'inf', 'nan' => {
					lit = ident
					token.Token.float
				}
				else => {
					lit = ident
					token.Token.ident
				}
			}
		}
		is_digit(ch) || ch == b`+` || ch == b`-` => {
			tok, lit = s.scan_number()
		}
		ch == `'` || ch == `"` => {
			lit, tok = s.scan_string(ch)
		}
		else => {
			s.next()

			match ch {
				EOF => {
					tok = .eof
				}
				`\n` => {
					return pos, .newline, '\n'
				}
				`(` => {
					tok = .lparen
				}
				`)` => {
					tok = .rparen
				}
				`{` => {
					tok = .lbrace
				}
				`}` => {
					tok = .rbrace
				}
				`[` => {
					tok = if s.ch == b`[` {
						s.next()
						token.Token.double_lbrack
					} else {
						token.Token.lbrack
					}
				}
				`]` => {
					tok = if s.ch == b`]` {
						s.next()
						token.Token.double_rbrack
					} else {
						token.Token.rbrack
					}
				}
				`.` => {
					tok = .dot
				}
				`,` => {
					tok = .comma
				}
				`:` => {
					tok = .colon
				}
				`=` => {
					tok = .assign
				}
				`#` => {
					lit = s.scan_comment()
					tok = .comment
				}
				else => s.report_cb(ParseError.new(token.Pos{ offset: s.offset, len: 1 }, "illegal character ${ch}"))
			}
		}
	}

	pos.len = s.offset - pos.offset
	return pos, tok, lit
}

pub fn (s &mut Scanner) scan_ident() -> string {
	start_offset := s.offset
	mut offset := s.offset
	for ; offset < s.src_len as i32; offset++ {
		ch := s.src[offset]
		if !is_key_symbol(ch) {
			break
		}
	}

	s.offset = offset
	return s.src[start_offset..offset]
}

fn (s &mut Scanner) scan_number() -> (token.Token, string) {
	mut offset := s.offset

	if s.ch == b`+` || s.ch == b`-` {
		s.next()
	}

	if s.lookahead(0) == b`n` && s.lookahead(1) == b`a` && s.lookahead(2) == b`n` {
		s.next()
		s.next()
		s.next()
		s.next()
		return .float, "nan"
	}

	if s.lookahead(0) == b`i` && s.lookahead(1) == b`n` && s.lookahead(2) == b`f` {
		s.next()
		s.next()
		s.next()
		s.next()
		return .float, "inf"
	}

	mut tok := token.Token.integer
	mut base := 10
	mut prefix := 0 as rune
	mut invalid := -1
	mut digsep := 0

	if s.ch != `.` {
		if s.ch == `0` {
			s.next()
			base, prefix = match to_lower(s.ch) {
				`b` => {
					s.next()
					2, `b`
				}
				`o` => {
					s.next()
					8, `o`
				}
				`x` => {
					s.next()
					16, `x`
				}
				else => {
					digsep = digsep | 1
					10, `0`
				}
			}
		}

		digsep = digsep | s.scan_digits(base, &mut invalid)
	}

	if s.ch == `.` {
		tok = .float
		if prefix == `o` || prefix == `b` {
			s.report_cb(ParseError.new(token.Pos{ offset: offset, len: s.offset - offset }, 'invalid radix point in ${number_name(prefix)}'))
		}

		s.next()
		digsep = digsep | s.scan_digits(base, &mut invalid)
	}

	if digsep & 1 == 0 {
		prefix_val := s.src[offset..offset + 2]
		s.report_cb(ParseError.new(token.Pos{ offset: offset, len: 2 }, '${number_name(prefix)} has no digits after `${prefix_val}`'))
	}

	lower_ch := to_lower(s.ch)
	if lower_ch == `e` || lower_ch == `p` {
		if lower_ch == `e` && prefix != 0 && prefix != `0` {
			s.report_cb(ParseError.new(token.Pos{ offset: offset, len: 1 }, 'exponent requires decimal mantissa, but ${number_name(prefix)} mantissa found'))
		} else if lower_ch == `p` && prefix != `x` {
			s.report_cb(ParseError.new(token.Pos{ offset: offset, len: 1 }, 'exponent requires hexadecimal mantissa, but ${number_name(prefix)} mantissa found'))
		}

		s.next()
		tok = .float
		if s.ch == `+` || s.ch == `-` {
			s.next()
		}
		ds := s.scan_digits(10, &mut invalid)
		digsep = digsep | ds
		if ds & 1 == 0 {
			s.report_cb(ParseError.new(token.Pos{ offset: offset, len: s.offset - offset }, 'exponent has no digits'))
		}
	} else if prefix == `x` && tok == .float {
		s.report_cb(ParseError.new(token.Pos{ offset: offset, len: s.offset - offset }, 'hexadecimal mantissa requires a `p` exponent'))
	}

	if tok == .integer && invalid > 0 {
		digit := s.src[invalid - 1].ascii_str()
		s.report_cb(ParseError.new(token.Pos{ offset: invalid - 1, len: 1 }, 'invalid digit `${digit}` in ${number_name(prefix)} (valid digits: ${number_valid_digits(prefix)})'))
	}

	lit := s.src[offset..s.offset]

	if digsep & 2 != 0 {
		invalid_index := find_invalid_seq(lit)
		if invalid_index == s.offset - 1 {
			// 100_
			//    ^ invalid_index
			s.report_cb(ParseError.new(token.Pos{ offset: invalid_index, len: 1 }, 'invalid digit separator, `_` cannot be at the end of number'))
		} else if invalid_index >= 0 {
			s.report_cb(ParseError.new(token.Pos{ offset: invalid_index, len: 1 }, 'invalid digit separator, `_` must separate successive digits'))
		}
	}

	return tok, lit
}

fn (s &mut Scanner) scan_digits(base i32, invalid &mut i32) -> i32 {
	mut digsep := 0

	if base <= 10 {
		max := ((`0` as i32) + base) as rune
		for is_decimal(s.ch) || s.ch == `_` {
			mut sep := 1
			if s.ch == `_` {
				sep = 2
			} else if s.ch >= max && *invalid < 0 {
				*invalid = (s.offset + 1) as i32
			}
			digsep = digsep | sep
			s.next()
		}
	} else {
		for is_hex(s.ch) || s.ch == `_` {
			mut sep := 1 + (s.ch == `_`) as i32
			digsep = digsep | sep
			s.next()
		}
	}

	return digsep
}

pub fn (s &mut Scanner) scan_string(quote rune) -> (string, token.Token) {
	triple := s.lookahead(1) == quote && s.lookahead(2) == quote
	start_offset := s.offset
	s.next()

	if triple {
		s.next()
		s.next()
	}

	mut was_continuation := false

	for {
		offset := s.offset
		ch := s.ch

		if ch == b`\\` && quote != b`'` {
			if s.lookahead(1) == b`\n` {
				// line continuation
				s.next()
				s.next()

				// TODO:
				was_continuation = true
				continue
			}
			s.next()
			s.scan_escape(quote)
			continue
		}

		s.next()

		if !triple && ch == quote {
			break
		}

		if triple && ch == quote {
			// if next two characters are also quotes, then it can be end of string
			if offset + 2 < s.src_len && s.src[offset + 1] == quote && s.src[offset + 2] == quote {
				if offset + 3 < s.src_len && s.src[offset + 3] == quote {
					// after this two quotes there is another quote, so this three quotes are not end of string
					// For example
					// """ hello world """"
					//                    ^ ant we this one after tree
					//                 ^^^ we found this tree quotes
					// so first tree quotes are not end of string
					// threat first quote as normal character
					continue
				}

				s.offset += 1
				s.next()
				break
			}
		}

		if ch == EOF {
			s.report_cb(ParseError.new(token.Pos{ offset: s.offset, len: 1 }, "unterminated string"))
			break
		}

		if !triple && ch == `\n` {
			s.report_cb(ParseError.new(token.Pos{ offset: s.offset, len: 1 }, "unterminated string"))
			break
		}
	}

	tok := if triple { token.Token.triple_string } else { token.Token.string }
	mut end := s.offset
	if end > s.src_len {
		s.report_cb(ParseError.new(token.Pos{ offset: s.offset, len: 1 }, "unterminated string"))
	}

	str := s.src[start_offset..end]
	return str, tok
}

fn (s &mut Scanner) scan_escape(quote rune) -> bool {
	mut n := 0
	mut base := 0 as u32
	mut max := 0 as u32
	mut is_unicode := false
	match s.ch {
		quote, `a`, `b`, `f`, `n`, `r`, `t`, `v`, `\\` => {
			s.next()
			return true
		}
		`0`, `1`, `2`, `3`, `4`, `5`, `6`, `7` => {
			n = 3
			base = 8
			max = 255
		}
		`u` => {
			s.next()
			n = 4
			base = 16
			max = 0x10FFFF
			is_unicode = true
		}
		`U` => {
			s.next()
			n = 8
			base = 16
			max = 0x10FFFF
			is_unicode = true
		}
		else => {
			msg := if s.ch == EOF {
				'escape sequence not terminated'
			} else {
				'unknown escape sequence \\${s.ch}'
			}

			s.report_cb(ParseError.new(token.Pos{ offset: s.offset, len: 1 }, msg))
			return false
		}
	}

	mut res := 0 as u32
	for n > 0 {
		val := digit_val(s.ch) as u32
		if val >= base {
			msg, off := if s.ch == EOF {
				'escape sequence not terminated', s.offset
			} else {
				'illegal character ${rune_dbg(s.ch)} in escape sequence', s.offset
			}

			s.report_cb(ParseError.new(token.Pos{ offset: off, len: 1 }, msg))
			return false
		}

		res = res * base + val
		s.next()
		n--
	}

	if res > max && base == 8 {
		// `\777`
		//  ^^^^ pos
		msg := 'escape sequence is invalid octal number, ${res} > 255'

		s.report_cb(ParseError.new(token.Pos{ offset: s.offset, len: 1 }, msg))
		return false
	}

	if res > max || (0xD800 <= res && res < 0xE000) {
		// `\Uffffffff`
		//  ^^^^^^^^^^ pos
		descr := if res > max {
			'0x${res.hex()} too large'
		} else {
			'0x${res.hex()} is surrogate code point'
		}
		msg := 'escape sequence is invalid Unicode code point: ${descr}'

		s.report_cb(ParseError.new(token.Pos{ offset: s.offset, len: 1 }, msg))
		return false
	}

	if res == 0 {
		// '\0', '\000', '\x00', '\u0000' or '\U00000000'
		//  ^^ pos
		msg := 'string literal cannot contain null character'
		s.report_cb(ParseError.new(token.Pos{ offset: s.offset, len: 1 }, msg))
		return false
	}

	return true
}

pub fn (s &mut Scanner) scan_comment() -> string {
	start_offset := s.offset
	mut offset := s.offset

	for ; offset < s.src_len as i32; offset += 1 {
		ch := s.src[offset]
		if ch == `\n` {
			break
		}
	}

	s.offset = offset
	return s.src[start_offset..offset]
}

fn find_invalid_seq(x string) -> i32 {
	mut x1 := ` ` // prefix char, we only care if it's 'x'
	mut d := `.` // digit, one of '_', '0' (a digit), or '.' (anything else)
	mut i := 0 as usize

	// a prefix counts as a digit
	if x.len >= 2 && x[0] == b`0` {
		x1 = to_lower(x[1] as rune)
		if x1 == `x` || x1 == `o` || x1 == `b` {
			d = `0`
			i = 2
		}
	}

	for ; i < x.len; i++ {
		p := d // previous digit
		d = x[i] as rune
		match true {
			d == `_` => {
				if p != `0` {
					return i as i32
				}
			}
			is_decimal(d) || (x1 == `x` && is_hex(d)) => {
				d = `0`
			}
			else => {
				if p == `_` {
					return i as i32 - 1
				}
				d = `.`
			}
		}
	}

	if d == `_` {
		return x.len as i32 - 1
	}

	return -1
}

fn digit_val(ch rune) -> i32 {
	return match true {
		`0` <= ch && ch <= `9` => (ch - `0`) as i32
		`a` <= to_lower(ch) && to_lower(ch) <= `f` => (to_lower(ch) - `a` + 10) as i32
		else => 16
	}
}

fn rune_dbg(ch rune) -> string {
	// print '`' for backtick, `a` for other characters
	is_backtick := ch == `\``
	quote := if is_backtick { "'" } else { '`' }
	hex := (ch as u32).hex().str()
	return 'U+' + hex.pad_start(4, `0`) + ' ' + quote + ch.str() + quote
}

fn number_valid_digits(prefix rune) -> string {
	return match prefix {
		`b` => '0 or 1'
		`o` => '0 to 7'
		`x` => '0 to 9,`a` to `f`, `A` to `F`'
		else => '0 to 9'
	}
}

fn number_name(prefix rune) -> string {
	return match prefix {
		`b` => 'binary literal'
		`o` => 'octal literal'
		`x` => 'hexadecimal literal'
		else => 'decimal literal'
	}
}

fn radix_name(prefix rune) -> string {
	return match prefix {
		`b` => 'binary'
		`o` => 'octal'
		`x` => 'hexadecimal'
		else => 'decimal'
	}
}

fn to_lower(r rune) -> rune {
	return (`a` - `A`) | r
}

fn is_decimal(ch rune) -> bool {
	return ch >= `0` && ch <= `9`
}

fn is_hex(ch rune) -> bool {
	return (ch >= `0` && ch <= `9`) || (ch >= `a` && ch <= `f`) || (ch >= `A` && ch <= `F`)
}

fn is_key_symbol(r rune) -> bool {
	return is_letter(r) || is_digit(r) || r == `-` || r == `_`
}

fn is_letter(r rune) -> bool {
	return (r >= `a` && r <= `z`) || (r >= `A` && r <= `Z`)
}

fn is_digit(r rune) -> bool {
	return r >= `0` && r <= `9`
}
