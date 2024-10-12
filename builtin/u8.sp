module builtin

import mem
import strconv

// u8 is the set of all unsigned 8-bit integers.
// Range: 0 through 255.
//
// u8 usually used to represent ASCII characters.
// For example, b`a` is a byte literal representing the ASCII character `a`.
//
// See also `rune` type for Unicode characters.
pub type u8 = u8

// is_space returns `true` if the byte is a white space character.
// The following list is considered white space characters:
// ` `, `\t`, `\n`, `\v`, `\f`, `\r`, 0x85, 0xa0
//
// Example:
// ```
// symbol := b` `
// symbol.is_space() == true
// ```
pub fn (u u8) is_space() -> bool {
	// 0x85 is NEXT LINE (NEL)
	// 0xa0 is NO-BREAK SPACE
	return u == b` ` || (u > 8 && u < 14) || u == 0x85 || u == 0xa0
}

// is_digit reports whether the byte is a decimal digit.
//
// Example:
// ```
// symbol := b`1`
// symbol.is_digit() == true
// ```
pub fn (u u8) is_digit() -> bool {
	return u >= b`0` && u <= b`9`
}

// is_bin_digit reports whether the byte is a binary digit.
//
// Example:
// ```
// s1 := b`0`
// s1.is_bin_digit() == true
// s2 := b`2`
// s2.is_bin_digit() == false
// ```
pub fn (u u8) is_bin_digit() -> bool {
	return u == b`0` || u == b`1`
}

// is_oct_digit reports whether the byte is an octal digit.
//
// Example:
// ```
// s1 := b`7`
// s1.is_oct_digit() == true
// s2 := b`8`
// s2.is_oct_digit() == false
// ```
pub fn (u u8) is_oct_digit() -> bool {
	return u >= b`0` && u <= b`7`
}

// is_hex_digit reports whether the byte is a hexadecimal digit.
//
// Example:
// ```
// s1 := b`a`
// s1.is_hex_digit() == true
// s2 := b`g`
// s2.is_hex_digit() == false
// ```
pub fn (u u8) is_hex_digit() -> bool {
	return (u >= b`0` && u <= b`9`) || (u >= b`a` && u <= b`f`) || (u >= b`A` && u <= b`F`)
}

// is_punctuation reports whether the byte is a punctuation character.
//
// Example:
// ```
// s1 := b`!`
// s1.is_punctuation() == true
// s2 := b`a`
// s2.is_punctuation() == false
// ```
pub fn (u u8) is_punctuation() -> bool {
	return (u >= b`!` && u <= b`/`) || (u >= b`:` && u <= b`@`) || (u >= b`[` && u <= b`\``) || (u >= b`{` && u <= b`~`)
}

// is_graphic reports whether the byte is an ASCII graphic character:
// U+0021 '!' to U+007E '~'
//
// Example:
// ```
// s1 := b`!`
// s1.is_graphic() == true
// s2 := b` `
// s2.is_graphic() == false
// ```
pub fn (u u8) is_graphic() -> bool {
	return u >= b`!` && u <= b`~`
}

// is_control reports whether the byte is a control character.
//
// Example:
// ```
// s1 := b`!`
// s1.is_control() == false
// s2 := b`\n`
// s2.is_control() == true
// ```
pub fn (u u8) is_control() -> bool {
	return u < b` ` || u == 0x7f
}

// is_alpha reports whether the byte is a Latin letter.
//
// Example:
// ```
// s1 := b`a`
// s1.is_alpha() == true
// s2 := b`1`
// s2.is_alpha() == false
// ```
pub fn (u u8) is_alpha() -> bool {
	return (u >= b`a` && u <= b`z`) || (u >= b`A` && u <= b`Z`)
}

// is_alphanum reports whether the byte is a Latin letter or decimal digit.
//
// Example:
// ```
// s1 := b`a`
// s1.is_alphanum() == true
// s2 := b`1`
// s2.is_alphanum() == true
// s3 := b`!`
// s3.is_alphanum() == false
// ```
pub fn (u u8) is_alphanum() -> bool {
	return u.is_alpha() || u.is_digit()
}

