module builtin

import mem
import utf8

// rune is an alias for i32 and is equivalent to i32 in all ways. It is
// used, by convention, to distinguish character values from integer values.
pub type rune = rune

// str returns the UTF-8 encoding of the rune.
pub fn (r rune) str() -> string {
	return utf8.encode_rune_to_string(r)
}

// bytes returns the UTF-8 encoding of the rune.
pub fn (r rune) bytes() -> []u8 {
	// SAFETY: since [`FixedArray.sub`] is allocating a new array we can safely
	//         use a stack-allocated array to get the bytes of the rune.
	mut p := [5]u8{}
	len := utf8.encode_rune(&mut p[..], r)
	return p.sub(0, len)
}

// repeat returns a new string with `count` number of copies
// of the rune it was called on.
//
// Example:
// ```
// symbol := `a`
// assert symbol.repeat(3) == 'aaa'
// ```
pub fn (r rune) repeat(count usize) -> string {
	if count == 0 {
		return ''
	}
	if count == 1 {
		return r.str()
	}
	str := r.str()
	len := r.len()
	len_in_bytes := len * count

	mut data := mem.alloc((count + 1) * len) as *u8
	for i in 0 .. count {
		unsafe { mem.fast_copy(data + i * len, str.c_str(), len) }
	}
	// SAFETY: `data` is allocated with `count + 1` bytes,
	//         so it's safe to write `0` to the last byte.
	unsafe {
		data[len_in_bytes] = 0
	}
	return string.view_from_c_str_len(data, len_in_bytes)
}

// len returns the number of bytes required to encode the rune.
// If the rune is not a valid value to encode in UTF-8, it returns -1.
pub fn (r rune) len() -> isize {
	return utf8.rune_len(r)
}

// is_valid returns true if the rune is a valid value to encode in UTF-8.
pub fn (r rune) is_valid() -> bool {
	return utf8.is_valid_rune(r)
}

// is_ascii returns true if the rune is an ASCII value.
pub fn (r rune) is_ascii() -> bool {
	return r < 128
}

// as_ascii returns the rune as an ASCII character.
// If the rune is not an ASCII character (i.e. it is not in the range [0, 127]),
// it returns none.
pub fn (r rune) as_ascii() -> ?u8 {
	if r.is_ascii() {
		// SAFETY: we already checked that r is in the range [0, 127]
		// so it is safe to cast it to u8.
		return unsafe { r as u8 }
	}
	return none
}

// hash returns the hash code for the number.
pub fn (r rune) hash() -> u64 {
	return wyhash64_(r, 0)
}

// cmp compares two runes and returns an [`Ordering`] value.
pub fn (s rune) cmp(b rune) -> Ordering {
	return if s < b { .less } else if s > b { .greater } else { .equal }
}
