module benchmark

import runtime

// allocs_per_run runs a function `runs` times and returns the average
// number of allocations per run.
pub fn allocs_per_run(runs usize, f fn ()) -> usize {
	runtime.gc()

	// warmup the function
	f()

	allocs_before := runtime.get_count_alloc()

	for i in 0 .. runs {
		f()
	}

	allocs := runtime.get_count_alloc() - allocs_before
	return (allocs as f64 / runs as f64).ceil() as usize
}

// bytes_per_run runs a function `runs` times and returns the average
// number of bytes allocated per run.
pub fn bytes_per_run(runs usize, f fn ()) -> MemoryFootprint {
	runtime.gc()

	// warmup the function
	f()

	mem_before := runtime.get_total_alloc()

	for i in 0 .. runs {
		f()
	}

	allocated := runtime.get_total_alloc() - mem_before
	return (allocated as f64 / runs as f64).ceil() as usize
}
