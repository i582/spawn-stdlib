module runtime

import mem
import sync.atomic

// DEFAULT_STACK_SIZE is the default stack size of a thread.
// Used in [`spawn_thread`] function.
pub const DEFAULT_STACK_SIZE = 8 * 1024 * 1024

pub struct JoinThreadError {
	msg      string
	panicked bool
}

pub fn (e JoinThreadError) msg() -> string {
	return e.msg
}

pub struct DetachThreadError {
	msg string
}

pub fn (e DetachThreadError) msg() -> string {
	return e.msg
}

pub struct ThreadCreationError {
	msg string
}

pub fn ThreadCreationError.new(msg string) -> ThreadCreationError {
	return ThreadCreationError{ msg: msg }
}

pub fn (e ThreadCreationError) msg() -> string {
	return e.msg
}

// Handle is a handle to a thread.
//
// The `Handle` struct is used to control the lifecycle of a thread and
// to get the result of the thread when it is finished.
pub struct Handle[TRes] {
	// poison is a flag that indicates whether the thread panicked.
	poison atomic.Bool

	// panic_msg is a message that indicates the panic message.
	panic_msg string

	// raw_thread is a raw thread handle. On Windows it is a `HANDLE`,
	// on Unix it is a `pthread_t`.
	raw_thread RawThread

	// result is a result of the thread function. Valid only when [`done`] is `true`.
	result TRes

	// done is a flag that indicates whether the thread is finished.
	done atomic.Bool
}

// join suspends execution of the calling thread until the target thread terminates
// and returns the result of the target thread.
//
// If the `join` is failed to join the target thread, it returns an error.
// If the target thread panicked, it returns an error with the panic message.
//
// Example:
// ```
// fn main() {
//   h := spawn fn () -> i32 { return 0 }()
//   res := h.join().unwrap()
//   println(res) // 0
// }
// ```
pub fn (h &Handle[TRes]) join() -> ![TRes, JoinThreadError] {
	h.raw_thread.join()!
	if h.poison.load(.seq_cst) {
		return error(JoinThreadError{ msg: h.panic_msg, panicked: true })
	}
	return h.result
}

// detach detaches the thread, allowing it to run in the background.
//
// When the thread is detached, the thread handle is no longer valid.
// Calling `detach` on an already detached thread is unspecified behavior.
//
// Example:
// ```
// fn main() {
//   h := spawn fn () -> i32 { return 0 }()
//   h.detach().unwrap()
// }
// ```
pub fn (h &Handle[TRes]) detach() -> ![unit, DetachThreadError] {
	h.raw_thread.detach()!
}

// cancel requests that thread be canceled.
//
// The target thread's cancelability state and type determines when
// the cancellation takes effect.
//
// When the cancellation is acted on, the cancellation cleanup handlers
// for thread are called.
//
// When the last cancellation cleanup handler returns, the thread-specific
// data destructor functions will be called for thread. When the last
// destructor function returns, thread will be terminated
pub fn (h &Handle[TRes]) cancel() {
	h.raw_thread.cancel()
}

// id returns the integer thread id of the thread.
pub fn (h &Handle[TRes]) id() -> usize {
	return 0 // TODO: h.raw_thread as usize
}

// spawn_thread creates a new thread and returns a handle to it.
//
// The `spawn_thread` function takes a stack size, a data, and a
// callback function.
//
// The stack size is the size of the stack in bytes. If the stack
// size is 0, it uses the [`DEFAULT_STACK_SIZE`].
//
// If stack size is less than the minimum stack size, it uses the
// minimum stack size.
//
// If stack size is not a multiply of the page size, on Windows it
// rounds up to the next multiple of the page size, but on Unix it
// panics.
//
// The data is the data that will be passed to the callback function.
//
// The callback function is the function that will be executed in the
// new thread. The callback function takes the data as an argument and
// returns a result.
//
// This function is internal representation of the spawn expression.
// Don't use this function directly unless you know what you are doing.
//
// Example:
// ```
// fn main() {
//   h := spawn_thread(0, 10, fn (d i32) -> i32 { return 10 })
//   res := h.join().unwrap()
//   println(res) // 10
// }
// ```
//
// With `spawn` expression:
//
// ```
// fn main() {
//   h := spawn fn (d i32) -> i32 { return d }(10)
//   res := h.join().unwrap()
//   println(res) // 10
// }
// ```
pub fn spawn_thread[TRes, TData](mut stack_size usize, data TData, cb fn (d TData) -> TRes) -> &Handle[TRes] {
	handle := &mut Handle[TRes]{}
	ctx := mem.to_heap_mut(&mut ThreadContext[TRes, TData]{
		handle: handle
		cb: cb
		data: data
	})

	if stack_size == 0 {
		stack_size = DEFAULT_STACK_SIZE
	}
	handle.raw_thread = RawThread.create(stack_size, ctx, thread_wrapper[TRes, TData]).unwrap()
	return handle
}

struct ThreadContext[TRes, TData] {
	handle &mut Handle[TRes]
	cb     fn (_ TData) -> TRes
	data   TData
}

fn thread_wrapper[TRes, TData](arg &mut ThreadContext[TRes, TData]) -> *void {
	// TODO: we need generic function literals support to handle panics this way
	// defer fn () {
	//     if err := recover() {
	//         arg.handle.poison.store(true, .seq_cst)
	//         arg.handle.panic_msg = err
	//     }
	// }()

	arg.handle.result = arg.cb(arg.data)
	arg.handle.done.store(true, .seq_cst)
	return nil
}
