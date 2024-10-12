module glob

import utf8

pub struct BadPattern {}

pub fn (b BadPattern) msg() -> string {
	return "syntax error in pattern"
}

// BAD_PATTERN indicates a pattern was malformed.
const BAD_PATTERN = BadPattern{}

// matches_safe reports whether [`name`] matches the shell [`pattern`].
//
// If the pattern is malformed, matches always returns false. To
// get an error, use [`matches`] instead.
//
// See [`matches`] for a description of the pattern syntax and example
// of patterns.
pub fn matches_safe(pattern string, name string) -> bool {
	return matches(pattern, name) or { false }
}

// matches reports whether [`name`] matches the shell [`pattern`].
// The pattern syntax is:
// ```text
// pattern:
//     { term }
// term:
//     '*'         matches any sequence of non-/ characters
//     '?'         matches any single non-/ character
//     '[' [ '^' ] { character-range } ']'
//                 character class (must be non-empty)
//     c           matches character c (c != '*', '?', '\\', '[')
//     '\\' c      matches character c
//
// character-range:
//     c           matches character c (c != '\\', '-', ']')
//     '\\' c      matches character c
//     lo '-' hi   matches character c for lo <= c <= hi
// ```
//
// matches requires pattern to match all of name, not just a substring.
//
// Example of patterns:
// ```text
// *.sp          matches any file ending in .sp
// [a-z]*        matches any file starting with a lowercase letter
// *.[a-z][a-z]  matches any file ending in a dot followed by two lowercase letters
// ?.txt         matches any file with a one-letter name and a .txt extension
// ```
pub fn matches(pattern string, name string) -> ![bool, BadPattern] {
	mut text := name
	mut pat := pattern

	next_pattern: for {
		for pat.len > 0 {
			mut star := false
			mut chunk := ''
			star, chunk, pat = scan_chunk(pat)
			if star && chunk == "" {
				// Trailing * matches rest of string unless it has a /.
				return text.index_u8(b`/`) < 0
			}
			// Look for match at current position.
			t, ok := match_chunk(chunk, text)!
			// if we're the last chunk, make sure we've exhausted the name
			// otherwise we'll give a false result even if we could still match
			// using the star
			if ok && (t.len == 0 || pat.len > 0) {
				text = t
				continue
			}
			if star {
				// Look for match skipping i+1 bytes.
				// Cannot skip /.
				for i := 0; i < text.len && text[i] != b`/`; i++ {
					t, ok = match_chunk(chunk, text[i + 1..]) or {
						return false
					}
					if ok {
						// if we're the last chunk, make sure we exhausted the name
						if pat.len == 0 && t.len > 0 {
							continue
						}
						text = t
						continue next_pattern
					}
				}
			}
			// Before returning false with no error,
			// check that the remainder of the pattern is syntactically valid.
			for pat.len > 0 {
				_, chunk, pat = scan_chunk(pat)
				match_chunk(chunk, "") or {
					return false
				}
			}
			return false
		}

		return text.len == 0
	}
}

// scan_chunk gets the next segment of pattern, which is a non-star string
// possibly preceded by a star.
fn scan_chunk(pat string) -> (bool, string, string) {
	mut pattern := pat
	mut star := false
	for pattern.len > 0 && pattern[0] == b`*` {
		pattern = pattern[1..]
		star = true
	}
	mut inrange := false
	mut i := 0
	scan: for ; i < pattern.len; i++ {
		match pattern[i] {
			b`\\` => {
				// error check handled in match_chunk: bad pattern.
				if i + 1 < pattern.len {
					i++
				}
			}
			b`[` => {
				inrange = true
			}
			b`]` => {
				inrange = false
			}
			b`*` => {
				if !inrange {
					break scan
				}
			}
		}
	}
	return star, pattern[..i], pattern[i..]
}

// match_chunk checks whether chunk matches the beginning of s.
// If so, it returns the remainder of s (after the match).
// Chunk is all single-character operators: literals, char classes, and ?.
fn match_chunk(ch string, str string) -> ![(string, bool), BadPattern] {
	mut s := str
	// failed records whether the match has failed.
	// After the match fails, the loop continues on processing chunk,
	// checking that the pattern is well-formed but no longer reading s.
	mut failed := false
	mut chunk := ch
	for chunk.len > 0 {
		if !failed && s.len == 0 {
			failed = true
		}
		match chunk[0] {
			b`[` => {
				// character class
				mut r := 0 as rune
				if !failed {
					mut n := 0
					r, n = utf8.decode_rune_in_string(s)
					s = s[n..]
				}
				chunk = chunk[1..]
				// possibly negated
				mut negated := false
				if chunk.len > 0 && chunk[0] == b`^` {
					negated = true
					chunk = chunk[1..]
				}
				// parse all ranges
				mut matched := false
				mut nrange := 0
				for {
					if chunk.len > 0 && chunk[0] == b`]` && nrange > 0 {
						chunk = chunk[1..]
						break
					}
					mut lo := 0 as rune
					mut hi := 0 as rune

					lo, chunk = get_esc(chunk) or {
						return "", false
					}

					hi = lo
					if chunk[0] == b`-` {
						hi, chunk = get_esc(chunk[1..]) or {
							return "", false
						}
					}
					if lo <= r && r <= hi {
						matched = true
					}
					nrange++
				}

				if matched == negated {
					failed = true
				}
			}
			b`?` => {
				if !failed {
					if s[0] == b`/` {
						failed = true
					}
					r, n := utf8.decode_rune_in_string(s)
					s = s[n..]
				}
				chunk = chunk[1..]
			}
			b`\\` => {
				chunk = chunk[1..]
				if chunk.len == 0 {
					return error(BAD_PATTERN)
				}
				if !failed {
					if chunk[0] != s[0] {
						failed = true
					}
					s = s[1..]
				}
				chunk = chunk[1..]
			}
			else => {
				if !failed {
					if chunk[0] != s[0] {
						failed = true
					}
					s = s[1..]
				}
				chunk = chunk[1..]
			}
		}
	}
	if failed {
		return "", false
	}
	return s, true
}

// get_esc gets a possibly-escaped character from chunk, for a character class.
fn get_esc(ch string) -> ![(rune, string), BadPattern] {
	mut chunk := ch
	if chunk.len == 0 || chunk[0] == b`-` || chunk[0] == b`]` {
		return error(BAD_PATTERN)
	}
	if chunk[0] == b`\\` {
		chunk = chunk[1..]
		if chunk.len == 0 {
			return error(BAD_PATTERN)
		}
	}
	r, n := utf8.decode_rune_in_string(chunk)
	if r == utf8.RUNE_ERROR && n == 1 {
		return error(BAD_PATTERN)
	}
	nchunk := chunk[n..]
	if nchunk.len == 0 {
		return error(BAD_PATTERN)
	}
	return r, nchunk
}
