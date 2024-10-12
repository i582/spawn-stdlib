module testing

import time
import term
import strings
import fs

enum TestStatus {
	ok
	failed
	skipped
}

struct TestResult {
	tester   &mut Tester
	duration time.Duration
	status   TestStatus
	loc      Location
	msg      string
}

fn (r TestResult) msg_without_colors() -> string {
	return term.strip_ansi(r.msg)
}

interface FileReporter {
	fn save(self, t &Tester, path string) -> ![unit, fs.FsError]
}

struct BaseFileReporter {}

fn (_ BaseFileReporter) save(t &Tester, _ string) -> ![unit, fs.FsError] {}

struct JUnitReporter {}

fn (_ JUnitReporter) save(t &Tester, path string) -> ![unit, fs.FsError] {
	mut sb := strings.new_builder(100)

	sb.write_str('<?xml version="1.0" encoding="UTF-8"?>\n')
	sb.write_str('<testsuites>\n')

	mut global_suite := strings.new_builder(100)

	for sub in t.subs {
		if sub.subs.len == 0 {
			JUnitReporter.single_test(&mut global_suite, sub, 1)
			continue
		}
	}

	sb.write_str(global_suite.str())

	for sub in t.subs {
		if sub.subs.len == 0 {
			continue
		}
		JUnitReporter.group(&mut sb, sub, 1)
	}
	sb.write_str('</testsuites>\n')

	fs.write_file(path, sb.str())!
}

fn JUnitReporter.test_or_group(sb &mut strings.Builder, t &mut Tester, depth usize) {
	if t.subs.len == 0 {
		JUnitReporter.single_test(sb, t, depth)
	} else {
		JUnitReporter.group(sb, t, depth)
	}
}

fn JUnitReporter.single_test(sb &mut strings.Builder, t &mut Tester, depth usize) {
	JUnitReporter.write_indent(sb, depth)
	sb.write_str('<testcase name="${t.name}" time="${t.duration.as_secs()}.${t.duration.as_millis()}">\n')
	if t.status == .failed {
		JUnitReporter.write_indent(sb, depth + 1)
		sb.write_str('<failure message="${t.msg_without_colors()}" type="AssertionError">${t.msg_without_colors()}</failure>\n')
	}
	JUnitReporter.write_indent(sb, depth)
	sb.write_str('</testcase>\n')
}

fn JUnitReporter.group(sb &mut strings.Builder, t &Tester, depth usize) {
	JUnitReporter.write_indent(sb, depth)
	sb.write_str('<testsuite name="${t.name}" tests="${t.subs.len}" failures="${t.fails_count}" time="${t.duration.as_secs()}.${t.duration.as_millis()}">\n')

	for result in t.subs {
		JUnitReporter.test_or_group(sb, result, depth + 1)
	}

	JUnitReporter.write_indent(sb, depth)
	sb.write_str('</testsuite>\n')
}

fn JUnitReporter.write_indent(sb &mut strings.Builder, depth usize) {
	for _ in 0 .. depth {
		sb.write_str('   ')
	}
}

interface Reporter {
	fn on_testing_start(self, t &Tester)
	fn on_testing_finish(self, t &mut Tester)

	fn on_start(self, t &Tester)
	fn on_finish(self, status TestStatus, t &mut Tester)

	fn on_assert_fail(self, t &mut Tester, loc Location, message string)
}

struct BaseReporter {}

fn (_ BaseReporter) on_testing_start(t &Tester) {}

fn (_ BaseReporter) on_testing_finish(t &mut Tester) {
	count_asserts := t.subs.reduce(0 as usize, |acc usize, sub &mut Tester| acc + sub.count_asserts())
	duration := t.subs.reduce(0 as u64, |acc u64, sub &mut Tester| acc + sub.duration as u64) as time.Duration
	is_failed := t.subs.any(|sub| sub.failed)

	mut passed := 0
	mut failed := 0

	for sub in t.subs {
		if sub.failed {
			failed++
		} else {
			passed++
		}
	}

	println()
	println(term.green("  ${passed} pass"))
	if failed == 0 {
		println(term.gray("  0 fail"))
	} else {
		println(term.bright_red("  ${failed} fail"))
	}

	println("  ${count_asserts} asserts")

	println()
	print("Ran ${passed + failed} tests ")
	t.print_duration(duration)
	println()
}

