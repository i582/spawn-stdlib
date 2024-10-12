module testing

import fs
import term
import diff
import strings
import text

pub interface Assertable {
	Equality
	Display
}

fn (t &mut Tester) on_assert() {
	t.assert_count++
}

fn (t &mut Tester) count_asserts() -> usize {
	return t.assert_count
}

#[test_helper]
pub fn (t &mut Tester) assert_eq[T: Assertable](a T, b T, msg string) {
	t.on_assert()
	if a == b {
		return
	}

	t.eq_fail(a.str(), b.str(), msg)
}

#[test_helper]
fn (t &mut Tester) eq_fail(a string, b string, msg string) {
	diff_res := diff.colored_diff(diff.compare(a, b))
	left := term.yellow(text.indent_text(a, 6, true))
	right := term.cyan(text.indent_text(b, 6, true))

	t.fail('
left is not equal to right: ${msg}
   left: ${left}
  right: ${right}

${diff_res}

${term.gray("Note: +++ describes parts that should be added to the right to make it equal\n      --- describes parts that should be removed from the right to make it equal")}
'.trim_indent())
}

fn get_context_line(loc Location) -> string {
	mut sb := strings.new_builder(100)
	file_content := fs.read_file(string.view_from_c_str(loc.file)) or { return '' }
	lines := file_content.split_into_lines()
	prev_prev_line := lines.get(loc.line - 3) or { '' }
	prev_line := lines.get(loc.line - 2) or { '' }
	line := lines.get(loc.line - 1) or { return '' }
	line_number_len := loc.line.str().len

	prev_prev_start := format_line_number((loc.line - 2).str(), line_number_len)
	prev_start := format_line_number((loc.line - 1).str(), line_number_len)
	start := format_line_number(loc.line.str(), line_number_len)
	next_start := format_line_number('~'.repeat(line_number_len), line_number_len)

	sb.write_str('\x1b[90m')
	sb.write_str(prev_prev_start)
	sb.write_str(' ')
	sb.write_str(prev_prev_line)
	sb.write_str('\n')
	sb.write_str(prev_start)
	sb.write_str(' ')
	sb.write_str(prev_line)
	sb.write_str('\n')
	sb.write_str(start)
	sb.write_str('\x1b[39m')
	sb.write_str(' ')
	sb.write_str(line)
	sb.write_str('\x1b[90m')
	sb.write_str('\n')
	sb.write_str(next_start)
	sb.write_str(' '.repeat(loc.col - 1))
	sb.write_str('\x1b[39m')
	sb.write_str(term.bright_red('^'))
	sb.write_str('\n')
	return sb.str_view()
}

fn format_line_number(num string, len usize) -> string {
	padding := b` `.repeat(len - num.len)
	return ' ${num}${padding} |'
}

#[test_helper]
pub fn (t &mut Tester) assert_ne[T: Assertable](a T, b T, msg string) {
	t.on_assert()
	if a != b {
		return
	}
	left := term.yellow(text.indent_text(a.str(), 6, true))
	right := term.cyan(text.indent_text(b.str(), 6, true))

	t.fail('
left is equal to right, but should not: ${msg}
   left: ${left}
  right: ${right}
'.trim_indent())
}

#[test_helper]
pub fn (t &mut Tester) assert_opt_eq[T: Assertable](a ?T, b T, msg string) {
	t.on_assert()
	a_val := a or {
		t.fail('left is none: ${msg}')
		return
	}
	t.assert_eq(a_val, b, msg)
}

#[test_helper]
pub fn (t &mut Tester) assert_less[T](a T, b T, msg string) where T: Ordered {
	t.on_assert()
	if a < b {
		return
	}

	t.fail('left is greater than or equal to right: ${msg}')
}

#[test_helper]
pub fn (t &mut Tester) assert_greater[T](a T, b T, msg string) where T: Ordered {
	t.on_assert()
	if a > b {
		return
	}

	t.fail('left is less than or equal to right: ${msg}')
}

#[test_helper]
pub fn (t &mut Tester) assert_ge[T](a T, b T, msg string) where T: Ordered {
	t.on_assert()
	if a < b {
		t.fail('left is less than right: ${msg}')
		return
	}
}

#[test_helper]
pub fn (t &mut Tester) assert_le[T](a T, b T, msg string) where T: Ordered {
	t.on_assert()
	if a > b {
		t.fail('left is greater than right: ${msg}')
		return
	}
}

#[test_helper]
pub fn (t &mut Tester) assert_true(a bool, msg string) {
	t.on_assert()
	if !a {
		t.fail("expected true, but got false: ${msg}")
	}
}

#[test_helper]
pub fn (t &mut Tester) assert_false(a bool, msg string) {
	t.on_assert()
	if a {
		t.fail("expected false, but got true: ${msg}")
	}
}

#[test_helper]
pub fn (t &mut Tester) assert_none[T](a ?T, msg string) {
	t.on_assert()
	if a != none {
		t.fail("expected none, but got value: ${msg}")
	}
}

#[test_helper]
pub fn (t &mut Tester) assert_not_none[T](a ?T, msg string) {
	t.on_assert()
	if a == none {
		t.fail("expected value, but got none: ${msg}")
	}
}
