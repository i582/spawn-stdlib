module gc

import time

pub fn alloc(size usize) -> *mut u8 {
	return GC_MALLOC(size) as *mut u8
}

pub fn calloc(count usize, size usize) -> *mut u8 {
	return GC_MALLOC(count * size) as *mut u8
}

pub fn realloc(oldp *void, size usize) -> *mut u8 {
	return GC_REALLOC(oldp, size) as *mut u8
}

pub fn start_performance_measurement() {
	GC_start_performance_measurement()
}

pub fn stop_performance_measurement() -> time.Duration {
	return time.Duration.from_millis(GC_get_full_gc_total_time())
}

pub fn owns_ptr(ptr *void) -> bool {
	return GC_is_heap_ptr(ptr) != 0
}