fn (_ BaseReporter) on_start(t &Tester) {}

fn (_ BaseReporter) on_finish(status TestStatus, t &mut Tester) {
	if status == .ok {
		print(term.green(' ✓'))
		print(" ${t.name} ")
		t.print_test_duration()

		if t.retry_count > 0 && t.fails_count > 0 {
			println("  (success after ${t.fails_count} retries)")
		} else {
			println()
		}
	}
}

fn (_ BaseReporter) on_assert_fail(t &mut Tester, loc Location, msg string) {
	print(term.bright_red(' ×'))
	print(" ${t.name} ")
	t.print_test_duration()

	if t.retry_count > 0 {
		t.fails_count++
		println(" (retry ${t.fails_count}/${t.retry_count})")
	} else {
		println()
	}

	println()
	println("${loc}:")
	context := get_context_line(loc)
	print(context)
	print(term.bright_red('error'))
	print(': ')
	println(msg)
	println()
}

struct TeamcityReporter {}

fn (_ TeamcityReporter) on_testing_start(t &Tester) {
	name := TeamcityReporter.escape_name(t.name)
	println("##teamcity[testSuiteStarted name='${name}']\n")
}

fn (_ TeamcityReporter) on_testing_finish(t &mut Tester) {
	BaseReporter{}.on_testing_finish(t)

	name := TeamcityReporter.escape_name(t.name)
	println("##teamcity[testSuiteFinished name='${name}']\n")
}

fn (_ TeamcityReporter) on_start(t &Tester) {
	file := t.containing_file
	name := TeamcityReporter.escape_name(t.name)

	location := if t.custom_location == '' {
		"${file}:${name}"
	} else {
		t.custom_location
	}

	println("##teamcity[testStarted name='${name}' locationHint='spawn_qn://${location}']")
}

fn (_ TeamcityReporter) on_finish(status TestStatus, t &mut Tester) {
	BaseReporter{}.on_finish(status, t)

	kind := match status {
		.ok => "testFinished"
		.failed => "testFailed"
		.skipped => "testIgnored"
	}

	file := t.containing_file
	duration := t.duration.as_millis()
	name := TeamcityReporter.escape_name(t.name)

	println("##teamcity[${kind} name='${name}' duration='${duration}' message='']")
	fs.flush_stdout()
}

fn (_ TeamcityReporter) on_assert_fail(t &mut Tester, loc Location, msg string) {
	BaseReporter{}.on_assert_fail(t, loc, msg)
}

fn TeamcityReporter.escape_name(name string) -> string {
	// See https://www.jetbrains.com/help/teamcity/service-messages.html#Escaped+Values
	return name.
		replace("|", "||'").
		replace("\n", "|n'").
		replace("\r", "|r'").
		replace("[", "|[").
		replace("]", "|]").
		replace("'", "|'")
}

struct CompactReporter {}

fn (_ CompactReporter) on_testing_start(t &Tester) {}

fn (_ CompactReporter) on_testing_finish(t &mut Tester) {
	if t.any_failed() {
		println()
		println(term.bright_red("×"), "Some tests failed:")
		for result in t.results {
			if result.status != .failed {
				continue
			}

			msg := result.msg.split_iter('\n').next() or { result.msg }
			loc_str := term.gray('at ${result.loc}')
			println("  ${term.bright_red(result.tester.name)}: ${loc_str}\n    ${msg}")
		}
		return
	}

	println()
	println(term.green('✓'), 'All tests passed!')
}

fn (_ CompactReporter) on_start(t &Tester) {}

fn (_ CompactReporter) on_finish(status TestStatus, t &mut Tester) {
	if status == .ok {
		print(term.green('.'))
	}
}

fn (_ CompactReporter) on_assert_fail(_ &mut Tester, _ Location, _ string) {
	print(term.bright_red('E'))
}
