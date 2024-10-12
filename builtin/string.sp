module builtin

import mem
import utf8
import sys.libc
import strconv
import intrinsics

// string is a struct that represents a null-terminated string.
pub struct string {
	// data is a pointer to the null-terminated memory buffer.
	data *u8

	// len is the length of the string in **bytes**.
	// All string uses UTF-8 encoding, so this is not the same as the
	// number of characters (except ASCII-only strings where it is the same).
	// To get the number of characters, use the `utf8_len()` method.
	len usize
}

// cmp compares two strings and returns an [`Ordering`] value.
pub fn (s string) cmp(b string) -> Ordering {
	return if s < b { .less } else if s > b { .greater } else { .equal }
}

// cmp_ignore_case compares two strings case-insensitively and returns an [`Ordering`] value.
pub fn (s string) cmp_ignore_case(b string) -> Ordering {
	mut i := 0 as usize
	for i < s.len.min(b.len) {
		s_ch := s[i].to_lower()
		b_ch := b[i].to_lower()
		if s_ch < b_ch {
			return .less
		}
		if s_ch > b_ch {
			return .greater
		}
		i++
	}
	return s.len.cmp(b.len)
}

// equal is operator `==` overloading for comparing strings
pub fn (s string) equal(b string) -> bool {
	if s.len != b.len {
		return false
	}

	if s.len == 0 {
		return true
	}

	last_idx := s.len - 1

	// fast path, checking of last byte is pretty cheap,
	// so in many cases we can avoid for loop at all.
	if s[last_idx] != b[last_idx] {
		return false
	}

	// last_idx is already checked above.
	for i in 0 .. last_idx {
		if s[i] != b[i] {
			return false
		}
	}

	return true
}

// equal_ignore_case returns true if the strings are equal, ignoring case.
// Example:
// ```
// 'Hello'.equal_ignore_case('hello') == true
// ```
pub fn (s string) equal_ignore_case(b string) -> bool {
	if s.len != b.len {
		return false
	}

	if s.len == 0 {
		return true
	}

	last_idx := s.len - 1

	// fast path, checking of last byte is pretty cheap,
	// so in many cases we can avoid for loop at all.
	if s[last_idx].to_lower() != b[last_idx].to_lower() {
		return false
	}

	// last_idx is already checked above.
	for i in 0 .. last_idx {
		if s[i].to_lower() != b[i].to_lower() {
			return false
		}
	}

	return true
}

// less is operator `<` overloading for comparing strings
pub fn (s string) less(b string) -> bool {
	if s.len == 0 {
		return b.len > 0
	}

	if b.len == 0 {
		return false
	}

	for i in 0 .. s.len.min(b.len) {
		if s[i] < b[i] {
			return true
		}
		if s[i] > b[i] {
			return false
		}
	}

	return s.len < b.len
}

// add is operator `+` overloading for concatenating strings
pub fn (s string) add(b string) -> string {
	len := s.len + b.len
	mut buf := mem.alloc(len + 1) as *mut u8
	mem.fast_copy(buf, s.data, s.len)
	mem.fast_copy(buf + s.len, b.data, b.len)
	unsafe {
		buf[len] = 0
	}
	return string{
		data: buf
		len: len
	}
}

// add_assign is operator `+=` overloading for concatenating strings
pub fn (s &mut string) add_assign(b string) {
	new_ptr := mem.alloc(s.len + b.len + 1)
	libc.strncpy(new_ptr, s.data, s.len)
	libc.strcat(new_ptr, b.data)
	*s = string{
		data: new_ptr
		len: s.len + b.len
	}
}

// starts_with returns true if the string starts with the given prefix.
//
// Example:
// ```
// 'abc'.starts_with('ab') == true
// ```
pub fn (s string) starts_with(prefix string) -> bool {
	prefix_len := prefix.len
	if s.len < prefix_len {
		return false
	}
	return libc.strncmp(s.data, prefix.data, prefix_len) == 0
}

// ends_with returns true if the string ends with the given suffix.
//
// Example:
// ```
// 'abc'.ends_with('bc') == true
// ```
pub fn (s string) ends_with(suffix string) -> bool {
	suffix_len := suffix.len
	if s.len < suffix_len {
		return false
	}
	suffix_start := s.len - suffix_len
	// SAFETY: `s.data + suffix_start` is always a valid pointer since
	//         `suffix_start` is always less than `s.len` (see the check above).
	return libc.strncmp(unsafe { s.data + suffix_start }, suffix.data, suffix_len) == 0
}

// trim_prefix returns a string without the given prefix.
// Example:
// ```
// 'Hello World'.trim_prefix('Hello ') == 'World'
// ```
pub fn (s string) trim_prefix(prefix string) -> string {
	if s.starts_with(prefix) {
		return s[prefix.len..s.len]
	}
	return s
}

// trim_suffix returns a string without the given suffix.
// Example:
// ```
// 'Hello World'.trim_suffix(' World') == 'Hello'
// ```
pub fn (s string) trim_suffix(suffix string) -> string {
	if s.ends_with(suffix) {
		return s.substr(0, s.len - suffix.len)
	}
	return s
}

// substr returns the string between index positions `start` and `end`.
//
// Note: `end` is exclusive, so the resulting string will contain characters
// from `start` to `end - 1`.
//
// Example:
// ```
// 'Hello'.substr(1, 3) == 'ell'
// ```
//
// Note: this method returns a copy of the string thus allocating memory,
// if you want to avoid memory allocation, use `slice()` instead, but read
// the note in `slice()` documentation carefully.
pub fn (s string) substr(start usize, end usize) -> string {
	if start > end || start > s.len || end > s.len {
		panic('substr(${start}, ${end}) is out of bounds, len: ${s.len}')
	}

	len := end - start
	if len == s.len {
		return s
	}

	mut buf := mem.alloc(len + 1) as *mut u8
	// SAFETY: `s.data + start` is always a valid pointer since
	// `start` is always less than `s.len` (see the check above).
	unsafe {
		mem.fast_copy(buf, s.data + start, len)
		buf[len] = 0 as u8
	}
	return string{
		data: buf
		len: len
	}
}

// slice returns the string between index positions `start` and `end`.
//
// Note: `end` is exclusive, so the resulting string will contain characters
// from `start` to `end - 1`.
//
// Example:
// ```
// 'Hello'.slice(1, 3, false) == 'el'
// ```
//
// **Important note**: unlike `substr`, `slice` returns a string with the same
// underlying memory buffer as the original string, and without zero byte at the end,
// so using result as a null-terminated string may lead to unexpected results, for
// example printing the result of `slice` will print the original string from the given
// index to the end.
//
// Example:
// ```
// println('Hello'.slice(1, 3, false)) // prints 'ello', not 'el'
// ```
//
// If you want to use the result of `slice` as a null-terminated string, call `clone()`
// on it first.
//
// Example:
// ```
// println('Hello'.slice(1, 3, false).clone()) // prints 'el'
// ```
#[track_caller]
pub fn (s string) slice(start usize, end usize, inclusive_end bool) -> string {
	final_start := if start == -1 { 0 as usize } else { start }
	final_end := if end == -1 { s.len } else { end } + inclusive_end as usize
	comptime if !no_bounds_checking {
		if final_start > final_end || final_start > s.len || final_end > s.len {
			end_for_error := if end == -1 { s.len } else { end }
			panic('slice(${final_start}, ${end_for_error}, inclusive_end: ${inclusive_end}) is out of bounds, len: ${s.len}')
		}
	}
	return string{
		data: s.data + final_start
		len: final_end - final_start
	}
}

