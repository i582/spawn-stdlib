module sync

import errno
import time
import sys.libc

#[enable_if(!darwin)]

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
	inner libc.sem_t
}

// new creates a new semaphore with the specified initial count.
// If initialization fails, the function will return an error.
pub fn Semaphore.new(initial u32) -> !&Semaphore {
	mut s := &Semaphore{}
	res := libc.sem_init(&s.inner, 0, initial)
	if res != 0 {
		return error("failed to create semaphore: ${errno.last().desc()}")
	}
	return s
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
	libc.sem_post(&s.inner)
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
	for {
		if libc.sem_wait(&s.inner) == 0 {
			break
		}

		e := errno.last()
		if e == .EINTR {
			// interrupted by signal, try again
			continue
		}

		return error("sem_wait failed: ${e.desc()}")
	}
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
	timeout_spec := timeout.as_timespec()
	for {
		if libc.sem_timedwait(&s.inner, &timeout_spec) == 0 {
			break
		}

		e := errno.last()
		if e == .EINTR {
			// interrupted by signal, try again
			continue
		}

		if e == .ETIMEDOUT {
			// timeout
			return true
		}

		return error("sem_wait failed: ${e.desc()}")
	}

	return false
}

// destroy destroys the semaphore.
pub fn (s &Semaphore) destroy() -> ! {
	res := libc.sem_destroy(&s.inner)
	if res != 0 {
		return error("failed to destroy semaphore: ${res}")
	}
}
