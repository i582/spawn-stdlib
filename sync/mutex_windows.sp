module sync

import sys.winapi

// Mutex is a **mut**ual **ex**clusion primitive useful for protecting shared data.
// This mutex will block threads waiting for the lock to become available.
//
// Example:
// ```
// module main
//
// import sync
//
// fn foo(mtx &sync.Mutex) {
//    mtx.lock()
//    defer mtx.unlock()
//
//    // critical section
//    // only one thread can be here at a time
//    // because the mutex is locked
//    // ...
// }
//
// fn main() {
//    m := sync.Mutex.new()
//    for i in 0 .. 10 {
//       spawn foo(m)
//    }
// }
// ```
pub struct Mutex {
	m winapi.SRWLOCK
}

// new creates a new Mutex allocated on the heap.
pub fn Mutex.new() -> &Mutex {
	m := &Mutex{}
	winapi.InitializeSRWLock(&m.m)
	return m
}

// new_obj creates a new Mutex.
pub fn Mutex.new_obj() -> Mutex {
	m := Mutex{}
	winapi.InitializeSRWLock(&m.m)
	return m
}

// lock acquires a mutex, blocking the current thread until it is able to do so.
//
// This function will block the current thread until it is available to acquire
// the mutex. Upon returning, the thread is the only thread with the lock
// held.
//
// The exact behavior on locking a mutex in the thread which already holds
// the lock is left unspecified. However, this function will not return on
// the second call (it might panic or deadlock, for example).
//
// It is recommended to use the `defer m.unlock()` call right after the `m.lock()`
// to ensure that the mutex is always unlocked, even if the function panics or
// returns in the nested block.
//
// Example:
// ```
// module main
//
// import sync
//
// fn foo(m &sync.Mutex) {
//    m.lock()
//    defer m.unlock()
//
//    // do something
// }
// ```
pub fn (m &Mutex) lock() {
	winapi.AcquireSRWLockExclusive(&m.m)
}

// unlock releases the mutex.
//
// After this function returns, other threads are able to acquire the mutex.
// It is recommended to use the `defer m.unlock()` call right after the `m.lock()`
// to ensure that the mutex is always unlocked, even if the function panics or
// returns in the nested block.
//
// Example:
// ```
// module main
//
// import sync
//
// fn foo(m &sync.Mutex) {
//    m.lock()
//    defer m.unlock()
//
//    // do something
// }
// ```
pub fn (m &Mutex) unlock() {
	winapi.ReleaseSRWLockExclusive(&m.m)
}

// destroy destroys the mutex.
// This function should be called when the mutex is no longer needed.
pub fn (m &Mutex) destroy() -> ! {
	// nothing to do
}
