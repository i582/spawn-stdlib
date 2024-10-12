module regex

import term
import strings

pub struct Regex {
	pattern          string
	subpattern_count i32

	re *pcre2_code
}

pub fn must_compile(pattern string) -> Regex {
	re := compile(pattern) or {
		panic(err.formatted())
	}
	return re
}

pub fn compile(pattern string) -> ![Regex, CompileError] {
	mut err_code := 0
	mut err_offset := 0 as usize
	re := pcre2_compile(pattern.data, pattern.len, 0, &mut err_code, &mut err_offset, nil)
	if re == nil {
		return error(CompileError.new('pcre2_compile()', pattern, err_code, err_offset as i32))
	}

	mut capture_count := 0
	err_code = pcre2_pattern_info(re, PCRE2_INFO_CAPTURECOUNT, &mut capture_count)
	if err_code != 0 {
		return error(CompileError.new('pcre2_pattern_info()', pattern, err_code, -1))
	}
	return Regex{
		pattern: pattern
		subpattern_count: capture_count
		re: re
	}
}

pub struct MatchData {
	subject string
	ovector []usize
}

pub fn (d MatchData) get(index usize) -> ?string {
	if index >= d.ovector.len / 2 {
		return none
	}
	start := d.ovector[index * 2]
	end := d.ovector[index * 2 + 1]
	if start == MAX_USIZE {
		return none
	}

	return d.subject.substr(start, end)
}

pub fn (d MatchData) get_with_offset(index usize) -> ?(string, usize) {
	if index >= d.ovector.len / 2 {
		return none
	}
	start := d.ovector[index * 2]
	end := d.ovector[index * 2 + 1]
	return d.subject.substr(start, end), start
}

pub fn (d MatchData) get_all() -> []string {
	match_count := d.ovector.len / 2
	mut matches := []string{len: match_count}
	for i in 0 .. match_count {
		matches[i] = d.get(i) or { '' }
	}
	return matches
}

pub fn (r Regex) matches(subject string) -> bool {
	match_data := pcre2_match_data_create_from_pattern(r.re, nil)
	count := pcre2_match(r.re, subject.data, subject.len, 0, 0, match_data, nil)
	pcre2_match_data_free(match_data)
	return count > 0
}

pub fn (r Regex) find_match(subject string, pos usize) -> ?MatchData {
	match_data := pcre2_match_data_create_from_pattern(r.re, nil)
	defer pcre2_match_data_free(match_data)

	count := pcre2_match(r.re, subject.data, subject.len, pos, 0, match_data, nil)
	if count == 0 {
		panic('find_match(): ovector was not big enough for all the captured substrings, should never happen')
	}
	if count < 0 {
		if count == PCRE2_ERROR_NOMATCH {
			return none
		}
		return none
	}

	ovector_ptr := pcre2_get_ovector_pointer(match_data)
	ovector_size := ((r.subpattern_count + 1) * 2) as usize
	mut ovector := []usize{len: ovector_size}
	for i in 0 .. ovector_size {
		unsafe {
			ovector[i] = ovector_ptr[i]
		}
	}

	return MatchData{
		subject: subject
		ovector: ovector
	}
}

pub fn (r Regex) find_n_matchdata(subject string, n i32) -> []MatchData {
	mut res := []MatchData{}
	mut pos := 0 as usize
	mut count := 0
	for count < n || n < 0 {
		m := r.find_match(subject, pos) or { break }
		res.push(m)
		pos = m.ovector[1]
		count++
	}
	return res
}

pub fn (r Regex) find_n(subject string, n i32) -> []string {
	mut res := []string{}
	for m in r.find_n_matchdata(subject, n) {
		res.push(m.get(0) or { '' })
	}
	return res
}

pub fn (r Regex) find_all(subject string) -> []string {
	return r.find_n(subject, -1)
}

struct CompileError {
	prefix     string
	pattern    string
	error_code i32
	offset     i32
}

pub fn CompileError.new(prefix string, pattern string, error_code i32, offset i32) -> CompileError {
	return CompileError{
		prefix: prefix
		pattern: pattern
		error_code: error_code
		offset: offset
	}
}

pub fn (e CompileError) msg() -> string {
	return get_error_message(e.prefix, e.pattern, e.error_code, e.offset)
}

pub fn (e CompileError) formatted() -> string {
	buffer := []u8{len: 1024}
	pcre2_get_error_message(e.error_code, buffer.data, buffer.len)
	err_msg := string.from_c_str(buffer.data)
	mut msg := strings.new_builder(100)

	error_label := term.bold(term.bright_red('error'))
	msg.write_str('${e.prefix}: ${error_label}: ${err_msg} (code ${e.error_code})')
	if e.offset < 0 || e.offset as usize > e.pattern.len {
		msg.write_str('\n')
		msg.write_str(term.yellow(' >'))
		msg.write_str('  ')
		msg.write_str(e.pattern)
		return msg.str_view()
	}
	msg.write_str(' at offset ${e.offset}\n')
	msg.write_str('   |\n')
	msg.write_str(term.yellow(' > | '))
	msg.write_str(e.pattern.substr(0, e.offset))
	if (e.offset + 1) as usize < e.pattern.len {
		msg.write_str(term.bright_red(e.pattern[e.offset].ascii_str()))
		msg.write_str(e.pattern.substr(e.offset + 1, e.pattern.len))
	}
	msg.write_str('\n   | ')
	msg.write_str(' '.repeat(e.offset as usize))
	msg.write_str(term.bright_red('^'))
	return msg.str_view()
}

pub fn get_error_message(prefix string, pattern string, error_code i32, offset i32) -> string {
	buffer := []u8{len: 1024}
	pcre2_get_error_message(error_code, buffer.data, buffer.len)
	err_msg := string.from_c_str(buffer.data)
	if offset < 0 {
		return '${prefix}: pattern: "${pattern}", error: ${err_msg} (code ${error_code})'
	}

	return '${prefix}: pattern: "${pattern}", error: ${err_msg} at offset ${offset} (code ${error_code})'
}