// as_array returns the string as a byte array.
// This array should not be modified, since it is a direct reference to the
// string's memory buffer. Before any modification, the array should be cloned
// using `clone()` method.
pub fn (s string) as_array() -> []u8 {
	return new_array_from_raw(s.data, s.len)
}

// replace returns a copy of the string with all occurrences of `rep` replaced with `with`.
//
// Example:
// ```
// 'Hello, World'.replace('World', 'Earth') == 'Hello, Earth'
// ```
pub fn (s string) replace(rep string, with string) -> string {
	if rep.len == 1 {
		return s.replace_u8(rep[0], with)
	}

	if s.len < rep.len {
		return s
	}

	count := s.count(rep)
	if count == 0 {
		return s
	}

	new_len := s.len - count * rep.len + count * with.len
	mut buf := mem.alloc(new_len + 1) as *mut u8

	mut j := 0 as usize
	mut i := 0 as usize
	for i < s.len {
		if i + rep.len <= s.len && s[i..i + rep.len] == rep {
			unsafe {
				mem.fast_copy(buf + j, with.data, with.len)
			}
			j = j + with.len
			i = i + rep.len - 1
		} else {
			unsafe {
				buf[j] = s[i]
			}
			j++
		}
		i++
	}

	return string{
		data: buf
		len: new_len
	}
}

// replace_u8 returns a copy of the string with all occurrences of `rep` replaced with `with`.
//
// Example:
// ```
// 'Hello, World'.replace_u8(b`l`, 'L') == 'HeLLo, WorLd'
// ```
pub fn (s string) replace_u8(rep u8, with string) -> string {
	if s.len == 0 {
		return ''
	}

	count := s.count_u8(rep)
	if count == 0 {
		return s
	}

	new_len := s.len - count + count * with.len
	mut buf := mem.alloc(new_len + 1) as *mut u8

	mut j := 0 as usize
	for ch in s {
		if ch == rep {
			unsafe {
				mem.fast_copy(buf + j, with.data, with.len)
			}
			j = j + with.len
		} else {
			unsafe {
				buf[j] = ch
			}
			j++
		}
	}

	unsafe {
		buf[new_len] = 0
	}

	return string{
		data: buf
		len: new_len
	}
}

// replace_u8_with_u8 returns a copy of the string with all occurrences of
// `rep` replaced with `with`.
//
// Example:
// ```
// 'Hello, World'.replace_u8_with_u8(b`l`, b`L`) == 'HeLLo, WorLd'
// ```
// TODO: Do we need the `replace_u8` function as it is now?
pub fn (s string) replace_u8_with_u8(rep u8, with u8) -> string {
	if s.len == 0 {
		return ''
	}

	mut buf := mem.alloc(s.len + 1) as *u8

	unsafe {
		for j, ch in s {
			buf[j] = if ch == rep { with } else { ch }
		}

		buf[s.len] = 0
	}

	return string{
		data: buf
		len: s.len
	}
}

pub fn (s string) replace_prefix(rep string, with string) -> string {
	if !s.starts_with(rep) {
		return s
	}
	return with + s[rep.len..]
}

// count returns the number of occurrences of the given substring in the string.
//
// Example:
// ```
// 'Hello'.count('ll') == 1
// ```
pub fn (s string) count(sub string) -> usize {
	if sub.len == 0 {
		return 0
	}

	if sub.len == 1 {
		return s.count_u8(sub[0])
	}

	mut count := 0 as usize
	mut i := 0 as usize
	for i < s.len {
		if i + sub.len <= s.len && s[i..i + sub.len] == sub {
			count++
			i += sub.len
		} else {
			i++
		}
	}
	return count
}

// count_u8 returns the number of occurrences of the given byte in the string.
//
// Example:
// ```
// assert 'Hello'.count_u8(b`l`) == 2
// ```
pub fn (s string) count_u8(symbol u8) -> usize {
	mut count := 0 as usize
	for ch in s {
		if ch == symbol {
			count++
		}
	}
	return count
}

// replace_first returns a copy of the string with the first occurrence
// of `rep` replaced with `with`.
//
// Example:
// ```
// 'Hello, World'.replace_first('World', 'Earth') == 'Hello, Earth'
// 'Hello, World'.replace_first('People', 'Earth') == 'Hello, World'
// ```
pub fn (s string) replace_first(rep string, with string) -> string {
	idx := s.index(rep)
	if idx == -1 {
		return s
	}

	new_len := s.len - rep.len + with.len
	mut buf := mem.alloc(new_len + 1) as *mut u8
	unsafe {
		mem.fast_copy(buf, s.data, idx)
		mem.fast_copy(buf + idx, with.data, with.len)
		mem.fast_copy(buf + idx + with.len, s.data + idx + rep.len, s.len - idx - rep.len)
		buf[new_len] = 0
	}
	return string{
		data: buf
		len: new_len
	}
}

// clone returns a copy of the string `s`.
pub fn (s string) clone() -> string {
	if s.len == 0 {
		return ''
	}
	mut buf := mem.alloc(s.len + 1) as *mut u8
	mem.fast_copy(buf, s.data, s.len)
	unsafe {
		buf[s.len] = 0
	}
	return string{
		data: buf
		len: s.len
	}
}

// contains returns true if the string contains the given substring.
//
// Example:
// ```
// 'Hello'.contains('ell') == true
// ```
pub fn (s string) contains(sub string) -> bool {
	return s.index(sub) != -1
}

// contains_u8 returns true if the string contains the given byte.
//
// Example:
// ```
// 'Hello'.contains_u8(b`H`) == true
// ```
pub fn (s string) contains_u8(symbol u8) -> bool {
	return s.index_u8(symbol) != -1
}

// contains_any returns true if the string contains any of the specified bytes
// from the given set.
//
// Example:
// ```
// 'Hello'.contains_any('abc') == false
// 'Hello'.contains_any('abcH') == true
// ```
pub fn (s string) contains_any(set string) -> bool {
	for ch in set {
		if s.contains_u8(ch) {
			return true
		}
	}
	return false
}

