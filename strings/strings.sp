module strings

// max_common_prefix returns the longest common prefix of the given strings.
// If there is no common prefix, the empty string is returned.
//
// Example:
// ```
// max_common_prefix(['foo', 'foobar', 'foobaz']) == 'foo'
// max_common_prefix(['foo', 'bar', 'baz']) == ''
// ```
pub fn max_common_prefix(strs []string) -> string {
	if strs.len == 0 {
		return ''
	}

	// MAX_U32 should be large enough for any string length.
	mut min_len := MAX_U32 as usize
	for str in strs {
		if str.len < min_len {
			min_len = str.len
		}
	}

	if min_len == 0 {
		return ''
	}

	mut prefix := new_builder(min_len)

	first_str := strs[0]
	for i in 0 .. min_len {
		c := first_str[i]
		for str in strs {
			if str[i] != c {
				return prefix.str_view()
			}
		}
		prefix.write_u8(c)
	}

	return prefix.str_view()
}
