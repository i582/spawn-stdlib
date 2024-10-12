module sync

import mem

// RingBuffer is a ring buffer implementation.
// Ring buffer is a data structure that uses a single, fixed-size buffer as if it were
// connected end-to-end. This structure lends itself easily to buffering data streams.
// When the ring buffer is full and a new element is inserted, the oldest element in the
// ring buffer is overwritten.
//
// Example:
// ```
// q := RingBuffer.new[i32](3)
// q.push(1)
// q.push(2)
// q.push(3)
// q.push(4) // this will overwrite the oldest element (1)
// assert q.pop() == 2
// assert q.pop() == 3
// assert q.pop() == 4
// ```
pub struct RingBuffer[T] {
	len  usize
	next usize
	cap  usize
	data *T
}

// new creates a new [`RingBuffer`] with the given capacity.
pub fn RingBuffer.new[T](cap usize) -> RingBuffer[T] {
	return RingBuffer[T]{
		data: mem.alloc(cap * mem.size_of[T]()) as *T
		cap: cap
	}
}

// push adds an element to the ring buffer.
// If the buffer is full, it will overwrite the oldest element.
// Returns true if the element was added successfully.
pub fn (q &mut RingBuffer[T]) push(v T) -> bool {
	mut pos := q.next + q.len
	if pos >= q.cap {
		pos = pos - q.cap
	}
	unsafe {
		q.data[pos] = v
	}
	q.len++
	return true
}

// pop removes and returns the oldest element from the ring buffer.
// If the buffer is empty, it will panic.
pub fn (q &mut RingBuffer[T]) pop() -> T {
	if q.len == 0 {
		panic("queue is empty")
	}
	value := unsafe { q.data[q.next] }
	q.len--
	q.next++
	if q.next >= q.cap {
		q.next = q.next - q.cap
	}

	return value
}