// index_u8 returns the index of the first occurrence of the given byte.
//
// Example:
// ```
// 'Hi, Hannah'.index_u8(b`H`) == 0
// ```
pub fn (s string) index_u8(symbol u8) -> isize {
	// This naive implementation is slower than C memchr, so
	// we use C memchr for now.
	// for i, ch in s {
	//     if ch == symbol {
	//         return i
	//     }
	// }
	ptr := libc.memchr(s.data, symbol, s.len)
	if ptr == nil {
		return -1
	}
	return unsafe { ptr - s.data }
}

// last_index_u8 returns the index of the last occurrence of the given byte.
//
// Example:
// ```
// 'Hi, Hannah'.last_index_u8(b`H`) == 4
// ```
pub fn (s string) last_index_u8(symbol u8) -> isize {
	if intrinsics.unlikely(s.len == 0) {
		return -1
	}
	for i := (s.len - 1) as isize; i >= 0; i-- {
		if s[i] == symbol {
			return i
		}
	}
	return -1
}

// index_opt returns the index of the first occurrence of the given substring,
// or `none` if the substring is not found.
//
// Example:
// ```
// 'Hello'.index_opt('ell').unwrap() == 1
// 'Hello'.index_opt('abc') == none
// ```
pub fn (s string) index_opt(sub string) -> ?isize {
	idx := s.index(sub)
	if idx < 0 {
		return none
	}
	return idx
}

pub fn (s string) index_u8_opt(symbol u8) -> ?isize {
	idx := s.index_u8(symbol)
	if idx < 0 {
		return none
	}
	return idx
}

// index returns the index of the first occurrence of the given substring.
//
// Example:
// ```
// 'Hello'.index('ell') == 1
// ```
pub fn (s string) index(sub string) -> isize {
	if intrinsics.unlikely(sub.len == 0) {
		return -1
	}

	if sub.len == 1 {
		return s.index_u8(sub[0])
	}

	return index_str(s, sub)
}

pub fn (s string) index_after(start isize, sub string) -> isize {
	if intrinsics.unlikely(sub.len == 0) {
		return -1
	}
	index := s[start + 1..s.len].index(sub)
	if index == -1 {
		return -1
	}
	return index + start + 1
}

fn index_str1(hs string, ch u8) -> isize {
	ptr := libc.strchr(hs.c_str(), ch)
	if ptr == nil {
		return -1
	}
	return unsafe { ptr - hs.c_str() as *u8 }
}

fn index_str2(hs string, ne string) -> isize {
	mut hsi := 0
	mut h1 := ne[0] as u32 << 16 | ne[1]
	mut h2 := 0 as u32
	for c := hs[0]; h1 != h2 && c != 0; {
		h2 = h2 << 16 | c
		hsi++
		c = hs[hsi]
	}
	return if h1 == h2 { hsi - 2 } else { -1 }
}

fn index_str3(hs string, ne string) -> isize {
	mut hsi := 0
	mut h1 := ne[0] as u32 << 24 | ne[1] as u32 << 16 | ne[2] as u32 << 8
	mut h2 := 0 as u32
	for c := hs[0]; h1 != h2 && c != 0; {
		h2 = (h2 | c) << 8
		hsi++
		c = hs[hsi]
	}
	return if h1 == h2 { hsi - 3 } else { -1 }
}

fn index_str4(hs string, ne string) -> isize {
	mut hsi := 0
	mut h1 := ne[0] as u32 << 24 | ne[1] as u32 << 16 | ne[2] as u32 << 8 | ne[3] as u32
	mut h2 := 0 as u32
	for c := hs[0]; h1 != h2 && c != 0; {
		h2 = h2 << 8 | c
		hsi++
		c = hs[hsi]
	}
	return if h1 == h2 { hsi - 4 } else { -1 }
}

fn index_str(s string, sub string) -> isize {
	if intrinsics.unlikely(sub.len == 0) || intrinsics.unlikely(s.len < sub.len) {
		return -1
	}

	match sub.len {
		1 => {
			return index_str1(s, sub[0])
		}
		2 => {
			return index_str2(s, sub)
		}
		3 => {
			return index_str3(s, sub)
		}
		4 => {
			return index_str4(s, sub)
		}
	}

	if mem.compare(s.c_str(), sub.c_str(), sub.len) == 0 {
		return 0
	}

	// failthrough to KMP
	return s.index_kmp(sub)
}

// index_kmp returns the index of the first occurrence of the given substring.
// It uses the Knuth-Morris-Pratt algorithm.
pub fn (s string) index_kmp(sub string) -> isize {
	if sub.len > s.len {
		return -1
	}
	mut prefix := []usize{len: sub.len}
	mut j := 0 as usize
	for i in 1 .. sub.len {
		for sub[j] != sub[i] && j > 0 {
			j = prefix.fast_get(j - 1)
		}
		if sub[j] == sub[i] {
			j++
		}
		prefix[i] = j
	}
	j = 0
	for i in 0 .. s.len {
		for sub[j] != s[i] && j > 0 {
			j = prefix.fast_get(j - 1)
		}
		if sub[j] == s[i] {
			j++
		}
		if j == sub.len {
			return i - sub.len + 1
		}
	}
	return -1
}

pub fn (s string) last_index(sub string) -> isize {
	if intrinsics.unlikely(sub.len == 0) {
		return -1
	}

	if sub.len == 1 {
		return s.last_index_u8(sub[0])
	}

	return last_index_str(s, sub)
}

pub fn (s string) last_index_opt(sub string) -> ?isize {
	idx := s.last_index(sub)
	if idx == -1 {
		return none
	}
	return idx
}

fn last_index_str(s string, sub string) -> isize {
	if sub.len > s.len || sub.len == 0 {
		return -1
	}
	for i := (s.len - sub.len) as isize; i >= 0; i-- {
		mut j := 0 as usize
		for j < sub.len && unsafe { s.data[i + j] == sub.data[j] } {
			j++
		}
		if j == sub.len {
			return i
		}
	}
	return -1
}

// index_of_any returns the index of the first occurrence of any of the specified
// characters in the string.
//
// Example:
// ```
// 'error: expected'.index_of_any(' :') == 5
// 'error expected'.index_of_any(' :') == 5
// ```
pub fn (s string) index_of_any(chars string) -> isize {
	if s.len == 1 {
		return s.index_u8(chars[0])
	}

	for j in 0 .. s.len {
		for sch in chars {
			if s[j] == sch {
				return j
			}
		}
	}
	return -1
}

// last_index_of_any returns the index of the last occurrence if any of the specified
// characters in the string.
//
// Example:
// ```
// 'error: expected'.last_index_of_any(' :') == 6
// 'error expected'.last_index_of_any(' :') == 6
// ```
pub fn (s string) last_index_of_any(chars string) -> isize {
	if s.len == 1 {
		return s.last_index_u8(chars[0])
	}

	for j := (s.len - 1) as isize; j >= 0; j-- {
		for sch in chars {
			if s[j] == sch {
				return j
			}
		}
	}
	return -1
}

