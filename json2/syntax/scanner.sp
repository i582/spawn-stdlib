module syntax

import intrinsics

const EOF = 0

struct Scanner {
	src     string
	src_len usize

	tok Token = .illegal

	ch     rune
	offset usize

	errors []ParseError
}

fn Scanner.new(src string) -> Scanner {
	return Scanner{
		src: src
		src_len: src.len
		ch: src[0]
	}
}

fn (s &mut Scanner) next() {
	if s.offset >= s.src.len {
		s.tok = .eof
		s.ch = EOF
		return
	}

	s.offset++
	s.ch = s.src.fast_at(s.offset)
}

fn (s &mut Scanner) skip_bom() {
	if s.offset != 0 {
		return
	}

	if s.src.starts_with("\xEF\xBB\xBF") {
		s.offset += 3
		s.ch = s.src[s.offset]
	}
}

fn (s &mut Scanner) next_fast() {
	s.offset++
	s.ch = s.src.fast_at(s.offset)
}

fn (s &mut Scanner) report(off usize, msg string) {
	s.errors.push(ParseError{ off: off, msg: msg })
}

fn (s &mut Scanner) skip_whitespaces() {
	// since any values bellow 32 except whitespaces is invalid, assume that
	// all characters <= 32 is whitespace
	for s.offset < s.src_len && s.ch <= 32 {
		s.offset++
		s.ch = s.src.fast_at(s.offset)
	}
}

fn (s &mut Scanner) starts_with(val string, index usize) -> bool {
	return s.src[s.offset + index..].starts_with(val)
}

fn (s &mut Scanner) scan() -> (usize, Token, string) {
	s.skip_whitespaces()

	if s.ch == b`t` && s.starts_with('rue', 1) {
		s.offset += 4
		s.ch = s.src.fast_at(s.offset)
		return s.offset, .true_, ''
	}
	if s.ch == b`f` && s.starts_with('alse', 1) {
		s.offset += 5
		s.ch = s.src.fast_at(s.offset)
		return s.offset, .false_, ''
	}
	if s.ch == b`n` && s.starts_with('ull', 1) {
		s.offset += 4
		s.ch = s.src.fast_at(s.offset)
		return s.offset, .null, ''
	}

	ch := s.ch
	offset := s.offset

	match {
		ch < 256 && NUMBER_LOOKUP_TABLE[ch] => {
			tok, lit := s.scan_number()
			return offset, tok, lit
		}
		ch == `"` => {
			lit, tok := s.scan_string()
			return offset, tok, lit
		}
	}

	s.next()

	tok := match ch {
		EOF => .eof
		`{` => .lbrace
		`}` => .rbrace
		`[` => .lbrack
		`]` => .rbrack
		`,` => .comma
		`:` => .colon
		else => {
			s.report(s.offset, "illegal character ${ch}")
			return offset, .illegal, ''
		}
	}

	return offset, tok, ''
}

fn (s &mut Scanner) scan_number() -> (Token, string) {
	offset := s.offset

	if s.ch == b`-` {
		s.next()
	}

	mut invalid := -1

	if s.ch != `.` {
		s.scan_digits(&mut invalid)
	}

	if s.ch == `.` {
		s.next()
		s.scan_digits(&mut invalid)
	}

	lower_ch := to_lower(s.ch)
	if lower_ch == `e` {
		s.next()
		if s.ch == `-` {
			s.next()
		}
		s.scan_digits(&mut invalid)
	}

	lit := s.src[offset..s.offset]
	return .number, lit
}

fn (s &mut Scanner) scan_digits(invalid &mut i32) {
	max := (`0` as i32 + 10) as rune
	for NUMBER_LOOKUP_TABLE[s.ch] {
		if s.ch >= max && *invalid < 0 {
			*invalid = (s.offset + 1) as i32
		}
		s.next()
	}
}

fn (s &mut Scanner) scan_string() -> (string, Token) {
	start_offset := s.offset
	s.next_fast()

	mut i := s.offset
	for ; i < s.src_len; i++ {
		ch := s.src[i]

		if ch == b`\\` {
			next := s.src[i + 1]
			match next {
				// simple escapes
				b`"`, b`b`, b`f`, b`n`, b`r`, b`t`, b`\\`, b`/` => {
					i++
				}
				b`u` => {
					i += s.scan_unicode_escape(i + 2) + 1
				}
			}
			continue
		}

		if ch == b`"` {
			break
		}

		if intrinsics.unlikely(ch == EOF || ch == `\n`) {
			s.report(i, "unterminated string")
			i--
			break
		}
	}

	if i == s.src_len {
		s.report(i, "unterminated string")
		i--
	}

	s.offset = i + 1
	s.ch = s.src.fast_at(s.offset)
	return s.src[start_offset..s.offset], .string
}

fn (s &mut Scanner) scan_unicode_escape(index usize) -> usize {
	if index + 4 >= s.src_len {
		s.report(index - 1, 'Unicode escape sequence not terminated')
		return 0
	}

	nums := s.src[index..index + 4]

	mut res := 0 as u32
	for idx, ch in nums {
		if !is_hex(ch) {
			s.report(index + idx + 1, 'unexpected character ${rune_dbg(ch)} in Unicode escape sequence')
			return idx
		}
		if ch == EOF {
			s.report(index + idx + 1, 'escape sequence not terminated')
		}

		val := digit_val(ch) as u32
		if val >= 16 {
			return idx
		}
		res = res * 16 + val
	}

	if 0xD800 <= res && res < 0xE000 {
		s.report(index, 'escape sequence is invalid Unicode code point: 0x${res.hex()} is surrogate code point')
		return 4
	}

	return 4
}

fn digit_val(ch rune) -> i32 {
	return match {
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

fn to_lower(r rune) -> rune {
	return (`a` - `A`) | r
}

fn is_digit(r rune) -> bool {
	return r >= `0` && r <= `9`
}

fn is_hex(r rune) -> bool {
	return (r >= `0` && r <= `9`) || (r >= `a` && r <= `f`) || (r >= `A` && r <= `F`)
}

const NUMBER_LOOKUP_TABLE = build_lookup_tables()

pub fn build_lookup_tables() -> [256]bool {
	mut res := [256]bool{}
	for i := 0; i < 256; i++ {
		res[i] = is_digit(i as rune) || i as rune == b`-`
	}
	return res
}
