module builtin

// to_wide converts a string to UTF-16 encoded string that can be used for
// Windows API calls.
pub fn (s string) to_wide() -> *u16 {
	runes_len := s.utf8_len()

	mut res := []u16{cap: runes_len + 1}

	for i, r in s.runes_iter() {
		// if in Basic Multilingual Plane
		if r < 0xFFFF {
			res.push(r as u16)
		} else {
			// Non-BMP, convert to surrogate pairs
			high_surrogate := ((r - 0x10000) >> 10) + 0xD800
			low_surrogate := ((r - 0x10000) & 0x3FF) + 0xDC00
			res.push(high_surrogate as u16)
			res.push(low_surrogate as u16)
		}
	}

	res.push(0)
	return res.raw()
}

// from_wide converts a UTF-16 encoded null-terminated string to a UTF-8 string.
//
// For known length of the string, use more efficient [`string.from_wide_with_len`]
// instead.
// The passed [`str`] must be null-terminated, otherwise the behavior is undefined.
pub fn string.from_wide(str *u16) -> string {
	if str == nil {
		return ""
	}

	// On Windows we can use `wcslen` to get the length of the string,
	// but on other platforms we emulate it with a loop.
	mut len := 0
	// SAFETY: `str` is null-terminated.
	for unsafe { str[len] } != 0 {
		len++
	}
	return string.from_wide_with_len(str, len)
}

// from_wide_with_len converts a UTF-16 encoded string to a UTF-8 string.
pub fn string.from_wide_with_len(str *u16, len usize) -> string {
	if str == nil {
		return ""
	}

	mut b := []u8{cap: len * 4}

	mut i := 0
	for i < len {
		unit := unsafe { str[i] }

		if unit >= 0xD800 && unit <= 0xDBFF {
			// high surrogate
			if i + 1 < len {
				low_unit := unsafe { str[i + 1] }

				if low_unit >= 0xDC00 && low_unit <= 0xDFFF {
					// low surrogate
					high := unit as u32
					low := low_unit as u32
					code_point := ((high - 0xD800) << 10) + (low - 0xDC00) + 0x10000

					if code_point <= 0x7F {
						b.push(code_point as u8)
					} else if code_point <= 0x7FF {
						b.push(0xC0 | (code_point >> 6) as u8)
						b.push(0x80 | (code_point & 0x3F) as u8)
					} else if code_point <= 0xFFFF {
						b.push(0xE0 | (code_point >> 12) as u8)
						b.push(0x80 | ((code_point >> 6) & 0x3F) as u8)
						b.push(0x80 | (code_point & 0x3F) as u8)
					} else if code_point <= 0x10FFFF {
						b.push(0xF0 | (code_point >> 18) as u8)
						b.push(0x80 | ((code_point >> 12) & 0x3F) as u8)
						b.push(0x80 | ((code_point >> 6) & 0x3F) as u8)
						b.push(0x80 | (code_point & 0x3F) as u8)
					}

					i++ // skip the next unit as it's part of the surrogate pair
				} else {
					// invalid surrogate pair
					b.push(0xEF)
					b.push(0xBF)
					b.push(0xBD)
				}
			} else {
				// invalid encoding
				// high surrogate without a low surrogate
				b.push(0xEF)
				b.push(0xBF)
				b.push(0xBD)
			}
		} else if unit >= 0xDC00 && unit <= 0xDFFF {
			// invalid encoding
			// low surrogate without a preceding high surrogate
			b.push(0xEF)
			b.push(0xBF)
			b.push(0xBD)
		} else {
			// BMP or single code point
			if unit <= 0x7F {
				b.push(unit as u8)
			} else if unit <= 0x7FF {
				b.push(0xC0 | (unit >> 6) as u8)
				b.push(0x80 | (unit & 0x3F) as u8)
			} else if unit <= 0xFFFF {
				b.push(0xE0 | (unit >> 12) as u8)
				b.push(0x80 | ((unit >> 6) & 0x3F) as u8)
				b.push(0x80 | (unit & 0x3F) as u8)
			}
		}
		i++
	}

	return string.view_from_bytes(b)
}