// reverse returns a copy of the string with the characters in reverse order.
//
// Note: this function takes care of UTF-8 encoding, if your string contains
// ASCII-only characters, use more efficient `reverse_ascii()` instead.
//
// Example:
// ```
// assert 'Hello'.reverse() == 'olleH'
// assert 'Привет'.reverse() == 'тевирП'
// assert 'こんにちは'.reverse() == 'はちにんこ'
// ```
pub fn (s string) reverse() -> string {
	if s.len == 0 {
		return ''
	}

	mut bytes := []u8{len: s.len}
	mut index := s.len as isize
	for r in s.runes_iter() {
		len := r.len()
		index_to_write := index - len
		utf8.encode_rune(&mut bytes[index_to_write..], r)
		index -= len
	}

	// SAFETY: bytes is heap allocated array so we can just view over it
	return string.view_from_bytes(bytes)
}

// reverse_ascii returns a copy of the string with the characters in reverse order.
// This function is optimized version of `reverse()` for ASCII strings.
// Note: this function works correctly only for ASCII strings, if the string contains
// non-ASCII characters, use `reverse()` instead.
//
// Example:
// ```
// 'Hello'.reverse_ascii() == 'olleH'
// ```
pub fn (s string) reverse_ascii() -> string {
	if s.len == 0 {
		return ''
	}

	mut new_str := string{
		data: mem.alloc(s.len)
		len: s.len
	}

	mut j := 0
	for i := (s.len - 1) as isize; i >= 0; i-- {
		unsafe {
			new_str.data[j] = s[i]
		}
		j++
	}

	return new_str
}

// split_into_lines splits the string into lines.
//
// Example:
// ```
// 'Hello\nWorld'.split_into_lines() == ['Hello', 'World']
// ```
pub fn (s string) split_into_lines() -> []string {
	return s.split('\n')
}

pub fn (s string) split_into_lines2(cap usize) -> []string {
	mut i := 0 as usize
	mut start := 0 as usize
	delim_char := b`\n`

	mut res := []string{cap: cap}

	for i < s.len {
		if s[i] == delim_char {
			res.push(s[start..i])
			start = i + 1
			i = start
		} else {
			i++
		}
	}

	if start < s.len {
		res.push(s[start..s.len])
	}
	return res
}

// split splits the string into substrings separated by the given delimiter.
//
// If the delimiter is empty, the string is split into individual characters,
// note that this is different from `bytes()` method, which returns the bytes
// not characters.
//
// Example:
// ```
// 'Hello World'.split(' ') == ['Hello', 'World']
// 'Привет'.split('') == ['П', 'р', 'и', 'в', 'е', 'т']
// ```
pub fn (s string) split(delim string) -> []string {
	if delim.len == 0 {
		return s.runes().map(|b rune| b.str())
	}

	if delim.len == 1 {
		mut i := 0 as usize
		mut start := 0 as usize
		delim_char := delim[0]

		mut res := []string{cap: 3}

		for i < s.len {
			if s[i] == delim_char {
				res.push(s.slice(start, i, false))
				start = i + 1
				i = start
			} else {
				i++
			}
		}


		
		if start < s.len {
			res.push(s.slice(start, s.len, false))
		}
		return res
	}

	mut res := []string{cap: 2}
	mut i := 0 as usize
	mut start := 0 as usize

	for i < s.len {
		
		if i + delim.len <= s.len && s[i..i + delim.len] == delim {
			res.push(s.slice(start, i, false))
			start = i + delim.len
			i = start
		} else {
			i++
		}
	}

	if start < s.len {
		res.push(s.slice(start, s.len, false))
	}
	return res
}

// split_nth splits the string into substrings separated by the given delimiter.
// The `max` parameter specifies the maximum number of substrings to return. Last
// substring will contain the rest of the string that can contain the other
// occurrences of the delimiter.
// If `max` is 0, then the result is the same as calling [`string.split()`].
//
// Example:
// ```
// '1:2:3:4'.split_nth(':', 3) == ['1', '2', '3:4']
// ```
pub fn (s string) split_nth(delim string, max usize) -> []string {
	if max == 0 {
		return s.split(delim)
	}

	if delim.len == 0 {
		mut res := []string{cap: max + 1}

		for i in 0 .. s.len.min(max - 1) {
			ch := s[i]
			res.push(ch.ascii_str())
		}

		if s.len > max {
			res.push(s.slice(max - 1, s.len, false))
		}

		return res
	}

	if delim.len == 1 {
		mut i := 0 as usize
		mut start := 0 as usize
		delim_char := delim[0]

		mut res := []string{cap: 3}

		for i < s.len {
			if s[i] == delim_char {
				was_last := res.len == max - 1
				if was_last {
					break
				}
				
				res.push(s.slice(start, i, false))
				start = i + 1
				i = start
			} else {
				i++
			}
		}

		if res.len < max {
			res.push(s.slice(start, s.len, false))
		}
		return res
	}

	mut i := 0 as usize
	mut start := 0 as usize
	mut res := []string{cap: max + 1}

	for i < s.len {
		if i + delim.len <= s.len && s[i..i + delim.len] == delim {
			was_last := res.len == max - 1
			if was_last {
				break
			}
			res.push(s.slice(start, i, false))
			start = i + delim.len
			i = start
		} else {
			i++
		}
	}

	if res.len < max {
		res.push(s.slice(start, s.len, false))
	}
	return res
}

pub fn (s string) split_once_slice(delim string) -> ?(string, string) {
	idx := s.index(delim)
	if idx == -1 {
		return none
	}
	return s[0..idx], s[idx + delim.len..s.len]
}

pub fn (s string) split_once(delim string) -> ?(string, string) {
	idx := s.index(delim)
	if idx == -1 {
		return none
	}
	return s.substr(0, idx), s.substr(idx + delim.len, s.len)
}

pub fn (s string) split_by_first(delim string) -> (string, string) {
	idx := s.index(delim)
	if idx == -1 {
		return s, ''
	}
	return s.substr(0, idx), s.substr(idx + delim.len, s.len)
}

pub fn (s string) split_by_last(delim string) -> (string, string) {
	idx := s.last_index(delim)
	if idx == -1 {
		return s, ''
	}
	return s[0..idx], s[idx + delim.len..s.len]
}

pub fn (s string) split_iter(delim string) -> SplitIterator {
	return SplitIterator{ s: s, delim: delim, pos: 0 }
}

struct SplitIterator {
	s     string
	delim string
	pos   isize
}

pub fn (it &mut SplitIterator) has_next() -> bool {
	return it.pos < it.s.len as isize
}

