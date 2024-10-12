module sync

import time
import sys.libc

// Semaphore is a counting semaphore.
// It is a synchronization primitive that can be used to limit the number of
// threads that access a shared resource.
//
// The semaphore has an internal counter that is decremented each time a thread
// successfully acquires the semaphore. The counter is incremented each time a
// thread releases the semaphore.
//
// If the counter is zero, the thread that tries to acquire the semaphore will
// block until another thread releases the semaphore.
pub struct Semaphore {
	inner libc.dispatch_semaphore_t
}

// new creates a new semaphore with the specified initial count.
// If initialization fails, the function will return an error.
pub fn Semaphore.new(initial u32) -> !&Semaphore {
	return &Semaphore{
		inner: libc.dispatch_semaphore_create(initial as i32)
	}
}

// post increments the semaphore counter.
//
// If the counter was zero, and there are threads waiting to acquire the semaphore,
// one of the waiting threads will be unblocked.
//
// If the counter was zero, and there are no threads waiting to acquire the semaphore,
// the counter will be incremented, and the next thread that tries to acquire the semaphore
// will succeed without blocking.
//
// If the counter was greater than zero, the counter will be just incremented.
pub fn (s &Semaphore) post() {
	libc.dispatch_semaphore_signal(s.inner)
}

// wait decrements the semaphore counter.
//
// If the counter is zero, the calling thread will block until another thread
// increments the counter by calling [`post`].
//
// If the counter is greater than zero, the counter will be decremented, and the
// calling thread will continue executing.
//
// If the counter is zero, and the thread is interrupted by a signal, the function
// will return an error.
pub fn (s &Semaphore) wait() -> ! {
	// dispatch_semaphore_wait always return true with DISPATCH_TIME_FOREVER
	_ = libc.dispatch_semaphore_wait(s.inner, libc.DISPATCH_TIME_FOREVER)
}

// timed_wait decrements the semaphore counter with a timeout.
//
// If the counter is zero, the calling thread will block until another thread
// increments the counter by calling [`post`] or the timeout is reached. If
// the timeout is reached, the function will return `true`.
//
// If the counter is greater than zero, the counter will be decremented, and the
// calling thread will continue executing.
//
// If the counter is zero, and the thread is interrupted by a signal, the function
// will return an error.
pub fn (s &Semaphore) timed_wait(timeout time.Duration) -> !bool {
	timeout_time := libc.dispatch_time(libc.DISPATCH_TIME_NOW, timeout.as_nanos())
	return libc.dispatch_semaphore_wait(s.inner, timeout_time) != 0
}

// destroy destroys the semaphore.
pub fn (s &Semaphore) destroy() -> ! {
	// do nothing
}
