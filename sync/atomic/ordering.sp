module atomic

import sys.libc.stdatomics

// AtomicOrdering describes atomic memory orderings
//
// Memory orderings specify the way atomic operations synchronize memory.
// In its weakest [`relaxed`], only the memory directly touched by the
// operation is synchronized. On the other hand, a store-load pair of [`seq_cst`]
// operations synchronize other memory while additionally preserving a total order of such
// operations across all threads.
//
// Spawn's memory orderings are
// [the same as those of C++20](https://en.cppreference.com/w/cpp/atomic/memory_order).
pub enum AtomicOrdering {
	// No ordering constraints, only atomic operations.
	//
	// Corresponds to [`memory_order_relaxed`] in C++20.
	//
	// [`memory_order_relaxed`]: https://en.cppreference.com/w/cpp/atomic/memory_order#Relaxed_ordering
	relaxed = stdatomics.memory_order_relaxed
	consume = stdatomics.memory_order_consume

	// When coupled with a load, if the loaded value was written by a store operation with
	// `release` (or stronger) ordering, then all subsequent operations
	// become ordered after that store. In particular, all subsequent loads will see data
	// written before the store.
	//
	// Notice that using this ordering for an operation that combines loads
	// and stores leads to a `relaxed` store operation!
	//
	// This ordering is only applicable for operations that can perform a load.
	//
	// Corresponds to [`memory_order_acquire`] in C++20.
	//
	// [`memory_order_acquire`]: https://en.cppreference.com/w/cpp/atomic/memory_order#Release-Acquire_ordering
	acquire = stdatomics.memory_order_acquire

	// When coupled with a store, all previous operations become ordered
	// before any load of this value with `acquire` (or stronger) ordering.
	// In particular, all previous writes become visible to all threads
	// that perform an `acquire` (or stronger) load of this value.
	//
	// Notice that using this ordering for an operation that combines loads
	// and stores leads to a `relaxed` load operation!
	//
	// This ordering is only applicable for operations that can perform a store.
	//
	// Corresponds to [`memory_order_release`] in C++20.
	//
	// [`memory_order_release`]: https://en.cppreference.com/w/cpp/atomic/memory_order#Release-Acquire_ordering
	release = stdatomics.memory_order_release

	// Has the effects of both `acquire` and `release` together:
	// For loads it uses `acquire` ordering. For stores it uses the `release` ordering.
	//
	// Notice that in the case of `compare_and_swap`, it is possible that the operation ends up
	// not performing any store and hence it has just `acquire` ordering. However,
	// `acq_rel` will never perform `relaxed` accesses.
	//
	// This ordering is only applicable for operations that combine both loads and stores.
	//
	// Corresponds to [`memory_order_acq_rel`] in C++20.
	//
	// [`memory_order_acq_rel`]: https://en.cppreference.com/w/cpp/atomic/memory_order#Release-Acquire_ordering
	acq_rel = stdatomics.memory_order_acq_rel

	// Like `acquire`/`release`/`acq_rel` (for load, store, and load-with-store
	// operations, respectively) with the additional guarantee that all threads see all
	// sequentially consistent operations in the same order.
	//
	// Corresponds to [`memory_order_seq_cst`] in C++20.
	//
	// [`memory_order_seq_cst`]: https://en.cppreference.com/w/cpp/atomic/memory_order#Sequentially-consistent_ordering
	seq_cst = stdatomics.memory_order_seq_cst
}