pub fn (it &mut SplitIterator) next() -> ?string {
	if it.pos >= it.s.len as isize {
		return none
	}

	idx := it.s.index_after(it.pos - 1, it.delim)
	if idx == -1 {
		start := it.pos
		it.pos = it.s.len
		return it.s[start..it.s.len]
	}

	start := it.pos
	it.pos = idx + it.delim.len
	return it.s[start..idx]
}

// pad_start_u8 returns a new string of length `len` with the string `s`
// padded at the start with the given `pad_char`.
//
// Example:
// ```
// 'Hello'.pad_start_u8(10, b` `) == '     Hello'
// ```
pub fn (s string) pad_start_u8(len usize, pad_char u8) -> string {
	str_runes_len := s.utf8_len()
	if len <= str_runes_len {
		return s
	}

	pad_len := len - str_runes_len
	new_len := s.len + pad_len
	new_str := mem.alloc(new_len) as *mut u8

	unsafe {
		mem.set(new_str, pad_char as i32, pad_len)
		mem.fast_copy(new_str + pad_len, s.data, s.len)
	}
	return string.view_from_c_str_len(new_str, new_len)
}

// pad_end_u8 returns a new string of length `len` with the string `s`
// padded at the end with the given `pad_char`.
//
// Example:
// ```
// 'Hello'.pad_end_u8(10, b`!`) == 'Hello!!!!!'
// ```
pub fn (s string) pad_end_u8(len usize, pad_char u8) -> string {
	str_runes_len := s.utf8_len()
	if len <= str_runes_len {
		return s
	}

	pad_len := len - str_runes_len
	new_len := s.len + pad_len
	new_str := mem.alloc(new_len) as *mut u8

	unsafe {
		mem.fast_copy(new_str, s.data, s.len)
		mem.set(new_str + s.len, pad_char as i32, pad_len)
	}
	return string.view_from_c_str_len(new_str, new_len)
}

// pad_start returns a new string of length `len` with the string `s`
// padded at the start with the given `pad_rune`.
//
// Example:
// ```
// 'Hello'.pad_start(10, ` `) == '     Hello'
// ```
//
// Note, if `pad_rune` is not ASCII, then `len` is treated as the number of
// characters, not bytes.
// Example:
// ```
// 'Hello'.pad_start(10, `😀`) == '😀😀😀😀Hello'
// 'Привет'.pad_start(10, `😀`) == '😀😀😀😀Привет'
// ```
pub fn (s string) pad_start(len usize, pad_rune rune) -> string {
	if pad_rune.is_ascii() {
		// fast path for ASCII runes
		return s.pad_start_u8(len, pad_rune as u8)
	}

	str_runes_len := s.utf8_len()
	if len <= str_runes_len {
		return s
	}

	pad_rune_bytes := pad_rune.bytes()
	pad_rune_len := pad_rune.len()
	count_new_runes := len - str_runes_len
	new_len := s.len + count_new_runes * pad_rune_len
	new_str := mem.alloc(new_len) as *mut u8

	unsafe {
		for i in 0 .. count_new_runes {
			mem.fast_copy(new_str + i * pad_rune_len, pad_rune_bytes.data, pad_rune_len)
		}
		mem.fast_copy(new_str + count_new_runes * pad_rune_len, s.data, s.len)
	}
	return string.view_from_c_str_len(new_str, new_len)
}

// pad_end returns a new string of length `len` with the string `s`
// padded at the end with the given `pad_rune`.
//
// Example:
// ```
// 'Hello'.pad_end(10, `!`) == 'Hello!!!!!'
// ```
//
// Note, if `pad_rune` is not ASCII, then `len` is treated as the number of
// characters, not bytes.
// Example:
// ```
// 'Hello'.pad_end(10, `😀`) == 'Hello😀😀😀😀😀'
// 'Привет'.pad_end(10, `😀`) == 'Привет😀😀😀😀'
// ```
pub fn (s string) pad_end(len usize, pad_rune rune) -> string {
	if pad_rune.is_ascii() {
		// fast path for ASCII runes
		return s.pad_end_u8(len, pad_rune as u8)
	}

	str_runes_len := s.utf8_len()
	if len <= str_runes_len {
		return s
	}

	pad_rune_bytes := pad_rune.bytes()
	pad_rune_len := pad_rune.len()
	if pad_rune_len < 0 {
		panic('invalid rune passed to pad_end: `${pad_rune}`')
	}

	count_new_runes := len - str_runes_len
	new_len := s.len + count_new_runes * (pad_rune_len as usize)
	new_str := mem.alloc(new_len) as *mut u8

	unsafe {
		mem.fast_copy(new_str, s.data, s.len)
		for i in 0 .. count_new_runes {
			mem.fast_copy(new_str + s.len + i * (pad_rune_len as usize), pad_rune_bytes.data, pad_rune_len as usize)
		}
	}
	return string.view_from_c_str_len(new_str, new_len)
}

// remove_surrounding returns a copy of the string with the given `prefix` and `suffix` removed.
//
// Example:
// ```
// '"Hello"'.remove_surrounding('"', '"') == 'Hello'
// ```
pub fn (s string) remove_surrounding(prefix string, suffix string) -> string {
	if (s.len >= prefix.len + suffix.len) && s.starts_with(prefix) && s.ends_with(suffix) {
		return s.substr(prefix.len, s.len - suffix.len)
	}
	return s
}

// bytes returns the bytes representation of the string.
//
// Note: for strings with non-ASCII characters, single byte may
// not represent a single character.
// For example `'😀'.bytes()` return `[0xF0, 0x9F, 0x98, 0x80]`,
// not `[0x1F600]` (which is the unicode code point of the 😀).
// To get all characters of a string, use `runes()` instead.
pub fn (s string) bytes() -> []u8 {
	if s.len == 0 {
		return []
	}

	buf := []u8{len: s.len}
	unsafe {
		mem.fast_copy(buf.data, s.data, s.len)
	}
	return buf
}

// bytes_no_copy returns string representation as a byte array without copying.
// This array should not be modified, since it is a direct reference to the
// string's memory buffer. Before any modification, the array should be cloned
// using `clone()` method.
//
// Example:
// ```
// s := 'Hello'
// func_need_bytes(s.bytes_no_copy())
// ```
#[unsafe]
pub fn (s string) bytes_no_copy() -> []u8 {
	return unsafe { Array.from_ptr_no_copy(s.data, s.len) }
}

// runes returns the runes representation of the string.
//
// Example:
// ```
// assert 'Hello'.runes() == [`H`, `e`, `l`, `l`, `o`]
// assert 'Привет'.runes() == [`П`, `р`, `и`, `в`, `е`, `т`]
// assert '😀'.runes() == [`😀`]
// ```
pub fn (s string) runes() -> []rune {
	if s.len == 0 {
		return []
	}

	mut runes := []rune{cap: s.utf8_len()}
	for i := 0 as usize; i < s.len; i++ {
		len := s[i].utf8_len()
		if len > 1 {
			// prevent out of bounds if string is not valid UTF-8
			end := (i + len).min(s.len)
			// SAFETY: this bytes array is not outliving the string,
			//         so it's safe to get bytes array without copying
			rune_bytes := unsafe { s[i..end].bytes_no_copy() }
			runes.push(utf8.decode_rune(rune_bytes))
			i += len - 1
			continue
		}

		// single ASCII character
		runes.push(s[i])
	}

	return runes
}

