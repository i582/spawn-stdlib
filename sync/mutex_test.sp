module main

import sync

test "mutex can be locked and unlocked" {
	m := sync.Mutex.new()
	m.lock()
	m.unlock()
}

// This example shows how to use a mutex to protect a counter that is incremented by two threads.
// The counter is incremented 1000 times by each thread, so the final value should be 2000.
// Without the mutex, the counter would be incremented incorrectly because the threads would
// interfere with each other. You can try to comment out the lock and unlock calls to see the
// incorrect result.
#[example(sync.Mutex)]
test "counter with two threads protected by mutex" {
	end := chan unit{cap: 2}

	mut val := 0 as u64
	mut mtx := sync.Mutex.new()

	for i in 0 .. 2 {
		spawn fn () {
			for _ in 0 .. 1000 {
				mtx.lock()
				val++
				mtx.unlock()
			}

			end <- ()
		}()
	}

	<-end
	<-end

	t.assert_eq(val, 2000, "val should be 2000")
}
