module sync

import mem
import time
import rand
import strings
import sync.atomic

// Channel is a thread-safe FIFO queue.
//
// Channels are used to communicate between threads. When a value is sent on a channel, the
// control is blocked until some other thread receives the value. This allows threads
// to synchronize without explicit locks or condition variables.
//
// ```
// module main
//
// import sync
// import time
//
// fn some_long_computation(val i32) -> i32 {
//     time.sleep(1 * time.SECOND)
//     return val * 2
// }
//
// fn main() {
//     ch := chan i32{} // channel to send values to work on
//     res_ch := chan i32{} // channel to send results
//
//     // this thread send values to the channel
//     spawn fn () {
//         for i in 0 .. 5 {
//             ch <- i
//         }
//
//         // this is very important to close the channel
//         // to notify the workers that there are no more values
//         // when this happens the workers will finish loops
//         ch.close()
//     }()
//
//     // this threads are workers that process the values
//     // try to change the count_workers to 1 to see the difference
//     count_workers := 5
//     mut wg := sync.WaitGroup.with_count(count_workers)
//     for _ in 0 .. count_workers {
//         spawn fn () {
//             for val in ch {
//                 res := some_long_computation(val)
//                 res_ch <- res
//             }
//
//             // when the worker finishes the loop
//             // it should call done() on the WaitGroup
//             // to signal that it has finished
//             // when all workers have finished the `wait()`
//             // will unblock and the program will finish
//             wg.done()
//         }()
//     }
//
//     // this is a consumer that reads the results
//     // from the res_ch channel
//     spawn fn () {
//         for res in res_ch {
//             println(res)
//         }
//     }()
//
//     // wait for all workers to finish
//     wg.wait()
//
//     // close the res_ch channel to notify the consumer
//     // that there are no more values
//     res_ch.close()
// }
// ```
//
// Channels can be buffered or unbuffered. Buffered channels have a fixed capacity and
// will block the sender if the buffer is full or the receiver if the buffer is empty.
// Unbuffered channels have a capacity of 0 and will block the sender until the receiver
// is ready to receive the value or block the receiver until the sender is ready to send
// the value.
//
// To create buffered channel use `chan T{cap: 10}` and to create unbuffered channel use `chan T{}`.
//
// Channels can be closed. Once a channel is closed, it is an error to send on the channel.
// Receivers can still receive values from a closed channel until the channel is empty.
// Closing a channel is useful to signal that no more values will be sent on the channel.
// For exampple, when iterating over a channel, the sender can close the channel to signal
// that no more values will be sent and this loop can end.
//
// ```
// for el in ch {
//    // ...
// }
//
// // in other thread
// ch.close()
// ```
pub struct Channel[T] {
	impl &mut ChannelImpl
}

pub fn new_channel[T](cap usize) -> Channel[T] {
	return Channel[T]{ impl: ChannelImpl.new(mem.size_of[T](), cap) }
}

// close closes the channel. Closing a channel is a signal that no more
// values will be sent on the channel. If somt thread loops over the channel
// closing the channel will signal that the loop should end.
//
// Send on a closed channel will panic.
// Closing a closed channel will panic.
pub fn (mut c Channel[T]) close() {
	c.impl.close()
}

// is_closed returns true if the channel is closed.
pub fn (c Channel[T]) is_closed() -> bool {
	return c.impl.is_closed()
}

// next returns the next value from the channel. This method is alias
// for [`recv`] method. It used to implement `Interator` interrface.
//
// Thanks to this method you can iterate over the channel using `for` loop.
// Example:
// ```
// for el in ch {
//    println(el)
// }
// ```
// This is equivalent to:
// ```
// for {
//    el := (<-ch) or { break }
//    println(el)
// }
// ```
// This loop will block until no more values are sent on the channel.
pub fn (mut c Channel[T]) next() -> ?T {
	return c.recv()
}

// can_recv returns true if there is a value ready to be received on
// the channel or there is a sender waiting to send a value.
pub fn (c Channel[T]) can_recv() -> bool {
	return c.impl.can_recv()
}

// can_send returns true if the channel is not full or there is a receiver
// waiting to receive the value.
pub fn (c Channel[T]) can_send() -> bool {
	return c.impl.can_send()
}

// is_empty returns true if the channel is empty. This function is always
// returns true for unbuffered channels.
pub fn (c Channel[T]) is_empty() -> bool {
	return c.impl.size() == 0
}