pub struct RunesIterator {
	s string
	i usize
}

pub fn (s string) runes_iter() -> RunesIterator {
	return RunesIterator{ s: s }
}

pub fn (it &mut RunesIterator) next() -> ?rune {
	if it.i >= it.s.len {
		return none
	}

	len := it.s[it.i].utf8_len()
	if len > 1 {
		// prevent out of bounds if string is not valid UTF-8
		end := (it.i + len).min(it.s.len)
		// SAFETY: this bytes array is not outliving the string,
		//         so it's safe to get bytes array without copying
		rune_bytes := unsafe { it.s[it.i..end].bytes_no_copy() }
		it.i += len
		return utf8.decode_rune(rune_bytes)
	}

	// single ASCII character
	it.i++
	return it.s[it.i - 1]
}

// i32 returns the integer represented of the string.
pub fn (s string) i32() -> i32 {
	return (strconv.parse_int(s, 10) or { 0 }) as i32
}

// i32_opt returns the integer represented of the string,
// or `none` if the string is not a valid integer.
pub fn (s string) i32_opt() -> ?i32 {
	if res := strconv.parse_int(s, 10) {
		return res as i32
	}
	return none
}

// i32_or returns the integer represented of the string,
// or the default value if the string is not a valid integer.
pub fn (s string) i32_or(def i32) -> i32 {
	return (strconv.parse_int(s, 10) or { def }) as i32
}

// i64 returns the integer represented of the string.
pub fn (s string) i64() -> i64 {
	return (strconv.parse_int(s, 10) or { 0 })
}

// parse_int returns the integer represented of the string,
pub fn (s string) parse_int() -> ?i64 {
	return strconv.parse_int(s, 10)
}

// parse_uint returns the integer represented of the string,
pub fn (s string) parse_uint() -> ?u64 {
	return strconv.parse_uint(s, 10)
}

pub fn (s string) f64() -> f64 {
	return (strconv.parse_float(s) or { 0.0 })
}

// bool returns the boolean represented of the string.
pub fn (s string) bool() -> bool {
	return s == 'true'
}

// TODO: make possible name methods with the same name as a field
pub fn (s string) size() -> usize {
	return s.len
}

// utf8_len returns the number of runes in the string.
// Example:
// ```
// 'Hello'.utf8_len() == 5
// ```
// Explanation:
// Since `'Hello'` contains only ASCII characters, the number of runes is equal
// to the number of bytes.
//
// Example:
// ```
// '😀'.utf8_len() == 1
// ```
// Explanation:
// Since `'😀'` contains only one emoji, the number of runes is equal to 1, and
// the number of bytes is equal to 4.
//
// Example:
// ```
// '\xF0\x9F\x98\x80'.utf8_len() == 1
// ```
// Explanation:
// '\xF0\x9F\x98\x80' is the UTF-8 representation of the emoji '😀'.
// Since this bytes sequence represents one emoji, the number of runes is
// equal to 1, while the number of bytes is equal to 4.
pub fn (s string) utf8_len() -> usize {
	mut l := 0 as usize
	mut i := 0 as usize
	for i < s.len {
		l++
		i = i + s[i].utf8_len()
	}
	return l
}

// repeat returns a new string consisting of `n` copies of the string.
//
// Example:
// ```
// 'Hello'.repeat(3) == 'HelloHelloHello'
// ```
pub fn (s string) repeat(count usize) -> string {
	if count == 0 {
		return ''
	}
	if count == 1 {
		return s
	}

	data := mem.alloc(count * s.len) as *mut u8

	for i in 0 .. count {
		unsafe {
			mem.fast_copy(data + i * s.len, s.data, s.len)
		}
	}

	return string{
		data: data
		len: count * s.len
	}
}

// is_ascii returns true if the string contains only ASCII characters.
//
// Example:
// ```
// 'Hello'.is_ascii() == true
// 'Привет'.is_ascii() == false
// ```
pub fn (s string) is_ascii() -> bool {
	for ch in s {
		if ch & 128 != 0 {
			return false
		}
	}
	return true
}

// is_blank returns true if the string contains only whitespace characters.
//
// Example:
// ```
// '  \t'.is_blank() == true
// '  \t\n'.is_blank() == true
// 'hello\n'.is_blank() == false
// ```
pub fn (s string) is_blank() -> bool {
	for ch in s {
		if !ch.is_space() {
			return false
		}
	}
	return true
}

// ident_width returns the number of spaces or tabs at the beginning of the string.
//
// Example:
// ```
// '  \tHello'.ident_width() == 3
// 'Hello'.ident_width() == 0
// ```
pub fn (s string) ident_width() -> usize {
	for i, ch in s {
		if ch != b` ` && ch != b`\t` {
			return i
		}
	}
	return 0
}

// trim_indent detects a common minimal indent of all the input lines,
// removes it from every line and also removes the first and the last
// lines if they are blank (notice difference blank vs empty).
//
// Note that blank lines do not affect the detected indent level.
//
// In case if there are non-blank lines with no leading whitespace characters
// (no indent at all) then the common indent is 0, and therefore this function
// doesn't change the indentation.
//
// Example:
// ```v
// st := '
//      Hello there,
//      this is a string,
//      all the leading indents are removed
//      and also the first and the last lines if they are blank
// '.trim_indent()
//
// st == 'Hello there,
// this is a string,
// all the leading indents are removed
// and also the first and the last lines if they are blank'
// ```
pub fn (s string) trim_indent() -> string {
	mut min_common_ident := 2_147_483_647 as usize
	for line in s.split_iter('\n') {
		if line.is_blank() {
			continue
		}
		ident := line.ident_width()
		if ident < min_common_ident {
			min_common_ident = ident
		}
	}

	mut res := []u8{cap: s.len}

	mut last_is_blank := false
	mut lines_it := s.split_iter('\n')
	for i, line in lines_it {
		is_blank := line.is_blank()

		if i == 0 && is_blank {
			// skip first line if blank
			continue
		}
		if is_blank && !lines_it.has_next() {
			// skip last line if blank
			last_is_blank = true
			continue
		}

		if is_blank {
			res.push(b`\n`)
			continue
		}

		line_without_ident := line[min_common_ident..]
		res.push_ptr(line_without_ident.c_str(), line_without_ident.len)
		if !!lines_it.has_next() {
			res.push(b`\n`)
		}
	}

	if last_is_blank && res.len > 0 {
		res.remove_last()
	}

	res.push(0)
	return string.view_from_c_str_len(res.data, res.len - 1)
}

