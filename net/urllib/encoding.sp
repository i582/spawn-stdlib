module urllib

import strings

pub enum Encoding {
	path
	path_segment
	host
	zone
	user_password
	query_component
	fragment
}

pub fn query_escape(s string) -> string {
	return escape(s, .query_component)
}

pub fn path_escape(s string) -> string {
	return escape(s, .path_segment)
}

pub fn query_unescape(s string) -> !string {
	return unescape(s, .query_component)
}

pub fn path_unescape(s string) -> !string {
	return unescape(s, .path_segment)
}

const (
	ALPHANUM_TABLE           = init_alphanum_table()
	ALLOWED_HOST_TABLE       = init_allowed_host_table()
	RESERVED_CHARACTER_TABLE = init_reserved_character_table()

	UPPER_HEX = "0123456789ABCDEF"
)

fn init_alphanum_table() -> [256]bool {
	mut table := [256]bool{}
	for c in 0 .. 256 {
		table[c] = (c as u8).is_alphanum()
	}
	return table
}

fn init_allowed_host_table() -> [256]bool {
	mut table := [256]bool{}
	for c in 0 .. 256 {
		table[c] = c in [b`!`, b`$`, b`&`, b`'`, b`(`, b`)`, b`*`, b`+`, b`,`, b`;`, b`=`, b`[`, b`]`, b`<`, b`>`, b`"`]
	}
	return table
}

fn init_reserved_character_table() -> [256]bool {
	mut table := [256]bool{}
	for c in 0 .. 256 {
		table[c] = c in [b`$`, b`&`, b`+`, b`,`, b`/`, b`:`, b`;`, b`=`, b`?`, b`@`]
	}
	return table
}

fn should_escape(c u8, mode Encoding) -> bool {
	// §2.3 Unreserved characters (alphanum)
	if ALPHANUM_TABLE[c] {
		return false
	}

	if mode == .host || mode == .zone {
		// §3.2.2 Host allows
		//    sub-delims = "!" / "$" / "&" / "'" / "(" / ")" / "*" / "+" / "," / ";" / "="
		// as part of reg-name.
		// We add : because we include :port as part of host.
		// We add [ ] because we include [ipv6]:port as part of host.
		// We add < > because they're the only characters left that
		// we could possibly allow, and Parse will reject them if we
		// escape them (because hosts can't use %-encoding for
		// ASCII bytes).
		// if c in [b`!`, b`$`, b`&`, b`'`, b`(`, b`)`, b`*`, b`+`, b`,`, b`;`, b`=`, b`[`, b`]`, b`<`, b`>`, b`"`] {
		if ALLOWED_HOST_TABLE[c] {
			return false
		}
	}

	// §2.3 Unreserved characters (mark)
	if c in [b`-`, b`_`, b`.`, b`~`] {
		return false
	}

	// §2.2 Reserved characters (reserved)
	// if c in [b`$`, b`&`, b`+`, b`,`, b`/`, b`:`, b`;`, b`=`, b`?`, b`@`] {
	if RESERVED_CHARACTER_TABLE[c] {
		return match mode {
			.path => c == b`?`
			.path_segment => c == b`/` || c == b`;` || c == b`,` || c == b`?`
			.user_password => c == b`@` || c == b`/` || c == b`?` || c == b`:`
			.query_component => true
			.fragment => false
			else => true
		}
	}

	if mode == .fragment {
		// RFC 3986 §2.2 allows not escaping sub-delims. A subset of sub-delims are
		// included in reserved from RFC 2396 §2.2. The remaining sub-delims do not
		// need to be escaped. To minimize potential breakage, we apply two restrictions:
		// (1) we always escape sub-delims outside of the fragment, and (2) we always
		// escape single quote to avoid breaking callers that had previously assumed that
		// single quotes would be escaped. See issue #19917.
		if c in [b`!`, b`(`, b`)`, b`*`] {
			return false
		}
	}

	// Everything else must be escaped.
	return true
}