// send sends a value on the channel. This is impleentation of the `send`
// operator `<-`.
//
// ```
// ch <- 10
// // is equivalent to
// ch.send(10)
// ```
//
// If the channel is unbuffered, the sender will block until the receiver
// is ready to receive the value.
//
// If the channel is buffered, the sender will block if the buffer is full,
// otherwise it will send the value without blocking.
//
// If the channel is closed, the send will panic.
#[skip_inline]
pub fn (mut c Channel[T]) send(data T) {
	c.impl.send(mem.to_heap(&data))
}

// recv receives a value from the channel. This is implementation of the `recv`
// operator `<-`.
//
// ```
// val := <-ch
// // is equivalent to
// val := ch.recv()
// ```
//
// If the channel is unbuffered, the receiver will block until the sender is
// ready to send the value.
//
// If the channel is buffered, the receiver will block if the buffer is empty,
// otherwise it will receive the value without blocking.
//
// If the channel is closed and there are no more values to receive, the recv
// will return `none`.
pub fn (mut c Channel[T]) recv() -> ?T {
	ptr := c.impl.recv()?
	return unsafe { *(ptr as *T) }
}

// cap returns the capacity of the channel.
// For unbuffered channels, this function always returns 0.
pub fn (c Channel[T]) cap() -> usize {
	return c.impl.cap()
}

// size returns the number of values in the channel.
// For unbuffered channels, this function always returns 0.
pub fn (c Channel[T]) size() -> usize {
	return c.impl.size()
}

// str returns a string representation of the channel.
pub fn (c Channel[T]) str() -> string {
	mut sb := strings.new_builder(60)
	sb.write_str("chan ")
	sb.write_str(T.str())
	sb.write_str("{ size: ")
	sb.write_str(c.size().str())
	sb.write_str(", cap: ")
	sb.write_str(c.impl.queue.cap.str())
	sb.write_str(", ")
	sb.write_str("closed: ")
	sb.write_str(c.is_closed().str())
	sb.write_str(" }")
	return sb.str()
}

pub const (
	REC  = 0
	SEND = 1
)

struct WaitQueueNode {
	sem  &Semaphore
	next *mut WaitQueueNode
	prev *mut *WaitQueueNode
}