// trim_spaces returns a copy of the string with all leading and trailing
// whitespace characters removed. Whitespace characters are:
// space, tab, newline, vertical tab, form feed, carriage return.
//
// Example:
// ```
// '  \tHello\n'.trim_spaces() == 'Hello'
// ```
pub fn (s string) trim_spaces() -> string {
	return s.trim(' \n\t\v\f\r')
}

// trim returns a copy of the string with all leading and trailing
// characters contained in `cutset` removed.
//
// Example:
// ```
// '  (Hello)  '.trim('() ') == 'Hello'
// ```
pub fn (s string) trim(cutset string) -> string {
	if s.len == 0 || cutset.len == 0 {
		return cutset
	}

	left, right := s.trim_indexes(cutset)
	return s.substr(left, right)
}

// trim_indexes acts like `trim()` but returns the indexes by which the string
// was trimmed.
//
// Example:
// ```
// '  (Hello)  '.trim_indexes('() ') == (2, 8)
// ```
//
// Resulting indexes can be used to get the trimmed string:
// ```
// s := '  (Hello)  '
// left, right := s.trim_indexes('() ')
// trimmed := s[left..right]
// assert trimmed == 'Hello'
// ```
pub fn (s string) trim_indexes(cutset string) -> (usize, usize) {
	mut left := 0 as isize
	mut right := (s.len - 1) as isize
	mut any_match := true

	for left < s.len as isize && right >= 0 && any_match {
		any_match = false

		for ch in cutset {
			if s[left] == ch {
				left++
				any_match = true
			}

			if s[right] == ch {
				right--
				any_match = true
			}

			if any_match {
				break
			}
		}

		if left > right {
			return 0, 0
		}
	}

	return left as usize, (right + 1) as usize
}

// trim_start returns a copy of the string with all leading
// characters contained in `cutset` removed.
//
// Example:
// ```
// '  (Hello)  '.trim_start('() ') == 'Hello)  '
// ```
pub fn (s string) trim_start(cutset string) -> string {
	if s.len == 0 || cutset.len == 0 {
		return s
	}

	mut left := 0 as isize

	for left < s.len as isize {
		mut any_match := false

		for ch in cutset {
			if s[left] == ch {
				left++
				any_match = true
				break
			}
		}

		if !any_match {
			break
		}
	}

	return s.substr(left as usize, s.len)
}

// trim_end returns a copy of the string with all trailing
// characters contained in `cutset` removed.
//
// Example:
// ```
// '  (Hello)  '.trim_end('() ') == '  (Hello'
// ```
pub fn (s string) trim_end(cutset string) -> string {
	if s.len == 0 || cutset.len == 0 {
		return s
	}

	mut right := (s.len - 1) as isize

	for right >= 0 {
		mut any_match := false

		for ch in cutset {
			if s[right] == ch {
				right--
				any_match = true
				break
			}
		}

		if !any_match {
			break
		}
	}

	return s.substr(0, (right + 1) as usize)
}

pub fn (s string) all_after(sub string) -> string {
	idx := s.index(sub)
	if idx == -1 {
		return s
	}
	return s.substr(idx + sub.len, s.len)
}

pub fn (s string) all_after_last(sub string) -> string {
	idx := s.last_index(sub)
	if idx == -1 {
		return s
	}
	return s.substr(idx + sub.len, s.len)
}

pub fn (s string) all_before(sub string) -> string {
	idx := s.index(sub)
	if idx == -1 {
		return s
	}
	return s.substr(0, idx)
}

// at returns the byte at the given index.
// If the index is out of bounds, then it returns `none`.
pub fn (s string) at(i usize) -> ?u8 {
	if i >= s.len {
		return none
	}
	return s[i]
}

// fast_at returns the byte at the given index.
// If the index is out of bounds, behavior is undefined.
#[unsafe]
pub fn (s string) fast_at(i usize) -> u8 {
	return s[i]
}

// rune_at returns the rune at the given index.
// If the index is out of bounds, then it returns `none`.
//
// Example:
// ```
// assert "こんにちは".rune_at(1).unwrap() == `ん`
// assert "привет".rune_at(4).unwrap() == `в`
// ```
pub fn (s string) rune_at(ia usize) -> ?rune {
	if ia >= s.len {
		return none
	}

	mut count := 0
	for i := 0 as usize; i < s.len; i++ {
		len := s[i].utf8_len()
		if len > 1 {
			// prevent out of bounds if string is not valid UTF-8
			end := (i + len).min(s.len)
			// SAFETY: this bytes array is not outliving the string,
			//         so it's safe to get bytes array without copying
			rune_bytes := unsafe { s[i..end].bytes_no_copy() }

			if ia == count {
				return utf8.decode_rune(rune_bytes)
			}

			i += len - 1
			count++
			continue
		}

		if ia == count {
			// ASCII
			return s[i]
		}
		count++
	}

	return none
}

// all returns `true` if the provided callback function returns `true`
// for all bytes in the string. If any byte does not satisfy the callback
// function, it returns `false`.
//
// Example:
// ```
// str := "hello world"
// assert str.all(|b| b.is_lower)
// assert str.all(|b| b.is_digit) == false
// ```
pub fn (s string) all(cb fn (_ u8) -> bool) -> bool {
	for ch in s {
		if !cb(ch) {
			return false
		}
	}
	return true
}

// map_bytes applies the provided callback function to each byte of the string and
// returns a new string containing the results. The original string remains unmodified.
//
// Example:
// ```
// assert 'hello world'.map_bytes(|b| b.to_upper()) == 'HELLO WORLD'
// ```
#[must_use("map_bytes returns a new string without modifying the original")]
pub fn (s string) map_bytes(cb fn (el u8) -> u8) -> string {
	mut new_str := string{
		data: mem.alloc(s.len)
		len: s.len
	}
	for i, ch in s {
		new_str[i] = cb(ch)
	}
	return new_str
}

// to_upper returns a new string with all the ASCII letters in uppercase.
//
// IMPORTANT NOTE: This function work only with ASCII! See [`strings.to_upper`]
// if you need UTF-8 support.
//
// Example:
// ```
// assert "hello".to_upper() == "HELLO"
// assert "こんにちは".to_upper() == "こんにちは" // remains the same, non-ASCII
// ```
pub fn (s string) to_upper() -> string {
	mut already_upper := true
	for ch in s {
		if ch.is_lower() {
			already_upper = false
			break
		}

		if !ch.is_ascii() {
			// return UTF-8 string as is
			return s
		}
	}

	if already_upper {
		// fast path, already uppercase
		return s
	}

	return s.map_bytes(|b| b.to_upper())
}

