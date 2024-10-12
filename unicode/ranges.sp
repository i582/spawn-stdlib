module unicode

pub const (
	MAX_RUNE         = 65535 // Maximum valid Unicode code point.
	REPLACEMENT_CHAR = 65533 // Represents invalid code points.
	MAX_ASCII        = 127   // Maximum ASCII value.
	MAX_LATIN1       = 255   // Maximum Latin-1 value.
)

pub const (
	UPPER_CASE = 0
	LOWER_CASE = 1
	TITLE_CASE = 2
	MAX_CASE   = 3
)

pub const (
	// If the [`delta`] field of a [`CaseRange`] is [`UPPER_LOWER`], it means
	// this [`CaseRange`] represents a sequence of the form (say)
	// `[UPPER] [LOWER] [UPPER] [LOWER]`.
	UPPER_LOWER = 65535 + 1 // (Cannot be a valid delta.)
)

// LINEAR_MAX is the maximum size table for linear search for non-Latin1 rune.
const LINEAR_MAX = 18

// Bit masks for each code point under U+0100, for fast lookup.
const (
	pC     = 1 << 0    // a control character.
	pP     = 1 << 1    // a punctuation character.
	pN     = 1 << 2    // a numeral.
	pS     = 1 << 3    // a symbolic character.
	pZ     = 1 << 4    // a spacing character.
	pLu    = 1 << 5    // an upper-case letter.
	pLl    = 1 << 6    // a lower-case letter.
	pp     = 1 << 7    // a printable character according to Go's definition.
	pg     = pp | pZ   // a graphical character according to the Unicode definition.
	pLo    = pLl | pLu // a letter that is neither upper nor lower case.
	pLmask = pLo
)

// RangeTable defines a set of Unicode code points by listing the ranges of
// code points within the set. The ranges are listed in two slices
// to save space: a slice of 16-bit ranges and a slice of 32-bit ranges.
//
// The two slices must be in sorted order and non-overlapping.
// Also, [`r_32`] should contain only values `>= 0x10000` (1 << 16).
struct RangeTable {
	r_16         []Range16
	r_32         []Range32
	latin_offset i32       // number of entries in R16 with hi <= MaxLatin1
}

// [`CASE_ORBIT`] is defined in tables.sp as `[]FoldPair`. Right now all the
// entries fit in u16, so use u16. If that changes, compilation
// will fail (the constants in the literal will not fit in i16)
// and the types here can change to u32.
struct FoldPair {
	from u16
	to   u16
}

// Range16 represents of a range of 16-bit Unicode code points.
// The range runs from [`lo`] to [`hi`] inclusive and has the specified
// stride [`st`].
struct Range16 {
	lo u16
	hi u16
	st u16
}

// Range32 represents of a range of Unicode code points and is used when one or
// more of the values will not fit in 16 bits. The range runs from [`lo`] to [`hi`]
// inclusive and has the specified stride. [`lo`] and [`hi`] must always be `>= 1 << 16`.
struct Range32 {
	lo u32
	hi u32
	st u32
}

// CaseRange represents a range of Unicode code points for simple (one
// code point to one code point) case conversion.
// The range runs from [`lo`] to [`hi`] inclusive, with a fixed stride of 1.
// [`delta`]s are the number to add to the code point to reach the code point for a
// different case for that character. They may be negative. If zero, it
// means the character is in the corresponding case. There is a special
// case representing sequences of alternating corresponding [`UPPER`] and [`LOWER`]
// pairs. It appears with a fixed [`delta`] of
// ```
// {UPPER_LOWER, UPPER_LOWER, UPPER_LOWER}
// ```
// The constant [`UPPER_LOWER`] has an otherwise impossible delta value.
struct CaseRange {
	lo    u32
	hi    u32
	delta []rune
}