// channel_select is a low-level function that allows to select on multiple channels. This
// function is used to implement `select` expression.
//
// - channels is a slice of channels to select on
//
// - directions is a slice of directions for each channel. 0 means receive, 1 means send
//
// - obj_refs is a slice of pointers to objects where the received values will be stored
//   or pointers to values to send, if the value is nil, the received value will be discarded
//   and received value will not be stored
//
// - non_blocking is a flag that indicates if the select should be non-blocking, if no channel
//   is ready to receive or send, the function will return immediately and will not block thread
//
// - timeout is a duration after which the function will return if no channel is ready to receive
//   or send. If the timeout is set to `time.INFINITE` the function will block until some channel
//   is ready to receive or send.
//
// Returns following values:
// - >= 0 — index of the channel that is ready to receive or send
// - -1 — no channels are ready to receive or send and [`non_blocking`] is set to true
// - -2 — timeout is reached and no channels are ready to receive or send
pub fn channel_select(channels []&mut ChannelImpl, directions []i32, obj_refs []*mut void, non_blocking bool, timeout time.Duration) -> i32 {
	if channels.len == 0 {
		// no channels to select on
		return -1
	}

	// sem represent common semaphore of current thread for all channels
	// if there are no channels ready to receive or send, the thread will wait
	// on this semaphore. When some channel is ready to receive or send, channel
	// will post this semaphore and the thread will wake up.
	mut sem := Semaphore.new(0).unwrap()
	mut queues := []WaitQueueNode{len: channels.len, init: || WaitQueueNode{ sem: sem }}

	mut event_idx := -1

	outer: for {
		rnd := rand.next_u32() % channels.len as u32
		mut num_closed := 0
		for i in 0 .. channels.len {
			index := (i + rnd) % channels.len as i32
			ch := channels[index]

			if ch.is_closed() {
				num_closed++
				continue
			}

			dir := directions[index]
			if dir == REC && ch.can_recv() {
				rec := ch.recv().unwrap()

				// value can be nil if this receive operation discard value
				if obj_refs[index] != nil {
					mem.fast_copy(unsafe { obj_refs[index] as *mut u8 }, unsafe { rec as *u8 }, ch.obj_size)
				}

				event_idx = index as i32
				break outer
			} else if dir == SEND && ch.can_send() {
				ch.send(mem.to_heap_ptr(unsafe { obj_refs[index] as *u8 }, ch.obj_size))
				event_idx = index as i32
				break outer
			}
		}

		// all channels are closed, so return immediately
		if num_closed == channels.len {
			event_idx = -1
			break
		}

		// At this point no channel is ready to receive or send
		if non_blocking {
			// if `non_blocking` is set to true, return immediately,
			// this branch is represent non-blocking select with
			// `else` branch
			event_idx = -1
			break
		}

		// This code adds new head of the linked list of select waiting
		// to each channel. When some channel is ready to receive or send
		// it will post the semaphore and the thread will wake up.
		for i, ch in channels {
			dir := directions[i]
			mut cur_head := queues[i]
			cur_head.sem = sem

			ch_head := if dir == REC { ch.select_r_waiting } else { ch.select_w_waiting }

			cur_head.prev = &ch_head as *mut *WaitQueueNode
			cur_head.next = ch_head

			if cur_head.next != nil {
				unsafe {
					cur_head.next.prev = &cur_head.next as *mut *WaitQueueNode
				}
			}

			cur_head_ptr := mem.to_heap_mut(&mut cur_head)
			if dir == REC {
				ch.select_r_waiting = cur_head_ptr
			} else {
				ch.select_w_waiting = cur_head_ptr
			}

			queues[i] = cur_head
		}

		// When all all channels are updated with new head of the linked list
		// of select waiting, we can wait on the semaphore. When some
		// channel is ready to receive or send, it will post the semaphore
		// and the thread will wake up.

		if timeout != time.INFINITE {
			// if timeout is set, wait with timeout
			if sem.timed_wait(timeout).unwrap() {
				// no channel is ready to receive or send and timeout is reached
				event_idx = -2
				break outer
			}
		} else {
			// if timeout is not set, wait indefinitely
			sem.wait() or {}
		}
	}

	// At this point `select` is finished and we need to cleanup
	// the linked list of select waiting for each channel.
	//
	// This code restores the linked list of select waiting for each channel
	// to the state before the `select` was called. This is importatnt since
	// several `select` can be called in the same thread and after we finish
	// one `select` we restore the linked list of select waiting to the state
	// correct for the next `select`.
	for i, ch in channels {
		dir := directions[i]
		mut queue := queues[i]

		unsafe {
			if queue.prev != nil {
				*queue.prev = queue.next
			}
			if queue.next != nil {
				queue.next.prev = queue.prev

				// TODO: this condition should be removed
				if queue.next != nil {
					queue.next.sem.post()
				}
			}
		}
	}

	sem.destroy() or {}
	return event_idx
}

// ChannelImpl is a low-level implementation of the channel. This implementation
// is not used generics since we want to select on different channels with different
// types. This implementation is used to implement the [`Channel`] type.
//
// This implementation support both buffered and unbuffered channels.
struct ChannelImpl {
	// obj_size is a size of the object that is stored in the channel
	// Used primarly in [`channel_select`] to copy the value from the channel
	// to the object passed to the `select`.
	obj_size usize

	// queue is a ring buffer that stores values
	// for buffered channels
	queue RingBuffer[*void]

	// data is a value that is stored in the channel
	// for unbuffered channels
	data *void

	// r_mu is a mutex that protects the receiver operations
	r_mu &Mutex

	// w_mu is a mutex that protects the sender operations
	w_mu &Mutex

	// r_cond represents waiting queue for receivers
	r_cond &Cond

	// r_waiting is a number of receivers waiting for the value
	// to be sent on the channel
	r_waiting i32

	// w_cond represents waiting queue for senders
	w_cond &Cond

	// w_waiting is a number of senders waiting for the value
	// to be received from the channel
	w_waiting i32

	// select_r_waiting is a tail of the linked list of select waiting
	select_r_waiting *mut WaitQueueNode

	// select_w_waiting is a tail of the linked list of select waiting
	select_w_waiting *mut WaitQueueNode

	// closed indicates if the channel is closed
	closed atomic.Bool

	// lock is mutex protecting the whole channel
	lock &Mutex
}

fn ChannelImpl.new(obj_size usize, cap usize) -> &mut ChannelImpl {
	return &mut ChannelImpl{
		queue: RingBuffer.new(cap)
		obj_size: obj_size
		r_mu: Mutex.new()
		w_mu: Mutex.new()
		lock: Mutex.new()
		r_cond: Cond.new()
		w_cond: Cond.new()
	}
}

