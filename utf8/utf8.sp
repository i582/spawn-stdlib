module utf8

pub const (
	RUNE_ERROR = 0xFFFD
	RUNE_SELF  = 0x80

	RUNE1_MAX = 1 << 7 - 1
	RUNE2_MAX = 1 << 11 - 1
	RUNE3_MAX = 1 << 16 - 1

	UTF8_MAX = 4
)

pub const (
	SURROGATE_MIN = 0xD800
	SURROGATE_MAX = 0xDFFF
)

const (
	MASKX = 0b00111111
	MASK2 = 0b00011111
	MASK3 = 0b00001111
	MASK4 = 0b00000111
)

// The default lowest and highest continuation byte.
const (
	LOCB = 0b10000000
	HICB = 0b10111111
)

// These names of these constants are chosen to give nice alignment in the
// table below. The first nibble is an index into acceptRanges or F for
// special one-byte cases. The second nibble is the Rune length or the
// Status for the special one-byte case.
const (
	XX = 0xF1 // invalid: size 1
	AC = 0xF0 // ASCII: size 1
	S1 = 0x02 // accept 0, size 2
	S2 = 0x13 // accept 1, size 3
	S3 = 0x03 // accept 0, size 3
	S4 = 0x23 // accept 2, size 3
	S5 = 0x34 // accept 3, size 4
	S6 = 0x04 // accept 0, size 4
	S7 = 0x44 // accept 4, size 4
)

// FIRST is information about the first byte in a UTF-8 sequence.
const FIRST = [
	//   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
	AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, // 0x00-0x0F
	AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, // 0x10-0x1F
	AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, // 0x20-0x2F
	AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, // 0x30-0x3F
	AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, // 0x40-0x4F
	AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, // 0x50-0x5F
	AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, // 0x60-0x6F
	AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, AC, // 0x70-0x7F
	//   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
	XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, // 0x80-0x8F
	XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, // 0x90-0x9F
	XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, // 0xA0-0xAF
	XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, // 0xB0-0xBF
	XX, XX, S1, S1, S1, S1, S1, S1, S1, S1, S1, S1, S1, S1, S1, S1, // 0xC0-0xCF
	S1, S1, S1, S1, S1, S1, S1, S1, S1, S1, S1, S1, S1, S1, S1, S1, // 0xD0-0xDF
	S2, S3, S3, S3, S3, S3, S3, S3, S3, S3, S3, S3, S3, S4, S3, S3, // 0xE0-0xEF
	S5, S6, S6, S6, S7, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, // 0xF0-0xFF
] as [256]u8

// AcceptRange gives the range of valid values for the second byte in a UTF-8
// sequence.
struct AcceptRange {
	lo u8 // lowest value for second byte.
	hi u8 // highest value for second byte.
}

// ACCEPT_RANGES has size 16 to avoid bounds checks in the code that uses it.
const ACCEPT_RANGES = [
	AcceptRange{ lo: LOCB, hi: HICB },
	AcceptRange{ lo: 0xA0, hi: HICB },
	AcceptRange{ lo: LOCB, hi: 0x9F },
	AcceptRange{ lo: 0x90, hi: HICB },
	AcceptRange{ lo: LOCB, hi: 0x8F },
	AcceptRange{},
	AcceptRange{},
	AcceptRange{},
	AcceptRange{},
	AcceptRange{},
	AcceptRange{},
	AcceptRange{},
	AcceptRange{},
	AcceptRange{},
	AcceptRange{},
	AcceptRange{},
] as [16]AcceptRange

// full_rune reports whether the bytes in [`p`] begin with a full UTF-8 encoding of a rune.
// An invalid encoding is considered a full Rune since it will convert as a width-1 error rune.
pub fn full_rune(p []u8) -> bool {
	n := p.len
	if n == 0 {
		return false
	}
	x := FIRST[p[0]]
	if n >= (x & 7) as usize {
		return true // ASCII, invalid or valid.
	}
	// Must be short or invalid.
	accept := ACCEPT_RANGES[x >> 4]
	if n > 1 && (p[1] < accept.lo || accept.hi < p[1]) {
		return true
	}
	if n > 2 && (p[2] < LOCB || HICB < p[2]) {
		return true
	}
	return false
}

