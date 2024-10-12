module sync

import sys.libc

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
	m libc.pthread_rwlock_t
}

// new creates a new RwMutex allocated on the heap.
pub fn RwMutex.new() -> &RwMutex {
	mut attrs := libc.pthread_rwlockattr_t{}
	libc.pthread_rwlockattr_init(&mut attrs)
	comptime if !darwin {
		// Give writer priority over readers
		libc.pthread_rwlockattr_setkind_np(&mut attrs, libc.PTHREAD_RWLOCK_PREFER_WRITER_NONRECURSIVE_NP)
	}
	libc.pthread_rwlockattr_setpshared(&mut attrs, libc.PTHREAD_PROCESS_PRIVATE)

	mut m := RwMutex{}
	libc.pthread_rwlock_init(&mut m.m, &attrs)
	libc.pthread_rwlockattr_destroy(&attrs)
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
	libc.pthread_rwlock_wrlock(&m.m)
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
	libc.pthread_rwlock_rdlock(&m.m)
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
	res := libc.pthread_rwlock_trywrlock(&m.m)
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
	res := libc.pthread_rwlock_tryrdlock(&m.m)
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
	libc.pthread_rwlock_unlock(&m.m)
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
	libc.pthread_rwlock_unlock(&m.m)
}

// destroy destroys the mutex.
// This function should be called when the mutex is no longer needed.
pub fn (m &RwMutex) destroy() -> ! {
	res := libc.pthread_rwlock_destroy(&m.m)
	if res != 0 {
		return error("failed to destroy mutex: ${res}")
	}
}