// is16 reports whether [`r`] is in the sorted slice of 16-bit ranges.
fn is16(ranges []Range16, r u16) -> bool {
	if ranges.len <= LINEAR_MAX || r <= MAX_LATIN1 {
		for range in ranges {
			if r < range.lo {
				return false
			}
			if r <= range.hi {
				return range.st == 1 || (r - range.lo) % range.st == 0
			}
		}
		return false
	}

	// binary search over ranges
	mut lo := 0
	mut hi := ranges.len as i32
	for lo < hi {
		m := ((lo + hi) as u32 >> 1) as i32
		range_ := &ranges[m]
		if range_.lo <= r && r <= range_.hi {
			return range_.st == 1 || (r - range_.lo) % range_.st == 0
		}
		if r < range_.lo {
			hi = m
		} else {
			lo = m + 1
		}
	}
	return false
}

// is32 reports whether r is in the sorted slice of 32-bit ranges.
fn is32(ranges []Range32, r u32) -> bool {
	if ranges.len <= LINEAR_MAX {
		for range in ranges {
			if r < range.lo {
				return false
			}
			if r <= range.hi {
				return range.st == 1 || (r - range.lo) % range.st == 0
			}
		}
		return false
	}

	// binary search over ranges
	mut lo := 0
	mut hi := ranges.len as i32
	for lo < hi {
		m := ((lo + hi) as u32 >> 1) as i32
		range_ := ranges[m]
		if range_.lo <= r && r <= range_.hi {
			return range_.st == 1 || (r - range_.lo) % range_.st == 0
		}
		if r < range_.lo {
			hi = m
		} else {
			lo = m + 1
		}
	}
	return false
}

// is_a reports whether the rune [`r`] is in the specified table of ranges.
pub fn is_a(rangeTab RangeTable, r rune) -> bool {
	r16 := rangeTab.r_16
	// Compare as uint32 to correctly handle negative runes.
	if r16.len > 0 && r as u32 <= r16[r16.len - 1].hi as u32 {
		return is16(r16, r as u16)
	}
	r32 := rangeTab.r_32
	if r32.len > 0 && r >= r32[0].lo as rune {
		return is32(r32, r as u32)
	}
	return false
}

fn is_excluding_latin(rangeTab RangeTable, r rune) -> bool {
	r16 := rangeTab.r_16
	// Compare as u32 to correctly handle negative runes.
	off := rangeTab.latin_offset
	if r16.len > off && r as u32 <= (r16[r16.len - 1].hi) as i32 {
		return is16(r16[off..], r as u16)
	}
	r32 := rangeTab.r_32
	if r32.len > 0 && r >= r32[0].lo as rune {
		return is32(r32, r as u32)
	}
	return false
}

// is_upper reports whether the rune is an upper case letter.
//
// Example:
// ```
// assert unicode.is_upper(`L`)
// assert unicode.is_upper(`l`) == false
// assert unicode.is_upper(`Ы`)
// assert unicode.is_upper(`ы`) == false
// ```
pub fn is_upper(r rune) -> bool {
	// See comment in is_graphic.
	if r <= MAX_LATIN1 {
		return PROPERTIES[r as u8] & pLmask == pLu
	}
	return is_excluding_latin(UPPER, r)
}

// is_lower reports whether the rune is a lower case letter.
//
// Example:
// ```
// assert unicode.is_lower(`L`) == false
// assert unicode.is_lower(`l`)
// assert unicode.is_lower(`Ы`) == false
// assert unicode.is_lower(`ы`)
// ```
pub fn is_lower(r rune) -> bool {
	// See comment in is_graphic.
	if r <= MAX_LATIN1 {
		return PROPERTIES[r as u8] & pLmask == pLl
	}
	return is_excluding_latin(LOWER, r)
}