// is_capital returns `true`, if the byte is a Latin capital letter.
//
// Example:
// ```
// s1 := b`H`
// s1.is_capital() == true
// s2 := b`h`
// s2.is_capital() == false
// ```
pub fn (u u8) is_capital() -> bool {
	return u >= b`A` && u <= b`Z`
}

// is_lower returns `true`, if the byte is a Latin lower case letter.
//
// Example:
// ```
// s1 := b`H`
// s1.is_lower() == false
// s2 := b`h`
// s2.is_lower() == true
// ```
pub fn (u u8) is_lower() -> bool {
	return u >= b`a` && u <= b`z`
}

// is_ascii reports whether u is an ASCII letter, number, or punctuation character.
pub fn (u u8) is_ascii() -> bool {
	return u < 128
}

// ascii_str returns a string containing the ASCII representation of the given u8.
// The returned string will be 1 byte long.
//
// Example:
// ```
// symbol := b`a`
// symbol.ascii_str() == 'a'
// ```
pub fn (u u8) ascii_str() -> string {
	mut str := string{
		data: mem.alloc(2)
		len: 1
	}
	// SAFETY: `str.data` is allocated with 2 bytes, so it's safe to write 2 bytes to it.
	unsafe {
		str.data[0] = u
		str.data[1] = 0
	}
	return str
}

// utf8_len returns the number of bytes required to encode the given u8 as UTF-8.
//
// Example:
// ```
// symbol := b`a`
// symbol.utf8_len() == 1
// ```
pub fn (u u8) utf8_len() -> i64 {
	return ((0xe5000000 as i64 >> ((u >> 3) & 0x1e)) & 3) + 1
}

// repeat returns a new string with `count` number of copies of the u8 it was called on.
//
// Example:
// ```
// symbol := b`a`
// symbol.repeat(3) == 'aaa'
// ```
pub fn (u u8) repeat(count usize) -> string {
	if count == 0 {
		return ''
	}
	if count == 1 {
		return u.ascii_str()
	}
	mut data := mem.alloc(count + 1) as *u8
	mem.set(data, u, count)
	// SAFETY: `data` is allocated with `count + 1` bytes,
	// so it's safe to write `0` to the last byte.
	unsafe {
		data[count] = 0
	}
	return string.view_from_c_str_len(data, count)
}

// to_lower returns the lowercase version of the given u8.
//
// Example:
// ```
// symbol := b`A`
// symbol.to_lower() == b`a`
// ```
pub fn (u u8) to_lower() -> u8 {
	if u.is_capital() {
		return u + 32
	}
	return u
}

// to_upper returns the uppercase version of the given u8.
//
// Example:
// ```
// symbol := b`a`
// symbol.to_upper() == b`A`
// ```
pub fn (u u8) to_upper() -> u8 {
	if u.is_lower() {
		return u - 32
	}
	return u
}

// str returns a string containing the number represented in base 10.
//
// Example:
// ```
// symbol := 106 as u8
// symbol.str() == '106'
// ```
pub fn (u u8) str() -> string {
	return strconv.uint_to_str(u as u64, 4)
}

// hex returns a string containing the number represented in base 16.
//
// Note: to get hexadecimal representation with `0x` prefix, use [`hex_prefixed`] method.
//
// Example:
// ```
// symbol := 106 as u8
// symbol.hex() == '6a'
// ```
pub fn (u u8) hex() -> string {
	return strconv.uint_to_hex(u as u64, 4, false)
}

// hex_prefixed returns a string containing the number represented in base 16 with `0x` prefix.
//
// Note: to get hexadecimal representation without `0x` prefix, use [`hex`] method..
//
// Example:
// ```
// symbol := 106 as u8
// symbol.hex_prefixed() == '0x6a'
// ```
pub fn (u u8) hex_prefixed() -> string {
	return strconv.uint_to_hex(u as u64, 4, true)
}

// hash returns the hash code for the number.
pub fn (u u8) hash() -> u64 {
	return wyhash64_(u, 0)
}

// cmp compares two values and returns an [`Ordering`] value.
pub fn (s u8) cmp(b u8) -> Ordering {
	return if s < b { .less } else if s > b { .greater } else { .equal }
}