fn escape(s string, mode Encoding) -> string {
	mut space_count := 0
	mut hex_count := 0

	for ch in s {
		if should_escape(ch, mode) {
			if ch == b` ` && mode == .query_component {
				space_count++
			} else {
				hex_count++
			}
		}
	}

	if space_count == 0 && hex_count == 0 {
		return s
	}

	required := s.len + 2 * hex_count
	mut sb := strings.new_builder(required)

	if hex_count == 0 {
		sb.write_str(s)
		for i in 0 .. s.len {
			if s[i] == b` ` {
				sb[i] = b`+`
			}
		}
		return sb.str_view()
	}

	sb.fill_zeroes()
	mut j := 0
	for ch in s {
		if ch == b` ` && mode == .query_component {
			sb[j] = b`+`
			j++
		} else if should_escape(ch, mode) {
			sb[j] = b`%`
			sb[j + 1] = UPPER_HEX[ch >> 4]
			sb[j + 2] = UPPER_HEX[ch & 15]
			j += 3
		} else {
			sb[j] = ch
			j++
		}
	}

	return sb.str_view()
}

fn unescape(s string, mode Encoding) -> !string {
	mut n := 0
	mut has_plus := false

	for i := 0; i < s.len; {
		ch := s[i]
		if ch == b`%` {
			n++
			if i + 2 >= s.len || !is_hex(s[i + 1]) || !is_hex(s[i + 2]) {
				mut s1 := s[i..]
				if s1.len > 3 {
					s1 = s1[..3]
				}
				return msg_err("invalid URL escape " + s1)
			}
			// Per https://tools.ietf.org/html/rfc3986#page-21
			// in the host component %-encoding can only be used
			// for non-ASCII bytes.
			// But https://tools.ietf.org/html/rfc6874#section-2
			// introduces %25 being allowed to escape a percent sign
			// in IPv6 scoped-address literals. Yay.
			if mode == .host && unhex(s[i + 1]) < 8 && s[i..i + 3] == '%25' {
				return msg_err("invalid URL escape " + s[i..i + 3])
			}
			if mode == .zone {
				// RFC 6874 says basically "anything goes" for zone identifiers
				// and that even non-ASCII can be redundantly escaped,
				// but it seems prudent to restrict %-escaped bytes here to those
				// that are valid host name bytes in their unescaped form.
				// That is, you can use escaping in the zone identifier but not
				// to introduce bytes you couldn't just write directly.
				// But Windows puts spaces here! Yay.
				v := unhex(s[i + 1]) << 4 | unhex(s[i + 2])
				if s[i..i + 3] != "%25" && v != b` ` && should_escape(v, .host) {
					return msg_err("invalid URL escape " + s[i..i + 3])
				}
			}
			i += 3
		} else if ch == b`+` {
			has_plus = mode == .query_component
			i++
		} else {
			if (mode == .host || mode == .zone) && ch < 0x80 && should_escape(ch, mode) {
				return msg_err("invalid URL escape " + s[i - 1..i + 1])
			}
			i++
		}
	}

	if n == 0 && !has_plus {
		return s
	}

	mut sb := strings.new_builder(s.len - 2 * n)

	for i := 0; i < s.len; i++ {
		ch := s[i]
		if ch == b`%` {
			sb.write_u8(unhex(s[i + 1]) << 4 | unhex(s[i + 2]))
			i += 2
		} else if ch == b`+` {
			if mode == .query_component {
				sb.write_u8(b` `)
			} else {
				sb.write_u8(b`+`)
			}
		} else {
			sb.write_u8(ch)
		}
	}

	return sb.str_view()
}

fn valid_encoded(s string, mode Encoding) -> bool {
	for ch in s {
		// RFC 3986, Appendix A.
		// pchar = unreserved / pct-encoded / sub-delims / ":" / "@".
		// shouldEscape is not quite compliant with the RFC,
		// so we check the sub-delims ourselves and let
		// shouldEscape handle the others.
		if ch in [b`!`, b`$`, b`&`, b`'`, b`(`, b`)`, b`*`, b`+`, b`,`, b`;`, b`=`, b`:`] {
			// ok
			continue
		}
		if ch == b`[` || ch == b`]` {
			// ok - not specified in RFC 3986 but left alone by modern browsers
			continue
		}
		if ch == b`%` {
			// ok - percent encoded, will decode
			continue
		}

		if should_escape(ch, mode) {
			return false
		}
	}
	return true
}

fn is_hex(c u8) -> bool {
	return c.is_hex_digit()
}

fn unhex(c u8) -> u8 {
	if b`0` <= c && c <= b`9` {
		return c - b`0`
	}
	if b`a` <= c && c <= b`f` {
		return c - b`a` + 10
	}
	if b`A` <= c && c <= b`F` {
		return c - b`A` + 10
	}
	return 0
}