// encode_rune_to_string returns the UTF-8 encoding of the rune.
// Returns an empty string if the rune is not a valid value to encode in UTF-8.
pub fn encode_rune_to_string(r rune) -> string {
	mut p := []u8{len: 4}
	n := encode_rune(&mut p, r)
	if n < 0 {
		return ""
	}
	return string.view_from_c_str_len(p.data, n)
}

// encode_rune writes into p (which must be large enough) the UTF-8 encoding of the rune.
// Returns the number of bytes written.
pub fn encode_rune(p &mut []u8, r rune) -> i32 {
	if r <= RUNE1_MAX {
		p[0] = r as u8
		return 1
	}
	if r <= RUNE2_MAX {
		p[0] = (0xc0 | (r >> 6)) as u8
		p[1] = (0x80 | (r & 0x3f)) as u8
		return 2
	}
	if r > MAX_VALID_RUNE || (SURROGATE_MIN <= r && r < SURROGATE_MAX) {
		// surrogate pair
		return -1
	}
	if r <= RUNE3_MAX {
		p[0] = (0xe0 | (r >> 12)) as u8
		p[1] = (0x80 | ((r >> 6) & 0x3f)) as u8
		p[2] = (0x80 | (r & 0x3f)) as u8
		return 3
	}

	p[0] = (0xf0 | (r >> 18)) as u8
	p[1] = (0x80 | ((r >> 12) & 0x3f)) as u8
	p[2] = (0x80 | ((r >> 6) & 0x3f)) as u8
	p[3] = (0x80 | (r & 0x3f)) as u8
	return 4
}

// rune_len returns the number of bytes required to encode the rune.
// Returns -1 if the rune is not a valid value to encode in UTF-8.
//
// Example:
// ```
// assert rune_len(b`a`) == 1 // byte rune always takes 1 byte (ASCII)
// assert rune_len(`€`) == 3  // € takes 3 bytes in UTF-8
// assert rune_len(`𐍈`) == 4  // 𐍈 takes 4 bytes in UTF-8
// assert rune_len(`�`) == -1 // invalid rune
// ```
pub fn rune_len(r rune) -> i32 {
	if r <= RUNE1_MAX {
		return 1
	}
	if r <= RUNE2_MAX {
		return 2
	}
	if SURROGATE_MIN <= r && r <= SURROGATE_MAX {
		return -1 // surrogate
	}
	if r <= RUNE3_MAX {
		return 3
	}
	if r <= MAX_VALID_RUNE {
		return 4
	}

	return -1
}

// is_valid_rune reports whether r can be legally encoded as UTF-8.
// Code points that are out of range or a surrogate half are illegal.
pub fn is_valid_rune(r rune) -> bool {
	return r < SURROGATE_MIN || (SURROGATE_MAX < r && r <= MAX_VALID_RUNE)
}

// validate_string reports whether [`str`] consists entirely of valid UTF-8-encoded runes.
pub fn validate_string(str string) -> bool {
	mut s := str
	// fast path, check for and skip 8 bytes of ASCII characters per iteration
	for s.len >= 8 {
		first32 := s[0] as u32 | s[1] as u32 << 8 | s[2] as u32 << 16 | s[3] as u32 << 24
		second32 := s[4] as u32 | s[5] as u32 << 8 | s[6] as u32 << 16 | s[7] as u32 << 24
		if (first32 | second32) as u64 & 0x80808080 as u64 != 0 {
			// found a non ASCII byte
			break
		}
		s = s[8..]
	}

	n := s.len

	for i := 0; i < n; {
		si := s[i]
		if si < RUNE_SELF {
			i++
			continue
		}
		x := FIRST[si]
		if x == XX {
			return false // illegal starter byte
		}
		size := (x & 7) as i32
		if i + size > n {
			return false // short or invalid
		}
		accept := ACCEPT_RANGES[x >> 4]
		c1 := s[i + 1]
		c2 := s[i + 2]
		c3 := s[i + 3]
		if c1 < accept.lo || accept.hi < c1 {
			return false
		} else if size == 2 {
			//
		} else if c2 < LOCB || HICB < c2 {
			return false
		} else if size == 3 {
			//
		} else if c3 < LOCB || HICB < c3 {
			return false
		}
		i += size
	}
	return true
}

