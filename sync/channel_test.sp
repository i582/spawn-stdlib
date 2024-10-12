module main

import sync
import time

// This example shows how to use channels to create a simple
// worker pool. Separate thread sends values to a channel
// and workers read from the channel and process the values
// and send the results to another channel. A separate thread
// reads the results from the channel and prints them.
//
// `some_long_computation` defines as a function that simulates
// a long computation by sleeping for 100ms.
#[slow]
#[example(sync.Channel)]
test "simple channel workers" {
	some_long_computation := fn (val i32) -> i32 {
		time.sleep(100 * time.MILLISECOND)
		return val * 2
	}

	ch := chan i32{} // channel to send values to work on
	res_ch := chan i32{} // channel to send results

	// this thread send values to the channel
	spawn fn () {
		for i in 0 .. 5 {
			ch <- i
		}

		// this is very important to close the channel
		// to notify the workers that there are no more values
		// when this happens the workers will finish loops
		ch.close()
	}()

	// this threads are workers that process the values
	// try to change the count_workers to 1 to see the difference
	count_workers := 5
	mut wg := sync.WaitGroup.with_count(count_workers)
	for i in 0 .. count_workers {
		spawn fn () {
			for val in ch {
				res := some_long_computation(val)
				res_ch <- res
			}

			// when the worker finishes the loop
			// it should call done() on the WaitGroup
			// to signal that it has finished
			// when all workers have finished the `wait()`
			// will unblock and the program will finish
			wg.done()
		}()
	}

	// this is a consumer that reads the results
	// from the res_ch channel
	spawn fn () {
		for res in res_ch {
			println(res)
		}
	}()

	// wait for all workers to finish
	wg.wait()

	// close the res_ch channel to notify the consumer
	// that there are no more values
	res_ch.close()
}

#[slow]
test "simple blocking select with one receive operation" {
	ch := chan i32{}

	spawn fn () {
		time.sleep(20 * time.MILLISECOND)
		ch <- 20
	}()

	select {
		value := <-ch => {
			t.assert_eq(value, 20, "value should be 20")
			return
		}
	}

	t.fail("should not reach here")
}

#[slow]
test "simple blocking select with one send operation" {
	ch := chan i32{}

	spawn fn () {
		time.sleep(20 * time.MILLISECOND)
		t.assert_opt_eq(<-ch, 20, "value should be 20")
	}()

	select {
		ch <- 20 => {
			return
		}
	}

	t.fail("should not reach here")
}

#[slow]
test "simple blocking select with one send operation and 30ms timeout, should timeout" {
	ch := chan i32{}

	select {
		ch <- 20 => {
			return
		}
		30 * time.MILLISECOND => {
			return
		}
	}

	t.fail("should not reach here")
}

#[slow]
test "simple blocking select with one send operation and 30ms timeout, should not timeout" {
	ch := chan i32{}

	spawn fn () {
		time.sleep(20 * time.MILLISECOND)
		t.assert_opt_eq(<-ch, 20, "value should be 20")
	}()

	select {
		ch <- 20 => {
			return
		}
		30 * time.MILLISECOND => {
			t.fail("should not reach here")
			return
		}
	}

	t.fail("should not reach here")
}

#[slow]
test "simple non-blocking select with one send operation" {
	ch := chan i32{}

	select {
		ch <- 20 => {
			t.fail("should not reach here")
		}
		else => {
			return
		}
	}

	t.fail("should not reach here")
}
