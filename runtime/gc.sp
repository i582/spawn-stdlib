module runtime

extern {
	type GC_finalization_proc = fn (obj *void, data *void)

	fn GC_gcollect()
	fn GC_get_count_allocs() -> usize
	fn GC_get_total_bytes() -> usize
	fn GC_register_finalizer(ptr *void, finalizer GC_finalization_proc, cd *void, ofn *GC_finalization_proc, ocd *&u8)
}

// gc runs a garbage collection cycle.
pub fn gc() {
	GC_gcollect()
}

// get_count_alloc returns the cumulative number of allocations since the
// program started.
pub fn get_count_alloc() -> usize {
	return GC_get_count_allocs()
}

// get_total_alloc returns the cumulative number of bytes allocated since the
// program started.
pub fn get_total_alloc() -> usize {
	return GC_get_total_bytes()
}

// register_finalizer registers a finalizer for the given object.
pub fn register_finalizer(obj &void, finalizer fn (_ &void, data &void)) {
	GC_register_finalizer(obj, finalizer, nil, nil, nil)
}
