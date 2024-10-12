module atomic

import sys.libc.stdatomics
import intrinsics

// Ptr is an atomic raw pointer that can be used to share data between threads.
// In-memory, it is represented as a pointer to the value and equivalent to
// `*mut T`.
#[atomic]
pub struct Ptr[T] {
	v *mut T
}

// new creates a new atomic pointer with the given initial value.
//
// Example:
// ```
// module main
//
// import sync.atomic
//
// fn main() {
//    val := 10
//    some_ptr := atomic.Ptr.new(&mut val)
// }
// ```
pub fn Ptr.new[T](v *mut T) -> Ptr[T] {
	return Ptr{ v: v }
}

// store stores a value into the pointer.
//
// [`store`] takes an [`AtomicOrdering`] argument which describes the memory ordering
// of this operation. Possible values are [`seq_cst`], [`release`] and [`relaxed`].
//
// Panics if `order` is [`acquire`] or [`acq_rel`].
//
// Example:
// ```
// module main
//
// import sync.atomic
//
// fn main() {
//    val := 10
//    some_ptr := atomic.Ptr.new(&mut val)
//
//    other_val := 20
//    other_ptr := &mut other_val
//
//    some_ptr.store(other_ptr, .relaxed)
//    // some_ptr now points to other_val
// }
pub fn (b &mut Ptr[T]) store(val *mut T, order AtomicOrdering) {
	if intrinsics.unlikely(order == .acquire || order == .acq_rel) {
		panic("there is no such thing as an acquire store or an acquire/release store")
	}

	stdatomics.atomic_store_explicit(&mut b.v, val, order as i32)
}

// load loads a value from the pointer.
//
// `load` takes an [`AtomicOrdering`] argument which describes the memory ordering
// of this operation. Possible values are [`eeq_cst`], [`acquire`] and [`relaxed`].
//
// Panics if `order` is [`release`] or [`acq_rel`].
//
// Example:
// ```
// module main
//
// import sync.atomic
//
// fn main() {
//    val := 10
//    some_ptr := atomic.Ptr.new(&mut val)
//
//    value := some_ptr.load(.relaxed)
//    println(value) // 10
// }
// ```
pub fn (b &Ptr[T]) load(order AtomicOrdering) -> *mut T {
	if intrinsics.unlikely(order == .release || order == .acq_rel) {
		panic("there is no such thing as a release load or an acquire/release load")
	}

	return stdatomics.atomic_load_explicit(&b.v, order as i32)
}

// swap stores a value into the pointer, returning the previous value.
//
// `swap` takes an [`AtomicOrdering`] argument which describes the memory ordering
// of this operation. All ordering modes are possible. Note that using
// [`acquire`] makes the store part of this operation [`relaxed`], and
// using [`release`] makes the load part [`relaxed`].
//
// Example:
// ```
// module main
//
// import sync.atomic
//
// fn main() {
//    val := 10
//    some_ptr := atomic.Ptr.new(&mut val)
//
//    other_val := 20
//    other_ptr := &mut other_val
//
//    value := some_ptr.swap(other_ptr, .relaxed)
// }
// ```
pub fn (b &mut Ptr[T]) swap(val *mut T, order AtomicOrdering) -> *mut T {
	return stdatomics.atomic_exchange_explicit(&mut b.v, val, order as i32)
}

pub fn (b &mut Ptr[T]) compare_and_swap(current *mut T, new *mut T, order_succ AtomicOrdering, order_fail AtomicOrdering) -> bool {
	return stdatomics.atomic_compare_exchange_strong_explicit[T](&mut b.v, new, current, order_succ as i32, order_fail as i32)
}

pub fn (b &Ptr[T]) str() -> string {
	val := (b.load(.seq_cst) as usize).hex_prefixed()
	return 'atomic(${val})'
}
