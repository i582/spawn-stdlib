module profile

import time

pub comptime const (
	// is_mem is true if memory profiling is enabled.
	is_mem = false

	// is_cpu is true if CPU profiling is enabled.
	is_cpu = false

	is_block = false
)

pub const MAX_SAMPLES = 1_000_000

// Sample is a single profile sample. It uses for both CPU and memory profiling.
pub struct Sample {
	// trace is a backtrace of sample.
	// To be fast it is a raw pointer to a C array of frame addresses.
	trace *usize

	// size is a number of frames in the trace.
	size i32

	// alloc is a number of bytes allocated by the sample.
	// Used only for memory profiling.
	alloc usize
}

pub var (
	samples     = []Sample{}
	num_samples = 0

	// sample_rate is a time between samples in microseconds.
	sample_rate = 0

	// filename is a file to write profile to.
	filename = ""
)

pub var (
	start_time = time.system_unix_epoch()
	end_time   = time.system_unix_epoch()
)

pub fn ticks() -> u64 {
	return time.instant_now().unix_nanos()
}
