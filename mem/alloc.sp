module mem

import mem.gc
import profile
import prealloc
import intrinsics

// alloc allocates `size` bytes of memory and returns a pointer to it.
// If the allocation fails, it panics.
#[track_caller]
pub fn alloc(size usize) -> &mut u8 {
	comptime if use_prealloc {
		return prealloc.alloc(size)
	}
	comptime if profile.is_mem {
		if profile.is_running() {
			return profile.alloc(size)
		}
	}
	mut ptr := nil as *mut u8
	comptime if with_gc {
		ptr = gc.alloc(size)
	} $else {
		ptr = intrinsics.memory_alloc(size)
	}
	if ptr == nil {
		alloc_failed(size)
	}
	return assume_safe_mut(ptr)
}

// alloc_opt allocates `size` bytes of memory and returns a pointer to it.
// If the allocation fails, it returns none.
pub fn alloc_opt(size usize) -> ?&mut u8 {
	comptime if use_prealloc {
		return prealloc.alloc(size)
	}
	mut ptr := nil as *mut u8
	comptime if with_gc {
		ptr = gc.alloc(size)
	} $else {
		ptr = intrinsics.memory_alloc(size)
	}
	if ptr == nil {
		return none
	}
	return assume_safe_mut[u8](ptr)
}

// calloc allocates `count` objects of `size` bytes each and returns a pointer to it.
// If the allocation fails, it panics.
pub fn calloc(count usize, size usize) -> &mut u8 {
	comptime if use_prealloc {
		return prealloc.calloc(count, size)
	}
	mut ptr := nil as *mut u8
	comptime if with_gc {
		ptr = gc.calloc(count, size)
	} $else {
		ptr = intrinsics.memory_calloc(count, size)
	}
	if ptr == nil {
		panic('cannot allocate memory, size: ${size}')
	}
	return assume_safe_mut(ptr)
}

// calloc_opt allocates `count` objects of `size` bytes each and returns a pointer to it.
// If the allocation fails, it returns none.
pub fn calloc_opt(count usize, size usize) -> ?&mut u8 {
	comptime if use_prealloc {
		return prealloc.calloc(count, size)
	}
	mut ptr := nil as *mut u8
	comptime if with_gc {
		ptr = gc.calloc(count, size)
	} $else {
		ptr = intrinsics.memory_calloc(count, size)
	}
	if ptr == nil {
		return none
	}
	return assume_safe_mut[u8](ptr)
}

// realloc reallocates `ptr` to `size` bytes and returns a pointer to it.
// If the allocation fails, it panics.
pub fn realloc(ptr *void, size usize) -> &mut u8 {
	comptime if use_prealloc {
		// we don't know the size of `ptr` so we cannot realloc it :(
		panic('cannot realloc preallocated memory')
	}
	mut new_ptr := nil as *mut u8
	comptime if with_gc {
		new_ptr = gc.realloc(ptr, size)
	} $else {
		new_ptr = intrinsics.memory_realloc(ptr, size)
	}
	if new_ptr == nil {
		panic('cannot allocate memory, size: ${size}')
	}
	return assume_safe_mut(new_ptr)
}

// realloc_opt reallocates `ptr` to `size` bytes and returns a pointer to it.
// If the allocation fails, it returns none.
pub fn realloc_opt(ptr *void, size usize) -> ?&mut u8 {
	comptime if use_prealloc {
		return none
	}
	mut new_ptr := nil as *mut u8
	comptime if with_gc {
		new_ptr = gc.realloc(ptr, size)
	} $else {
		new_ptr = intrinsics.memory_realloc(ptr, size)
	}
	if new_ptr == nil {
		return none
	}
	return assume_safe_mut[u8](new_ptr)
}

// c_free frees the memory pointed to by `ptr`.
// This function should only be used for pointers returned by C functions that
// say they should be freed using C `free`.
//
// Example:
// ```text
// // from documentation for `tdefl_compress_mem_to_heap`:
// // > The caller must free() the returned block when it's no longer needed.
//
// data := tdefl_compress_mem_to_heap(...)
// ...
// mem.c_free(data)
// ```
#[unsafe]
pub fn c_free(ptr *mut void) {
	intrinsics.memory_free(ptr)
}

pub fn stack_alloc(size usize) -> &mut u8 {
	return intrinsics.stack_alloc(size)
}

#[cold]
#[skip_inline]
#[track_caller]
fn alloc_failed(size usize) -> never {
	panic('cannot allocate memory, size: ${size}')
}
