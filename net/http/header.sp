module http

import bufio
import strings

// This file contains a description of how to store headers that are
// received or will be sent via HTTP.

// KV represents simple key-value.
pub struct KV {
	key   string
	value string
}

// Headers represents the key-value pairs in an HTTP header.
pub struct Headers {
	headers [50]KV
	len     usize
}

// new creates a new [`Headers`] instance with passed key-values.
//
// [`kv`] must have an even number of elements, otherwise the
// function will panic.
pub fn Headers.new(kv ...string) -> Headers {
	if kv.len % 2 != 0 {
		panic("headers must be key-value pairs")
	}

	mut headers := Headers{}
	for i in 0 .. kv.len / 2 {
		headers.set(kv[i * 2], kv[i * 2 + 1])
	}
	headers.len = kv.len
	return headers
}

// clear clears all headers.
pub fn (h &mut Headers) clear() {
	h.len = 0
}

// set adds a new key-value to [`Headers`], does not overwrite the previous value.
// TODO: why??
pub fn (h &mut Headers) set(key string, value string) {
	h.headers[h.len] = KV{ key: key, value: value }
	h.len++
}

// get gets the first value associated with the given [`key`]. If
// there are no values associated with the [`key`], [`get`] returns none.
//
// If [`exact`] is false, [`get`] performs a case-insensitive search.
pub fn (h &Headers) get(key string, exact bool) -> ?string {
	if exact {
		for i in 0 .. h.len {
			if h.headers[i].key == key {
				return h.headers[i].value
			}
		}
		return none
	}

	for i in 0 .. h.len {
		if h.headers[i].key.equal_ignore_case(key) {
			return h.headers[i].value
		}
	}
	return none
}

// contains check if there is any value for [`key`].
//
// Example:
// ```
// headers := http.Headers.new('Host', 'example.com')
// if 'Host' !in headers {
//     headers.set('Host', 'example.com')
// }
// ```
pub fn (h &Headers) contains(key string) -> bool {
	for i in 0 .. h.len {
		if h.headers[i].key.equal_ignore_case(key) {
			return true
		}
	}
	return false
}

// str returns a string with the key-value in each row.
pub fn (h &Headers) str() -> string {
	mut sb := strings.new_builder(100)
	for i in 0 .. h.len {
		sb.write_str(h.headers[i].key)
		sb.write_str(": ")
		sb.write_str(h.headers[i].value)
		sb.write_str("\n")
	}
	return sb.str_view()
}

// render_to writes headers to give builder in key-value format in each row.
pub fn (h &Headers) render_to(sb &mut strings.Builder) {
	for i in 0 .. h.len {
		sb.write_str(h.headers[i].key)
		sb.write_str(": ")
		sb.write_str(h.headers[i].value)
		sb.write_str("\n")
	}
}

// parse_headers_from_reader reads and parses all key values up to `\r\n\r\n`
// from given reader.
pub fn parse_headers_from_reader(r &mut bufio.Reader) -> !Headers {
	mut headers := Headers{}

	mut header_line, _ := r.read_line()!

	for header_line.len > 0 {
		last_key, last_value := parse_header(string.view_from_bytes(header_line))!
		headers.set(last_key, last_value)

		header_line, _ = r.read_line()!
	}

	return headers
}

// parse_headers parses key-value fromat from given [`data`] string.
pub fn parse_headers(data string) -> !Headers {
	mut headers := Headers{}

	mut last_key := ""
	mut last_value := ""

	for line in data.split_iter('\n') {
		if line.len == 0 {
			break
		}
		last_key, last_value = parse_header(line)!
		headers.set(last_key, last_value)
	}

	return headers
}

fn parse_header(line string) -> !(string, string) {
	mut key_end := 0 as usize
	mut value_start := 0 as usize
	mut value_end := line.len

	for i, c in line {
		if c == b`:` {
			key_end = i
			break
		}
	}

	if key_end == 0 {
		// no colon found
		return error("missing colon in header")
	}

	for i in key_end + 1 .. line.len {
		if line[i] != b` ` {
			value_start = i
			break
		}
	}

	if line[line.len - 1] == b` ` {
		// trim any possible spaces at the end
		for i := (line.len - 1) as isize; i >= 0; i-- {
			if line[i] != b` ` {
				value_end = i
				break
			}
		}
	}

	return line[0..key_end].clone(), line[value_start..value_end].clone()
}
