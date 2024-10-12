module testing

import time
import fs
import strings
import term

pub struct Case {
	name     string
	code     string
	expected string
	skip     bool
	actual   string
	failed   bool
	line     usize
}

pub struct Suit {
	t &mut Tester

	// name is the name of the test suite
	name string

	// run_test is a function that runs a test case and
	// returns the actual output
	run_test fn (c Case) -> string

	// count_tests is the number of test cases in the suite
	count_tests usize

	// duration is the time it took to run the test suite
	duration time.Duration

	// compact sets to true to print less output
	compact bool = true

	// update_tests sets to true to update the expected output
	// of the test cases. Changes the test files.
	update_tests bool
}

pub fn Suit.create(t &mut Tester, name string, run_test fn (c Case) -> string) -> &mut Suit {
	return &mut Suit{
		t: t
		name: name
		run_test: run_test
		update_tests: true
	}
}

pub fn Suit.parse_test_file(path string) -> ![]Case {
	content := fs.read_file(path)!
	return Suit.parse_tests(content)
}

pub fn (s &mut Suit) run_test_in_dir(path string) -> ! {
	watch := time.new_stopwatch()

	colored_name := term.black(term.bg_blue(' ${s.name} '))
	print('Running ${colored_name.pad_end(25, ` `)}\n')
	fs.flush_stdout()

	mut count_tests := 0 as usize
	mut need_fail := false

	it := fs.read_dir_iter(path)!
	for entry in it {
		test_filepath := entry.path()
		if fs.is_dir(test_filepath) {
			continue
		}

		cases := s.run_test_in_file(test_filepath)
		count_tests += cases.len

		if s.update_tests {
			Suit.save_test_cases(test_filepath, cases)
		}

		if cases.any(|case| case.failed) {
			need_fail = true
		}
	}

	if count_tests == 0 {
		return error('no test files found in ${path}')
	}

	if need_fail {
		s.t.fail('some test failed')
	}

	elapsed := watch.elapsed()

	s.count_tests = count_tests
	s.duration = elapsed

	print('Finished ')

	colored_count := term.bold(' ${count_tests} ')
	print('${colored_count.pad_start(15, ` `)} ')

	println(term.gray(' ${elapsed} '))
	println()
	fs.flush_stdout()
}

fn (s &mut Suit) run_test_in_file(path string) -> []Case {
	mut cases := Suit.parse_test_file(path) or { panic("cannot parse test file: ${path}: ${err.msg()}") }

	for mut case in cases {
		if case.skip {
			if !s.compact {
				println('${term.yellow('⚠')} ${case.name} skipped')
			}
			continue
		}

		// TODO: set_custom_location

		s.t.run(case.name, fn (tst &mut Tester) {
			actual := s.run_test(*case).trim_spaces()
			if actual != case.expected {
				case.actual = actual
				case.failed = true

				tst.assert_eq(actual, case.expected, "actual must be equal to expected")
				return
			}

			if !s.compact {
				println('${term.green('✓')} ${case.name}')
				fs.flush_stdout()
			}
		})
	}

	return cases
}

enum State {
	start
	test_name
	test_code
	test_expected
}

pub fn Suit.parse_tests(content string) -> ![]Case {
	lines := content.split_into_lines()
	mut cases := []Case{}
	mut name := ''
	mut code := ''
	mut expected_data := ''
	mut state := State.start

	for i, line in lines {
		if line.starts_with('===') {
			if state == .start {
				state = .test_name
			} else if state == .test_name {
				state = .test_code
			} else if state == .test_expected {
				cases.push(Case{
					name: name.trim_spaces()
					code: code.trim_spaces()
					expected: expected_data.trim_spaces()
					skip: name.contains('@skip')
					line: i as usize
				})
				name = ''
				code = ''
				expected_data = ''

				state = .test_name
			}
			continue
		}

		if line.starts_with('---') {
			if state == .test_code {
				state = .test_expected
			}
			continue
		}

		if state == .test_name {
			name = name + line + '\n'
		}

		if state == .test_code {
			code = code + line + '\n'
		}

		if state == .test_expected {
			expected_data = expected_data + line + '\n'
		}
	}

	if name != '' {
		cases.push(Case{
			name: name.trim_spaces()
			code: code.trim_spaces()
			expected: expected_data.trim_spaces()
			skip: name.contains('@skip')
		})
	}

	return cases
}

fn Suit.save_test_cases(path string, cases []Case) {
	mut content := strings.new_builder(1000)

	for i, case in cases {
		if i != 0 {
			content.write_str('\n')
		}
		content.write_str('==========================================================\n')
		content.write_str(case.name)
		content.write_str('\n==========================================================\n')
		content.write_str(case.code)
		content.write_str('\n----------------------------------------------------------\n')
		if case.failed {
			content.write_str(case.actual)
		} else {
			content.write_str(case.expected)
		}
		content.write_str('\n')
	}

	fs.write_file(path, content.str()) or { panic('failed to write file: ${path}') }
}
