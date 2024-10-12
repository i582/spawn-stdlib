module sync

import sync.atomic

// WaitGroup waits for a collection of threads to finish.
// The main thread calls [`add`] to set the number of
// threads to wait for. Then each of the thread
// runs and calls [`done`] when finished. At the same time,
// [`wait`] can be used to block until all threads have finished.
//
// `WaitGroup` must not be copied after first use.
pub struct WaitGroup {
	task_count atomic.U32
	wait_count atomic.U32
	sem        &Semaphore
}

// new creates a new WaitGroup.
pub fn WaitGroup.new() -> &mut WaitGroup {
	return WaitGroup.with_count(0)
}

// with_count creates a new WaitGroup with a given number of tasks to wait for.
pub fn WaitGroup.with_count(task_count u32) -> &mut WaitGroup {
	return &mut WaitGroup{
		task_count: atomic.U32.from(task_count)
		wait_count: atomic.U32.from(0)
		sem: Semaphore.new(0).unwrap()
	}
}

// add adds delta, which may be negative, to the [`WaitGroup`] counter.
// If the counter becomes zero, all threads blocked on [`wait`] are released.
// If the counter goes negative, [`add`] panics.
//
// Note that calls with a positive delta that occur when the counter is zero
// must happen before a [`wait`]. Calls with a negative delta, or calls with a
// positive delta that start when the counter is greater than zero, may happen
// at any time.
// Typically this means the calls to [`add`] should execute before the statement
// creating the thread or other event to be waited for.
// If a [`WaitGroup`] is reused to wait for several independent sets of events,
// new [`add`] calls must happen after all previous [`wait`] calls have returned.
pub fn (wg &mut WaitGroup) add(delta i32) {
	old_task_count := wg.task_count.fetch_add(delta, .seq_cst)
	new_task_count := old_task_count as i32 + delta
	if new_task_count < 0 {
		panic("sync: negative WaitGroup counter")
	}

	num_waiters := wg.wait_count.load(.seq_cst)

	if new_task_count == 0 && num_waiters > 0 {
		for !wg.wait_count.compare_exchange_weak(num_waiters, 0, .seq_cst, .seq_cst) {
			if wg.wait_count.load(.seq_cst) == 0 {
				break
			}
		}

		for i in 0 .. num_waiters {
			wg.sem.post()
		}
	}
}

// done decrements the [`WaitGroup`] counter by one.
pub fn (wg &mut WaitGroup) done() {
	wg.add(-1)
}

// wait blocks until the [`WaitGroup`] counter is zero.
pub fn (wg &mut WaitGroup) wait() {
	task_count := wg.task_count.load(.seq_cst)
	if task_count == 0 {
		// no tasks, no need to wait
		return
	}

	wg.wait_count.fetch_add(1, .seq_cst)
	wg.sem.wait() or {}
}
