module atomic

import sys.libc.stdatomics

#[atomic]
pub struct Bool {
	v u8
}

pub fn Bool.from(v bool) -> Bool {
	return Bool{ v: v as u8 }
}

pub fn (b &mut Bool) store(val bool, order AtomicOrdering) {
	stdatomics.atomic_store_explicit(&mut b.v, val as u8, order as i32)
}

pub fn (b &Bool) load(order AtomicOrdering) -> bool {
	return stdatomics.atomic_load_explicit[u8](&b.v, order as i32) != 0
}

pub fn (b &mut Bool) swap(val bool, order AtomicOrdering) -> bool {
	return stdatomics.atomic_exchange_explicit(&mut b.v, val as u8, order as i32) != 0
}

#[skip_inline]
pub fn (b Bool) str() -> string {
	return b.load(.seq_cst).str()
}

#[atomic]
pub struct U32 {
	v u32
}

pub fn U32.from(v u32) -> U32 {
	return U32{ v: v }
}

pub fn (b &mut U32) store(val u32, order AtomicOrdering) {
	stdatomics.atomic_store_explicit(&mut b.v, val, order as i32)
}

pub fn (b &U32) load(order AtomicOrdering) -> u32 {
	return stdatomics.atomic_load_explicit[u32](&b.v, order as i32)
}

pub fn (b &mut U32) swap(val u32, order AtomicOrdering) -> u32 {
	return stdatomics.atomic_exchange_explicit(&mut b.v, val, order as i32)
}

#[skip_profile]
pub fn (b &mut U32) fetch_add(val u32, order AtomicOrdering) -> u32 {
	return stdatomics.atomic_fetch_add_explicit(&mut b.v, val, order as i32)
}

pub fn (b &mut U32) compare_exchange_weak(mut current u32, new u32, success_order AtomicOrdering, failure_order AtomicOrdering) -> bool {
	return stdatomics.atomic_compare_exchange_weak_explicit(&mut b.v, &mut current, new, success_order as i32, failure_order as i32)
}

#[skip_inline]
pub fn (b U32) str() -> string {
	return b.load(.seq_cst).str()
}