// to_lower returns a new string with all the ASCII letters in lowercase.
//
// IMPORTANT NOTE: This function work only with ASCII! See [`strings.to_lower`]
// if you need UTF-8 support.
//
// Example:
// ```
// assert "HELLO".to_lower() == "hello"
// assert "こんにちは".to_lower() == "こんにちは" // remains the same, non-ASCII
// ```
pub fn (s string) to_lower() -> string {
	mut already_lower := true
	for ch in s {
		if ch.is_capital() {
			already_lower = false
			break
		}

		if !ch.is_ascii() {
			// return UTF-8 string as is
			return s
		}
	}

	if already_lower {
		// fast path, already lowercase
		return s
	}

	return s.map_bytes(|b| b.to_lower())
}

pub struct StringIterator {
	s string
	i isize
}

pub fn (s string) iter() -> &mut StringIterator {
	return &mut StringIterator{
		s: s
		i: -1
	}
}

pub fn (it &mut StringIterator) next() -> ?u8 {
	it.i++
	if it.i >= it.s.len {
		return none
	}
	return it.s[it.i]
}

pub fn (it &StringIterator) find_first(cond fn (ch u8) -> bool) -> ?u8 {
	for ch in *it {
		if cond(ch) {
			return ch
		}
	}
	return none
}

pub struct BackStringIterator {
	s string
	i isize
}

pub fn (s string) back_iter() -> &mut BackStringIterator {
	return &mut BackStringIterator{
		s: s
		i: s.len as isize
	}
}

pub fn (it &mut BackStringIterator) next() -> ?u8 {
	it.i--
	if it.i < 0 {
		return none
	}
	return it.s[it.i]
}

pub fn (it &mut BackStringIterator) find_first(cond fn (ch u8) -> bool) -> ?u8 {
	for ch in *it {
		if cond(ch) {
			return ch
		}
	}
	return none
}

// c_str returns a null-terminated pointer to u8 array that
// can be used as a C string.
//
// Note: strings are immutable, if you pass result of this method
// to a C function, make sure that the C function does not modify
// the string, otherwise it will cause undefined behavior.
// If you need to pass a string to a C function that modifies it,
// use `s.clone().c_str()`.
pub fn (s string) c_str() -> &u8 {
	if intrinsics.unlikely(s[s.len] != 0) {
		cloned := s.clone()
		return unsafe { &*cloned.data }
	}
	return unsafe { &*s.data }
}

// msg returns the string itself.
// This is useful when you need to use string as Error for Result.
pub fn (s string) msg() -> string {
	return s
}

// hash returns the hash of the given string.
pub fn (s string) hash() -> u64 {
	mut h := 5381 as u32
	for ch in s {
		h = h.wrapping_mul(33) + ch
	}
	return h
}

// str returns the string itself.
pub fn (s string) str() -> string {
	return s
}

// debug_str returns the string itself.
pub fn (s string) debug_str() -> string {
	return s
}

// view_from_c_str converts C null-terminated string to a Spawn string.
//
// Note that the underlying memory is not copied, so the resulting
// string is only valid as long as the C string is valid.
//
// If you are absolutely sure that the resulting C string will not live longer
// than the created this one, calling this method is safe and allows you to avoid
// unnecessary allocations.
//
// If you save the result of this function in some long-lived object, this may be
// unsafe and it is better to use method [`string.view_from_c_str`].
//
// If passed pointer is null, then empty string is returned.
//
// Example:
// ```
// c_str := get_c_string()
// str := string.view_from_c_str(c_str)
// ```
pub fn string.view_from_c_str(s *u8) -> string {
	if s == nil {
		return ''
	}
	return string{ data: s, len: libc.strlen(s) }
}

// view_from_c_str_len converts C string to a Spawn string.
//
// Since the length is passed as the second argument, the С string need not be
// null terminated, but the length must not be greater than the allocated area,
// otherwise the behavior is undefined.
//
// Note that the underlying memory is not copied, so the resulting
// string is only valid as long as the C string is valid.
//
// If you are absolutely sure that the resulting C string will not live longer
// than the created this one, calling this method is safe and allows you to avoid
// unnecessary allocations.
//
// If you save the result of this function in some long-lived object, this may be
// unsafe and it is better to use method [`string.view_from_c_str`].
//
// If passed pointer is null, then empty string is returned.
//
// Example:
// ```
// c_str := get_c_string()
// str := string.view_from_c_str_len(c_str, 5)
// ```
pub fn string.view_from_c_str_len(s *u8, len usize) -> string {
	if s == nil {
		return ''
	}
	return string{ data: s, len: len }
}

// from_c_str copy and converts C null-terminated string to a Spawn string.
//
// Note that the underlying memory is copied, so the resulting
// string is valid even if the C string is freed.
//
// See [`string.view_from_c_str`] to create a string from pointer to
// underlying memory without copying.
//
// If passed pointer is null, then empty string is returned.
//
// Example:
// ```
// c_str := get_c_string()
// str := string.from_c_str(c_str)
// ```
pub fn string.from_c_str(s *u8) -> string {
	return string.view_from_c_str(s).clone()
}

// from_runes converts an array of runes to a string.
pub fn string.from_runes(s []rune) -> string {
	if s.len == 0 {
		return ''
	}

	len := s.reduce(0 as usize, |acc usize, r rune| acc + r.len())
	mut bytes := []u8{len: len}

	mut index := 0 as isize
	for r in s {
		utf8.encode_rune(&mut bytes[index..], r)
		index += r.len()
	}

	// SAFETY: bytes is heap allocated array so we can just view over it
	return string.view_from_bytes(bytes)
}

// from_bytes converts an array of bytes to a string.
pub fn string.from_bytes(s []u8) -> string {
	return string.view_from_c_str_len(s.raw(), s.len).clone()
}

// view_from_bytes converts an array of bytes to a string.
//
// The passed array will be used as backed data for this string,
// so any changes to the array will change the string.
// Be careful and only use this method when the string is used
// temporarily.
pub fn string.view_from_bytes(s []u8) -> string {
	return string.view_from_c_str_len(s.raw(), s.len)
}

// str_interp is internal function used by the compiler to implement string interpolation.
// It is not intended to be used directly.
//
// Example:
// ```
// 'Hello ${name}, you are ${age} years old'
// ```
// Converts to:
// ```
// str_interp(5, ['Hello ', name, ', you are ', age.str(), ' years old'])
// ```
//
// Note that array is passed as C fixed size array via pointer. Since this array
// lives no longer than a function call, it can be safely passed as a pointer.
fn str_interp(count usize, data *string) -> string {
	mut len := 0 as usize
	for i in 0 .. count {
		len = len + unsafe { data[i] }.len
	}

	mut shift := 0 as usize
	mut arr := []u8{len: len + 1}
	for i in 0 .. count {
		unsafe {
			mem.fast_copy(arr.data + shift, data[i].data, data[i].len)
			shift += data[i].len
		}
	}

	// We don't need to add null-terminator here, `arr` already zero-initialized.
	// arr[len] = 0

	return string{ data: arr.raw(), len: len }
}
