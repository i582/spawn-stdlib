module sync

import intrinsics
import sync.atomic

// This implementation is based on the Go standard library's sync package.

// Once is an object that will perform exactly one action.
// It is useful for one-time initializations, after first use, other
// calls `do` will not call the function `f` again.
pub struct Once {
	done  atomic.Bool
	mutex &Mutex
}

// new returns a new `Once`.
pub fn Once.new() -> Once {
	return Once{
		done: atomic.Bool.from(false)
		mutex: Mutex.new()
	}
}

// do calls the function `f` if and only if `do` has not been called
// on this `Once` instance before. In other words, given
// ```
// once := sync.Once.new()
// ```
// if `once.do(f)` is called multiple times, only the first call will
// invoke `f`, even if `f` has a different value in each invocation.
// A new instance of `Once` is required for each function to execute.
//
// `do` is intended for initialization that must be run exactly once. Since `f`
// is niladic, it may be necessary to use a function literal to capture the
// arguments to a function to be invoked by `do`:
// ```
// config.once.do(fn () { config.init(filename) })
// ```
// Because no call to `do` returns until the one call to `f` returns, if `f` causes
// `do` to be called, it will deadlock.
//
// If `f` panics, `do` considers it to have returned; future calls of `do` return
// without calling `f`.
pub fn (o &mut Once) do(f fn ()) {
	// Note: Here is an incorrect implementation of Do:
	// ```
	// if o.done.compare_and_swap(false, true, .seq_cst) {
	//   f()
	// }
	// ```
	//
	// `do` guarantees that when it returns, `f` has finished.
	// This implementation would not implement that guarantee:
	// given two simultaneous calls, the winner of the cas would
	// call `f`, and the second would return immediately, without
	// waiting for the first's call to `f` to complete.
	// This is why the slow path falls back to a mutex, and why
	// the `o.done.store` must be delayed until after `f` returns.

	if intrinsics.unlikely(!o.done.load(.seq_cst)) {
		o.do_slow(f)
	}
}

pub fn (o &mut Once) do_slow(f fn ()) {
	// TODO: move unlock to defer to prevent deadlock if f panics
	o.mutex.lock()
	if !o.done.load(.seq_cst) {
		f()
		o.done.store(true, .seq_cst)
	}
	o.mutex.unlock()
}