// decode_rune decodes the UTF-8 encoding of a single rune.
// Return error if the encoding is invalid.
pub fn decode_rune(p []u8) -> rune {
	len := p.len
	if len < 1 {
		return RUNE_ERROR
	}
	if len == 1 {
		// single ASCII byte
		return p.fast_get(0) as rune
	}
	if len > 4 {
		// invalid: long encoding
		return RUNE_ERROR
	}

	mut b := p.fast_get(0)
	b <<= len as u8

	mut res := b as rune
	mut shift := 6 as usize - len
	for i in 1 .. len {
		c := p.fast_get(i) as rune
		res <<= shift as rune
		res |= c & 0x3f
		shift = 6
	}

	return res
}

// decode_first_rune unpacks the first UTF-8 encoding in [`p`] and returns the
// rune and its width in bytes. If [`p`] is empty, it returns `(RUNE_ERROR, 0)`.
// Otherwise, if the encoding is invalid, it returns `(RUNE_ERROR, 1)`. Both
// are impossible results for correct, non-empty UTF-8.
//
// An encoding is invalid if it is incorrect UTF-8, encodes a rune that is
// out of range, or is not the shortest possible UTF-8 encoding for the
// value. No other validation is performed.
pub fn decode_first_rune(p []u8) -> (rune, i32) {
	n := p.len
	if n < 1 {
		return RUNE_ERROR, 0
	}
	p0 := p.fast_get(0)
	x := FIRST[p0]
	if x >= AC {
		// The following code simulates an additional check for x == XX and
		// handling the ASCII and invalid cases accordingly. This mask-and-or
		// approach prevents an additional branch.
		mask := x as rune << 31 >> 31 // Create 0x0000 or 0xFFFF.
		return p0 as rune & (~mask) | RUNE_ERROR & mask, 1
	}
	sz := (x & 7) as i32
	accept := ACCEPT_RANGES[(x >> 4) as usize]
	if n < sz {
		return RUNE_ERROR, 1
	}
	str1 := p.fast_get(1)
	if str1 < accept.lo || accept.hi < str1 {
		return RUNE_ERROR, 1
	}
	if sz <= 2 {
		// <= instead of == to help the compiler eliminate some bounds checks
		return (p0 & MASK2) as rune << 6 | (str1 & MASKX) as rune, 2
	}
	str2 := p.fast_get(2)
	if str2 < LOCB || HICB < str2 {
		return RUNE_ERROR, 1
	}
	if sz <= 3 {
		return (p0 & MASK3) as rune << 12 | (str1 & MASKX) as rune << 6 | (str2 & MASKX) as rune, 3
	}
	str3 := p.fast_get(3)
	if str3 < LOCB || HICB < str3 {
		return RUNE_ERROR, 1
	}
	return (p0 & MASK4) as rune << 18 | (str1 & MASKX) as rune << 12 | (str2 & MASKX) as rune << 6 | (str3 & MASKX) as rune, 4
}