fn (c &mut ChannelImpl) close() {
	c.lock()
	if c.is_closed() {
		c.unlock()
		panic("channel already closed")
	}
	c.closed.store(true, .seq_cst)
	c.r_cond.notify_all()
	c.w_cond.notify_all()
	c.unlock()
}

fn (c &ChannelImpl) is_closed() -> bool {
	return c.closed.load(.seq_cst)
}

fn (c &mut ChannelImpl) send(data *void) {
	if c.is_closed() {
		panic('cannot send on closed channel')
	}

	if c.queue.cap == 0 {
		c.unbuffered_send(data)
		return
	}

	c.buffered_send(data)
}

fn (c &mut ChannelImpl) next() -> ?*void {
	return c.recv()
}

fn (c &mut ChannelImpl) recv() -> ?*void {
	if c.queue.cap == 0 {
		return c.unbuffered_recv()
	}
	return c.buffered_recv()
}

fn (c &mut ChannelImpl) buffered_send(data *void) {
	c.lock()
	for c.queue.len == c.queue.cap {
		c.w_waiting++
		c.w_cond.wait(c.lock)
		c.w_waiting--
	}

	c.queue.push(data)

	if c.r_waiting > 0 {
		c.r_cond.notify_one()
	}

	if c.select_r_waiting != nil {
		unsafe { c.select_r_waiting.sem.post() }
	}

	c.unlock()
}

fn (c &mut ChannelImpl) buffered_recv() -> ?*void {
	c.lock()
	for c.queue.len == 0 {
		if c.is_closed() {
			c.unlock()
			return none
		}
		c.r_waiting++
		c.r_cond.wait(c.lock)
		c.r_waiting--
	}

	data := c.queue.pop()

	if c.w_waiting > 0 {
		c.w_cond.notify_one()
	}

	if c.select_w_waiting != nil {
		unsafe { c.select_w_waiting.sem.post() }
	}

	c.unlock()
	return data
}

fn (c &mut ChannelImpl) unbuffered_send(data *void) {
	c.w_mu.lock()
	c.lock()

	if c.is_closed() {
		c.unlock()
		c.w_mu.unlock()
		panic("cannot send on closed channel")
	}

	c.data = data
	c.w_waiting++

	if c.r_waiting > 0 {
		c.r_cond.notify_one()
	}

	if c.select_r_waiting != nil {
		unsafe { c.select_r_waiting.sem.post() }
	}

	c.w_cond.wait(c.lock)

	c.unlock()
	c.w_mu.unlock()
}

fn (c &mut ChannelImpl) unbuffered_recv() -> ?*void {
	c.r_mu.lock()
	c.lock()

	for !c.is_closed() && c.w_waiting == 0 {
		if c.select_w_waiting != nil {
			unsafe { c.select_w_waiting.sem.post() }
		}

		c.r_waiting++
		c.r_cond.wait(c.lock)
		c.r_waiting--
	}

	if c.is_closed() {
		c.unlock()
		c.r_mu.unlock()
		return none
	}

	data := c.data
	c.w_waiting--
	c.w_cond.notify_one()

	if c.select_w_waiting != nil {
		unsafe { c.select_w_waiting.sem.post() }
	}

	c.unlock()
	c.r_mu.unlock()
	return data
}

fn (c &ChannelImpl) size() -> usize {
	// cap is immutable, so it's safe to read without locking
	if c.queue.cap == 0 {
		return 0
	}
	return c.queue.len
}

fn (c &ChannelImpl) cap() -> usize {
	return c.queue.cap
}

fn (c &ChannelImpl) is_full() -> bool {
	// cap is immutable, so it's safe to read without locking
	if c.queue.cap == 0 {
		return c.w_waiting > 0
	}
	return c.queue.len == c.queue.cap
}

fn (c &ChannelImpl) can_recv() -> bool {
	// cap is immutable, so it's safe to read without locking
	if c.queue.cap == 0 {
		return c.w_waiting > 0
	}
	return c.queue.len > 0
}

fn (c &ChannelImpl) can_send() -> bool {
	// cap is immutable, so it's safe to read without locking
	if c.queue.cap == 0 {
		return c.r_waiting > 0
	}
	return c.queue.len < c.queue.cap
}

fn (c &mut ChannelImpl) lock() {
	c.lock.lock()
}

fn (c &mut ChannelImpl) unlock() {
	c.lock.unlock()
}
