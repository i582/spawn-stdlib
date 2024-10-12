module sync

import time
import sys.libc

// CondAttrs is a set of attributes that can be set when initializing a condition variable.
pub struct CondAttrs {
	inner libc.pthread_condattr_t
}

// new creates a new set of condition variable attributes.
pub fn CondAttrs.new(flags i32) -> CondAttrs {
	mut c := CondAttrs{}
	libc.pthread_condattr_init(&mut c.inner)
	libc.pthread_condattr_setpshared(&mut c.inner, flags)
	return c
}

// Cond is a condition variables that represent the ability to block a thread
// such that it consumes no CPU time while waiting for an event to occur.
// Condition variables are typically associated with a boolean predicate (a condition)
// and a [`Mutex`]. The predicate is always verified inside of the mutex before
// determining that a thread must block.
//
// Functions in this module will block the current **thread** of execution.
pub struct Cond {
	c libc.pthread_cond_t
}

// new creates a new condition variable which is ready to be waited on and notified.
pub fn Cond.new() -> &Cond {
	c := &Cond{}
	libc.pthread_cond_init(&c.c, nil)
	return c
}

// with_attrs creates a new condition variable with the given attributes.
// If you want to create a condition variable without any attributes, use
// [`Cond.new`] instead.
//
// Note: The attributes are destroyed after the condition variable is created.
pub fn Cond.with_attrs(attrs CondAttrs) -> Cond {
	c := Cond{}
	libc.pthread_cond_init(&c.c, &attrs.inner)
	libc.pthread_condattr_destroy(&attrs.inner)
	return c
}

// wait blocks the current thread until this condition variable receives a
// notification.
//
// This function will atomically unlock the mutex specified and block the
// current thread. This means that any calls to [`notify_one`] or [`notify_all`]
// which happen logically after the mutex is unlocked are candidates to wake
// this thread up. When this function call returns, the lock specified will
// have been re-acquired.
//
// Note that this function is susceptible to spurious wakeups. Condition
// variables normally have a boolean predicate associated with them, and
// the predicate must always be checked each time this function returns to
// protect against spurious wakeups.
pub fn (c &Cond) wait(m &Mutex) {
	libc.pthread_cond_wait(&c.c, &m.m)
}

// wait_while blocks the current thread until this condition variable receives a
// notification and the provided condition is false.
//
// This function will atomically unlock the mutex specified and block the
// current thread. This means that any calls to [`notify_one`] or [`notify_all`]
// which happen logically after the mutex is unlocked are candidates to wake
// this thread up. When this function call returns, the lock specified will have been re-acquired.
pub fn (c &Cond) wait_while(m &Mutex, f fn (m &Mutex) -> bool) {
	for f(m) {
		c.wait(m)
	}
}

// wait_for waits on this condition variable for a notification, timing out
// after a specified duration.
//
// The semantics of this function are equivalent to [`wait`]
// except that the thread will be blocked for roughly no longer
// than duration. This method should not be used for precise timing due to
// anomalies such as preemption or platform differences that might not cause
// the maximum amount of time waited to be precisely `duration`.
//
// The returned boolean is `true` only if the timeout is known
// to have elapsed.
//
// Like [`wait`], the lock specified will be re-acquired when this function
// returns, regardless of whether the timeout elapsed or not.
pub fn (c &Cond) wait_for(m &Mutex, timeout time.Duration) -> bool {
	timespec := timeout.as_timespec()
	res := libc.pthread_cond_timedwait(&c.c, &m.m, &timespec)
	return res == libc.ETIMEDOUT
}

// notify_one wakes up one blocked thread on this condvar.
//
// If there is a blocked thread on this condition variable, then it will
// be woken up from its call to [`wait`] or [`wait_timeout`]. Calls to
// `notify_one` are not buffered in any way.
//
// To wake up all threads, see [`notify_all`].
pub fn (c &Cond) notify_one() {
	libc.pthread_cond_signal(&c.c)
}

// notify_all wakes up all blocked threads on this condvar.
//
// This method will ensure that any current waiters on the condition
// variable are awoken. Calls to `notify_all()` are not buffered in any
// way.
//
// To wake up only one thread, see [`notify_one`].
pub fn (c &Cond) notify_all() {
	libc.pthread_cond_broadcast(&c.c)
}

// raw returns the underlying pthread condition variable.
pub fn (c &Cond) raw() -> libc.pthread_cond_t {
	return c.c
}

// destroy destroys the condition variable.
pub fn (c &Cond) destroy() -> ! {
	res := libc.pthread_cond_destroy(&c.c)
	if res != 0 {
		return error("failed to destroy condition variable: ${res}")
	}
}
