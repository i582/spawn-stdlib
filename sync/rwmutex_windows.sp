module sync

import sys.winapi

// RwMutex is a **mut**ual **ex**clusion primitive useful for protecting shared data.
// It allows multiple readers or a single writer to access the data at the same time.
// This mutex will block threads waiting for the lock to become available.
//
// Example:
// ```
// module main
//
// import sync
//
// fn foo(mtx &sync.RwMutex) {
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
//    m := sync.RwMutex.new()
//    for i in 0 .. 10 {
//       spawn foo(m)
//    }
// }
// ```
pub struct RwMutex {
	m winapi.SRWLOCK
}

// new creates a new RwMutex allocated on the heap.
pub fn RwMutex.new() -> &RwMutex {
	mut m := RwMutex{}
	winapi.InitializeSRWLock(&m.m)
	return &m
}

// lock acquires a write lock on the mutex, blocking the current thread until it is available.
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
// fn foo(m &sync.RwMutex) {
//    m.lock()
//    defer m.unlock()
//
//    // do something
// }
// ```
pub fn (m &RwMutex) lock() {
	winapi.AcquireSRWLockExclusive(&m.m)
}

// rlock acquires a read lock on the mutex, blocking the current thread until it is available.
//
// This function will block the current thread until it is available to acquire
// the mutex. Upon returning, the thread is the only thread with the lock
// held.
//
// The exact behavior on locking a mutex in the thread which already holds
// the lock is left unspecified. However, this function will not return on
// the second call (it might panic or deadlock, for example).
//
// It is recommended to use the `defer m.runlock()` call right after the `m.rlock()`
// to ensure that the mutex is always unlocked, even if the function panics or
// returns in the nested block.
//
// Example:
// ```
// module main
//
// import sync
//
// fn foo(m &sync.RwMutex) {
//    m.rlock()
//    defer m.runlock()
//
//    // do something
// }
// ```
pub fn (m &RwMutex) rlock() {
	winapi.AcquireSRWLockShared(&m.m)
}

// try_lock tries to acquire a write lock on the mutex.
// If the mutex is already locked, this function will return false.
// Otherwise, it will acquire the write lock and return true.
//
// Example:
// ```
// module main
//
// import sync
//
// fn foo(m &sync.RwMutex) {
//    if m.try_lock() {
//       defer m.unlock()
//       // do something
//    } else {
//       // do something else
//    }
// }
// ```
pub fn (m &RwMutex) try_lock() -> bool {
	// TODO: this function is available only on Windows 7 and later
	res := winapi.TryAcquireSRWLockExclusive(&m.m)
	return res == 0
}

// try_rlock tries to acquire a read lock on the mutex.
// If the mutex is already locked, this function will return false.
// Otherwise, it will acquire the read lock and return true.
//
// Example:
// ```
// module main
//
// import sync
//
// fn foo(m &sync.RwMutex) {
//    if m.try_rlock() {
//       defer m.runlock()
//       // do something
//    } else {
//       // do something else
//    }
// }
// ```
pub fn (m &RwMutex) try_rlock() -> bool {
	// TODO: this function is available only on Windows 7 and later
	res := winapi.TryAcquireSRWLockShared(&m.m)
	return res == 0
}

// unlock releases the write lock on the mutex.
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
// fn foo(m &sync.RwMutex) {
//    m.lock()
//    defer m.unlock()
//
//    // do something
// }
// ```
pub fn (m &RwMutex) unlock() {
	winapi.ReleaseSRWLockExclusive(&m.m)
}

// runlock releases the read lock on the mutex.
//
// After this function returns, other threads are able to acquire the mutex.
// It is recommended to use the `defer m.runlock()` call right after the `m.rlock()`
// to ensure that the mutex is always unlocked, even if the function panics or
// returns in the nested block.
//
// Example:
// ```
// module main
//
// import sync
//
// fn foo(m &sync.RwMutex) {
//    m.rlock()
//    defer m.runlock()
//
//    // do something
// }
// ```
pub fn (m &RwMutex) runlock() {
	winapi.ReleaseSRWLockShared(&m.m)
}

// destroy destroys the mutex.
// This function should be called when the mutex is no longer needed.
pub fn (m &RwMutex) destroy() -> ! {
	// nothing to do here
}
