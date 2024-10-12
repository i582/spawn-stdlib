module strings

import utf8

// Builder is a dynamically growing buffer of bytes.
// It is used to efficiently append many strings to a large
// dynamically growing buffer, then use the resulting large string.
// Using a string builder is much faster and more memory efficient than
// doing string concatenations.
//
// Example:
// ```
// b := strings.new_builder(50)
// for i in 0..10 {
//     b.write_str(i.str())
// }
// println(b.str())
// ```
pub type Builder = []u8

// new_builder creates a new string builder with the given initial capacity.
pub fn new_builder(cap usize) -> Builder {
	return []u8{cap: cap} as Builder
}

// write_string appends the given string to the builder.
pub fn (b &mut Builder) write_string(str string) -> !i32 {
	(b as &mut []u8).push_ptr(str.data, str.len)
	return str.len as i32
}

// write_str appends the given string to the builder.
//
// Same as [`write_string`], but without returning an Result with
// the number of bytes written.
pub fn (b &mut Builder) write_str(str string) {
	(b as &mut []u8).push_ptr(str.data, str.len)
}

// write_u8 appends the given byte to the builder.
pub fn (b &mut Builder) write_u8(val u8) {
	(b as &mut []u8).push(val)
}

// write_rune appends the given rune to the builder.
pub fn (b &mut Builder) write_rune(r rune) {
	mut p := [5]u8{}
	len := utf8.encode_rune(&mut p[..], r)
	b.push_many(p[..len])
}

pub fn (b &mut Builder) write_i64(val i64) {
	mut p := [25]u8{}
	buf_len := write_i64_at(&mut p[..], val, 25)
	b.push_many(p[25 - buf_len..])
}

pub fn (b &mut Builder) write_padded_i64(val i64, len usize, pad u8) {
	mut p := [25]u8{}
	buf_len := write_i64_at(&mut p[..], val, 25)
	if buf_len < len {
		for i in 0 .. len - buf_len {
			b.push(pad)
		}
	}

	b.push_many(p[25 - buf_len..])
}

fn write_i64_at(slice &mut []u8, val i64, at_end usize) -> usize {
	mut num := val
	if num < 0 {
		return 0
	}

	mut end := (at_end - 1) as isize
	mut i := end
	for num > 0 && i >= 0 {
		slice[i] = (num % 10) as u8 + b`0`
		num /= 10
		i--
	}

	return end - i
}

pub fn (b &mut Builder) write_ptr(ptr &u8, len usize) {
	(b as &mut []u8).push_ptr(ptr, len)
}

pub fn (b &mut Builder) write(data []u8) -> !i32 {
	b.push_many(data)
	return data.len as i32
}

// clear clears the builder, so that it can be reused.
// This is useful if you want to reuse the builder without
// allocating a new one.
pub fn (b &mut Builder) clear() {
	b.len = 0
}

// trim removes the last `n` bytes from the builder.
pub fn (b &mut Builder) trim(n usize) {
	b.len -= n
}

// at returns the byte at the given index.
pub fn (b &Builder) at(idx usize) -> u8 {
	return (b as &[]u8)[idx]
}

pub fn (b &mut Builder) fill_zeroes() {
	for i in 0 .. b.cap {
		b.fast_push(0)
	}
}

// str returns the string that has been built up so far.
// Note that this does not clear the builder, so you can continue
// to append to it after calling this.
//
// See also `str_view` for a version that does not allocate a new string.
pub fn (b Builder) str() -> string {
	return string.from_bytes(b)
}

// str_view returns the string that has been built up so far.
// Note that returned string uses the same underlying memory as the builder,
// so you should not store the string for later use or modify builder after
// calling this method if you are storing the string.
// If you store the string and then modify the builder, you will modify the
// string as well.
//
// Mostly this method is useful for immediately passing the string to `println`
// or other such functions, since it avoids allocating a new string.
//
// Example:
// ```
// b := strings.new_builder(50)
// for i in 0 .. 10 {
//   b.write_str(i.str())
// }
// println(b.str_view())     // no allocations here
// b.clear()                 // clear the builder so we can reuse it
// for i in 0 .. 10 {
//   b.write_str(i.str()) // no allocations here for `write_string()`
// }
// println(b.str_view())     // no allocations here
// ```
pub fn (b &mut Builder) str_view() -> string {
	if b.len == 0 {
		return ''
	}

	// For safe use of memory as a string, we need to ensure that the
	// string is null terminated. If the builder is full, then adding
	// a null terminator would cause a reallocation, that would be
	// bigger than just allocating a new string, so in this case
	// we just allocate a new string.
	if b.len == b.cap {
		return string.from_bytes(*b)
	}
	// Otherwise, we just add a null terminator to the end of the
	// string, and return a string view of the whole buffer.
	b.write_u8(0 as u8)
	return string.view_from_c_str_len(b.data, b.len - 1)
}

// as_array returns the underlying u8 array of the builder.
pub fn (b &mut Builder) as_array() -> []u8 {
	return *b as []u8
}