// decode_rune_in_string unpacks the first UTF-8 encoding in s and returns the
// rune and its width in bytes. If s is empty, it returns `(RUNE_ERROR, 0)`.
// Otherwise, if the encoding is invalid, it returns `(RUNE_ERROR, 1)`. Both
// are impossible results for correct, non-empty UTF-8.
//
// An encoding is invalid if it is incorrect UTF-8, encodes a rune that is
// out of range, or is not the shortest possible UTF-8 encoding for the
// value. No other validation is performed.
pub fn decode_rune_in_string(s string) -> (rune, i32) {
	n := s.len
	if n < 1 {
		return RUNE_ERROR, 0
	}
	s0 := s.fast_at(0)
	x := FIRST[s0]
	if x >= AC {
		// The following code simulates an additional check for x == XX and
		// handling the ASCII and invalid cases accordingly. This mask-and-or
		// approach prevents an additional branch.
		mask := x as rune << 31 >> 31 // Create 0x0000 or 0xFFFF.
		return s0 as rune & (~mask) | RUNE_ERROR & mask, 1
	}
	sz := (x & 7) as i32
	accept := ACCEPT_RANGES[(x >> 4) as usize]
	if n < sz {
		return RUNE_ERROR, 1
	}
	str1 := s.fast_at(1)
	if str1 < accept.lo || accept.hi < str1 {
		return RUNE_ERROR, 1
	}
	if sz <= 2 {
		// <= instead of == to help the compiler eliminate some bounds checks
		return (s0 & MASK2) as rune << 6 | (str1 & MASKX) as rune, 2
	}
	str2 := s.fast_at(2)
	if str2 < LOCB || HICB < str2 {
		return RUNE_ERROR, 1
	}
	if sz <= 3 {
		return (s0 & MASK3) as rune << 12 | (str1 & MASKX) as rune << 6 | (str2 & MASKX) as rune, 3
	}
	str3 := s.fast_at(3)
	if str3 < LOCB || HICB < str3 {
		return RUNE_ERROR, 1
	}
	return (s0 & MASK4) as rune << 18 | (str1 & MASKX) as rune << 12 | (str2 & MASKX) as rune << 6 | (str3 & MASKX) as rune, 4
}

// visible_length calculates the length of the string in characters
// that will be visible on the screen. It takes into account
// combining characters and wide characters.
//
// This is simplified version and does not cover all cases, see [`unicode.string_width`].
pub fn visible_length(s string) -> usize {
	mut l := 0
	mut ul := 1
	for i := 0; i < s.len; i += ul {
		ch := s.fast_at(i)
		ul = (((0xe5000000 as i64 >> ((ch >> 3) & 0x1e)) & 3) + 1) as i32
		if i + ul > s.len {
			return l
		}
		l++
		if ul == 1 {
			continue
		}
		match ul {
			2 => {
				first := ch as u32 << 24
				second := unsafe { s.fast_at(i + 1) as u32 << 16 }

				r := (first | second) as u64
				if r >= 0xcc80 && r < 0xcdb0 {
					// diacritical marks
					l--
				}
			}
			3 => {
				first := ch as u32 << 24
				second := unsafe { s.fast_at(i + 1) as u32 << 16 }
				third := unsafe { s.fast_at(i + 2) as u32 << 8 }

				r := (first | second | third) as u64
				// diacritical marks extended
				// diacritical marks supplement
				// diacritical marks for symbols
				if (r >= 0xe1aab0 && r <= 0xe1ac7f) || (r >= 0xe1b780 && r <= 0xe1b87f) || (r >= 0xe28390 && r <= 0xe2847f) || (r >= 0xefb8a0 && r <= 0xefb8af) {
					// diacritical marks
					l--
				} else if (r >= 0xe18480 && r <= 0xe1859f) || (r >= 0xe2ba80 && r <= 0xe2bf95) || (r >= 0xe38080 && r <= 0xe4b77f) || (r >= 0xe4b880 && r <= 0xea807f) || (r >= 0xeaa5a0 && r <= 0xeaa79f) || (r >= 0xeab080 && r <= 0xed9eaf) || (r >= 0xefa480 && r <= 0xefac7f) || (r >= 0xefb8b8 && r <= 0xefb9af) {
					// Hangru
					// CJK Unified Ideographics
					// Hangru
					// CJK

					// half marks
					l++
				}
			}
			4 => {
				first := ch as u32 << 24
				second := unsafe { s.fast_at(i + 1) as u32 << 16 }
				third := unsafe { s.fast_at(i + 2) as u32 << 8 }
				fourth := unsafe { s.fast_at(i + 3) }

				r := (first | second | third | fourth) as u64
				// Enclosed Ideographic Supplement
				// Emoji
				// CJK Unified Ideographs Extension B-G
				if (r >= 0x0f9f8880 && r <= 0xf09f8a8f as i64) || (r >= 0xf09f8c80 as i64 && r <= 0xf09f9c90 as i64) || (r >= 0xf09fa490 as i64 && r <= 0xf09fa7af as i64) || (r >= 0xf0a08080 as i64 && r <= 0xf180807f as i64) {
					l++
				}
			}
		}
	}
	return l
}
