module gc

extern {
	fn GC_set_pages_executable(v i32)
	fn GC_INIT()
	fn GC_MALLOC(n usize) -> *mut void
	fn GC_malloc_atomic(n usize) -> *mut void
	fn GC_REALLOC(p *void, n usize) -> *mut void
	fn GC_start_performance_measurement()
	fn GC_get_full_gc_total_time() -> u64
	fn GC_is_heap_ptr(p *void) -> bool
}

pub fn init() {
	GC_set_pages_executable(0)
	GC_INIT()
}
