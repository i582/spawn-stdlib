module profile

import fs
import time
import intrinsics
import strings
import backtrace

// is_per_function is a flag showing if per-function profiling is enabled.
pub comptime const (
	is_per_function = false
	with_best_worst = false
)

const (
	// COUNT_FUNCTIONS is the number of functions that are profiled.
	// Actual value is set by the compiler.
	COUNT_FUNCTIONS = 1000

	// FUNCTION_NAME_INDEX is the function name index.
	FUNCTION_NAME_INDEX = ""

	// OUTPUT_FILE is the file where the profiling data is written.
	OUTPUT_FILE = ""
)

var (
	// enabled is a flag showing if profiling is enabled.
	enabled = false

	// per_function_time stores the total time spent in each function.
	// To get function name use [`FUNCTION_NAME_INDEX`].
	per_function_time       = []u64{len: COUNT_FUNCTIONS}
	worst_per_function_time = []u64{len: COUNT_FUNCTIONS}
	best_per_function_time  = []u64{len: COUNT_FUNCTIONS, init: || MAX_U64}

	// per_function_calls stores the number of times each function was called.
	// To get function name use [`FUNCTION_NAME_INDEX`].
	per_function_calls = []u64{len: COUNT_FUNCTIONS}
)

#[skip_profile]
pub fn trace_call(id usize) -> u64 {
	if intrinsics.unlikely(per_function_calls.cap == 0 || !enabled) {
		return 0
	}

	unsafe { per_function_calls.fast_set(id, per_function_calls.fast_get(id) + 1) }
	return time.instant_now().unix_nanos()
}

#[skip_profile]
pub fn start_measure_time() -> u64 {
	return time.instant_now().unix_nanos()
}

#[skip_profile]
pub fn end_measure_time(id usize, start_time u64) {
	if intrinsics.unlikely(per_function_time.cap == 0 || start_time == 0) {
		return
	}
	dur := time.instant_now().unix_nanos() - start_time
	unsafe { per_function_time.fast_set(id, per_function_time.fast_get(id) + dur) }

	comptime if with_best_worst {
		unsafe {
			worst := worst_per_function_time.fast_get(id)
			if dur > worst {
				worst_per_function_time.fast_set(id, dur)
			}

			best := best_per_function_time.fast_get(id)
			if dur < best {
				best_per_function_time.fast_set(id, dur)
			}
		}
	}
}

pub fn enable_per_function_profiling() {
	enabled = true
}

pub fn disable_per_function_profiling() {
	enabled = false
}

pub struct Item {
	name  string
	calls u64
	time  u64
	worst u64
	best  u64
}

#[skip_profile]
pub fn dump_per_function_profiling() {
	enabled = false

	function_names := FUNCTION_NAME_INDEX.split(";").clone()

	mut items := []Item{cap: COUNT_FUNCTIONS}
	for i in 0 .. COUNT_FUNCTIONS {
		if per_function_calls[i] > 1 {
			name := backtrace.demangle(function_names[i - 1])
			items.push(Item{
				name: name
				calls: per_function_calls[i]
				time: per_function_time[i]
				worst: worst_per_function_time[i]
				best: best_per_function_time[i]
			})
		}
	}

	dump_items(items)
}

fn dump_items(items []Item) {
	mut sb := strings.new_builder(100)

	sb.write_str('Type: cpu_per_function\n')
	sb.write_str('Functions: ${items.len}\n')

	sb.write_str('--------------------------\n')

	for item in items {
		sb.write_str(item.name)
		sb.write_str(':')
		sb.write_str(item.calls.str())
		sb.write_str(':')
		sb.write_str(item.time.str())
		sb.write_str('\n')
	}

	fs.write_file(OUTPUT_FILE, sb.str_view()).unwrap()
}
