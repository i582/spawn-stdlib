module mem

import intrinsics

// size_of returns the size of the type T in bytes.
pub fn size_of[T]() -> usize {
	return intrinsics.size_of[T]()
}

// align_of returns the alignment of the type T in bytes.
pub fn align_of[T]() -> usize {
	return intrinsics.align_of[T]()
}

// fast_copy copies size bytes from `src` to `dest`.
// Note that `dest` and `src` must not overlap, or else the behavior is undefined.
// `is_nonoverlapping` can be used to check if the memory blocks overlap.
// To copy overlapping memory blocks, use `copy`.
pub fn fast_copy(dest *mut u8, src *u8, size usize) -> *mut u8 {
	return intrinsics.memory_copy(dest, src, size)
}

pub fn fast_copy_ref(dest &mut u8, src &u8, size usize) -> &mut u8 {
	return assume_safe_mut(intrinsics.memory_copy(dest as *mut u8, src as *u8, size))
}

// copy copies size bytes from `src` to `dest`.
// `dest` and `src` may overlap, and the copy is guaranteed to occur in a
// non-destructive manner.
pub fn copy(dest *mut u8, src *u8, size usize) -> *mut u8 {
	return intrinsics.memory_move(dest, src, size)
}

// compare compares first `n` bytes of two memory blocks (interpreted as
// unsigned char arrays) and returns 0 if they are equal, 1 if the first
// block is greater than the second, -1 otherwise.
// If `n` is zero, the function returns 0.
//
// Do not use this function to compare security critical data,
// because it is not constant time.
pub fn compare(s1 *void, s2 *void, n usize) -> i32 {
	return intrinsics.memory_compare(s1, s2, n)
}

// set fills the first `n` bytes of the memory block pointed to by `s`,
// with the `c` (converted to an unsigned char).
pub fn set(s *mut void, c i32, n usize) -> *void {
	return intrinsics.memory_set(s, c, n)
}

// zero sets the first `n` bytes of the memory block pointed to by `s`,
// to zero.
pub fn zero(s *mut void, n usize) -> *void {
	return intrinsics.memory_set(s, 0, n)
}

// is_nonoverlapping returns true if the `src` and `dst` memory blocks
// of size `count` * size_of[T]() do not overlap.
pub fn is_nonoverlapping[T](src &T, dst &T, count usize) -> bool {
	src_usize := src as usize
	dst_usize := dst as usize
	size := size_of[T]().
		checked_mul(count).
		expect('is_nonoverlapping: `count * size_of[T]()` overflows a usize (${count} * ${size_of[T]()})')

	diff := if src_usize > dst_usize {
		src_usize - dst_usize
	} else {
		dst_usize - src_usize
	}

	// if the absolute distance between the ptrs is at least as big
	// as the size of the buffer, they do not overlap.
	return diff >= size
}

// assume_safe casts a pointer to a reference. Since references are safe by definition,
// we need to ensure that the pointer is not nil and that it is properly aligned.
// Otherwise, function panics.
#[track_caller]
#[skip_profile]
pub fn assume_safe[T](ptr *T) -> &T {
	if ptr == nil {
		panic("cannot cast nil pointer to reference")
	}
	if ptr as usize % align_of[T]() != 0 {
		panic("pointer is not aligned, ptr: ${ptr as usize}, align: ${align_of[T]()}")
	}
	return unsafe { &*ptr }
}

// assume_safe_mut casts a pointer to a reference. Since references are safe by definition,
// we need to ensure that the pointer is not nil and that it is properly aligned.
// Otherwise, function panics.
#[track_caller]
#[skip_profile]
pub fn assume_safe_mut[T](ptr *mut T) -> &mut T {
	if ptr == nil {
		panic("cannot cast nil pointer to reference")
	}
	if ptr as usize % align_of[T]() != 0 {
		panic("pointer is not aligned")
	}
	return unsafe { &mut *ptr }
}

// TODO: remove attr
#[skip_inline]
pub fn to_heap[T](ptr &T) -> &T {
	return to_heap_impl(ptr as &u8, size_of[T]()) as &T
}

#[skip_inline]
pub fn to_heap_mut[T](ptr &mut T) -> &mut T {
	return to_heap_impl(ptr as &u8, size_of[T]()) as &mut T
}

fn to_heap_impl(ptr &u8, size usize) -> &mut u8 {
	match size {
		8 => return to_heap_impl_const[8](ptr)
		16 => return to_heap_impl_const[16](ptr)
		24 => return to_heap_impl_const[24](ptr)
		32 => return to_heap_impl_const[32](ptr)
		40 => return to_heap_impl_const[40](ptr)
		48 => return to_heap_impl_const[48](ptr)
		56 => return to_heap_impl_const[56](ptr)
	}

	heap_ptr := alloc(size)
	fast_copy(heap_ptr, ptr, size)
	return heap_ptr
}

fn to_heap_impl_const[const Sise as usize](ptr &u8) -> &mut u8 {
	heap_ptr := alloc(Sise)
	fast_copy(heap_ptr, ptr, Sise)
	return heap_ptr
}

pub fn to_heap_ptr(ptr *u8, size usize) -> &mut u8 {
	heap_ptr := alloc(size)
	fast_copy(heap_ptr, ptr, size)
	return heap_ptr
}