// is_title reports whether the rune is a title case letter.
//
// Note: title case transforms a character to its title form,
// which is often the same as the upper case form but can differ
// for certain characters in some languages.
//
// For example, the character 'ǳ' in title case becomes 'ǲ', while
// in upper case it becomes 'Ǳ'.
//
// Example:
// ```
// assert unicode.is_upper(`ǲ`) == false
// assert unicode.is_title(`ǲ`)
// assert unicode.is_upper(`Ǳ`)
// assert unicode.is_title(`Ǳ`) == false
// ```
pub fn is_title(r rune) -> bool {
	if r <= MAX_LATIN1 {
		return false
	}
	return is_excluding_latin(TITLE, r)
}

// to_impl maps the rune using the specified case mapping.
// It additionally reports whether [`case_range`] contained a mapping for [`r`].
fn to_impl(case i32, r rune, case_range []CaseRange) -> (rune, bool) {
	if case < 0 || MAX_CASE <= case {
		return REPLACEMENT_CHAR, false // as reasonable an error as any
	}

	// binary search over ranges
	mut lo := 0
	mut hi := case_range.len as i32
	for lo < hi {
		m := ((lo + hi) as u32 >> 1) as i32
		cr := case_range[m]
		if cr.lo as rune <= r && r <= cr.hi as rune {
			delta := cr.delta[case]
			if delta > MAX_RUNE {
				// In an Upper-Lower sequence, which always starts with
				// an UPPER_CASE letter, the real deltas always look like:
				//	{0, 1, 0}    UPPER_CASE (LOWER is next)
				//	{-1, 0, -1}  LOWER_CASE (UPPER, TITLE are previous)
				// The characters at even offsets from the beginning of the
				// sequence are upper case; the ones at odd offsets are lower.
				// The correct mapping can be done by clearing or setting the low
				// bit in the sequence offset.
				// The constants UPPER_CASE and TITLE_CASE are even while LOWER_CASE
				// is odd so we take the low bit from case.
				return cr.lo as rune + ((r - cr.lo as rune) & ~1 | (case & 1) as rune), true
			}
			return r + delta, true
		}
		if r < cr.lo as rune {
			hi = m
		} else {
			lo = m + 1
		}
	}
	return r, false
}

// to maps the rune to the specified case:
// [`UPPER_CASE`], [`LOWER_CASE`], or [`TITLE_CASE`].
pub fn to(case i32, r rune) -> rune {
	r, _ = to_impl(case, r, CASE_RANGES)
	return r
}

// to_upper maps the rune to upper case.
//
// Example:
// ```
// assert unicode.to_upper(`l`) == `L`
// assert unicode.to_upper(`ы`) == `Ы`
// assert unicode.to_upper(`0`) == `0`
// ```
pub fn to_upper(r rune) -> rune {
	if r <= MAX_ASCII {
		if `a` <= r && r <= `z` {
			return r - (`a` - `A`)
		}
		return r
	}
	return to(UPPER_CASE, r)
}

// to_lower maps the rune to lower case.
//
// Example:
// ```
// assert unicode.to_lower(`L`) == `l`
// assert unicode.to_lower(`Ы`) == `ы`
// assert unicode.to_lower(`0`) == `0`
// ```
pub fn to_lower(r rune) -> rune {
	if r <= MAX_ASCII {
		if `A` <= r && r <= `Z` {
			return r + (`a` - `A`)
		}
		return r
	}
	return to(LOWER_CASE, r)
}

// to_title maps the rune to title case.
//
// Note: title case transforms a character to its title form,
// which is often the same as the upper case form but can differ
// for certain characters in some languages.
//
// For example, the character 'ǳ' in title case becomes 'ǲ', while
// in upper case it becomes 'Ǳ'.
//
// Example:
// ```
// assert unicode.to_upper(`ǳ`) == `Ǳ`
// assert unicode.to_title(`ǳ`) == `ǲ`
// assert unicode.to_title(`0`) == `0`
// ```
pub fn to_title(r rune) -> rune {
	if r <= MAX_ASCII {
		// title case is upper case for ASCII
		if `a` <= r && r <= `z` {
			return r - (`a` - `A`)
		}
		return r
	}
	return to(TITLE_CASE, r)
}
