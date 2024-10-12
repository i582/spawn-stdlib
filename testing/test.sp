module testing

import fs
import os
import mem
import env
import term
import time
import pathlib
import intrinsics

pub struct Tester {
	name   string
	failed bool

	parent ?&mut Tester
	subs   []&mut Tester

	results       []TestResult
	reporter      Reporter     = BaseReporter{} as Reporter
	file_reporter FileReporter = BaseFileReporter{} as FileReporter
	filepath      string

	start_time time.StopWatch
	duration   time.Duration
	status     TestStatus
	msg        string

	containing_file string

	// custom_location is used to override the location of the test
	// when send service messages in teamcity reporter
	custom_location string

	panicked     bool
	expect_panic bool

	assert_count usize

	skip        bool
	retry_count usize
	fails_count usize
}

pub fn (t &mut Tester) set_reporter(name string) {
	match name {
		"teamcity" => {
			t.reporter = TeamcityReporter{}
		}
		"compact" => {
			t.reporter = CompactReporter{}
		}
	}
}

pub fn (t &mut Tester) set_output(reporter string, path string) {
	match reporter {
		'junit' => {
			t.file_reporter = JUnitReporter{}
		}
	}
	t.filepath = path
}

pub fn (t &mut Tester) set_custom_location(loc string) {
	t.custom_location = loc
}

fn (r &mut Tester) msg_without_colors() -> string {
	return term.strip_ansi(r.msg)
}

pub fn (t &mut Tester) any_failed() -> bool {
	if t.failed {
		return true
	}

	for sub in t.subs {
		if sub.any_failed() {
			return true
		}
	}

	return false
}

#[track_caller]
pub fn (t &mut Tester) run(name string, cb fn (_ &mut Tester)) {
	t.run_in_file(string.view_from_c_str(Location.caller().file), name, cb)
}

pub fn (t &mut Tester) run_in_file(file string, name string, cb fn (_ &mut Tester)) {
	t.containing_file = file
	mut t_new := mem.to_heap_mut(&mut Tester{
		name: name
		parent: t
		reporter: t.reporter
		containing_file: file
		custom_location: t.custom_location
	})
	t.subs.push(t_new)
	t_new.start_time = time.new_stopwatch()
	t_new.run_safe(cb)

	if t_new.failed {
		if t_new.retry_count > 0 {
			for _ in 0 .. t_new.retry_count - 1 {
				t_new.failed = false
				t_new.start_time = time.new_stopwatch()
				t_new.run_safe(cb)
				if !t_new.failed {
					// we successfully retried
					break
				}
			}
		} else {
			t.reporter.on_finish(.failed, t_new)
			fs.flush_stdout()
			return
		}
	}

	t_new.duration = t_new.start_time.elapsed()
	if t_new.expect_panic && !t_new.panicked {
		t_new.fail("test expected to panic, but it didn't")
		return
	}
	t_new.status = .ok

	if parent := t.parent {
		parent.add_result(TestResult{
			tester: t_new
			duration: t_new.duration
			status: .ok
		})
	}

	t_new.reporter.on_finish(.ok, t_new)
	fs.flush_stdout()
}

pub fn (t &mut Tester) add_result(result TestResult) {
	// if parent := t.parent {
	//     parent.add_result(result)
	// }
	t.results.push(result)
}

pub fn (t &mut Tester) run_safe(cb fn (_ &Tester)) {
	defer fn () {
		if msg := recover() {
			t.panicked = true
			if !t.expect_panic {
				t.failed = true
				t.fail("panicked with message: ${msg}")
			}
		}
	}()

	t.reporter.on_start(t)
	fs.flush_stdout()
	cb(t)
}

#[track_caller]
pub fn (t &mut Tester) fail(msg string) {
	t.duration = t.start_time.elapsed()
	t.failed = true
	t.status = .failed
	t.msg = msg

	if parent := t.parent {
		parent.add_result(TestResult{
			tester: t
			duration: t.duration
			status: .failed
			loc: intrinsics.caller_location()
			msg: msg
		})
	}

	t.reporter.on_assert_fail(t, intrinsics.caller_location(), msg)
	t.reporter.on_finish(.failed, t)
	fs.flush_stdout()
}

fn (t &mut Tester) print_test_duration() {
	t.print_duration(t.duration)
}

fn (t &mut Tester) print_duration(dur time.Duration) {
	if dur == 0 {
		print(term.gray("[<1us]"))
		return
	}

	print(term.gray("[${dur}]"))
}

pub fn (t &mut Tester) finish() {
	t.reporter.on_testing_finish(t)
	fs.flush_stdout()

	if t.filepath.len > 0 {
		t.file_reporter.save(t, t.filepath) or {
			println(term.red('error'), ': failed to save file with test results: ${err.msg()}')
			fs.flush_stdout()
		}
	}
}

pub fn (t &mut Tester) must_panic() {
	t.expect_panic = true
}

pub fn (t &mut Tester) retry(count usize) {
	t.retry_count = count
}

pub fn (t &mut Tester) skip() {
	t.skip = true
}

pub fn (t &mut Tester) containing_file(file string) {
	t.containing_file = file
}

// tmp_dir returns the path to a temporary directory used by
// Spawn tester to store temporary files. Can be overridden by setting
// the `SPAWN_TEST_TMP` environment variable.
//
// Example:
// ```
// root := t.tmp_dir()
//
// fs.mkdir_all("${root}/foo/bar/baz", mode: 0o755) or {}
// fs.mkdir_all("${root}/foo/baz", mode: 0o755) or {}
// fs.mkdir_all("${root}/foo/qux", mode: 0o755) or {}
// fs.mkdir_all("${root}/bar", mode: 0o755) or {}
// ```
pub fn (t &mut Tester) tmp_dir() -> string {
	if val := env.find_opt('SPAWN_TEST_TMP') {
		create_folder_when_it_does_not_exist(val)
		return val
	}

	raw_path := pathlib.join(os.tmp_dir(), "spawn", "tester")
	create_folder_when_it_does_not_exist(raw_path)
	path := fs.real_path(raw_path).unwrap()
	env.set('SPAWN_TEST_TMP', path, true)
	return path
}

fn create_folder_when_it_does_not_exist(path string) {
	if fs.is_dir(path) {
		return
	}
	fs.mkdir_all(path, 0o700) or {
		if fs.is_dir(path) {
			// A race had been won, and the `path` folder had been created,
			// by another concurrent executable, since the folder now exists,
			// but it did not right before ... we will just use it too.
			return
		}
		panic(err.msg())
	}
}

// implicit definition of `t` inside any `test` definition
var fake_t = &mut Tester{}
