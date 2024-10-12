module runtime

import signal
import sys.libc
import internal
import backtrace

struct RawThread {
	handle libc.pthread_t
}

fn RawThread.create[T](mut stack_size usize, data *mut T, start fn (_ *mut T) -> *mut void) -> ![RawThread, ThreadCreationError] {
	mut t := RawThread{}
	mut attr := libc.pthread_attr_t{}
	libc.pthread_attr_init(&mut attr)

	if stack_size < libc.PTHREAD_STACK_MIN {
		stack_size = libc.PTHREAD_STACK_MIN
	}

	res := libc.pthread_attr_setstacksize(&mut attr, stack_size)
	if res == libc.EINVAL {
		libc.pthread_attr_destroy(&mut attr)

		// From documentation:
		// pthread_attr_setstacksize() will fail if:
		//  [EINVAL]  Invalid value for attr.
		//  [EINVAL]  stacksize is less than PTHREAD_STACK_MIN.
		//  [EINVAL]  stacksize is not a multiple of the system page size.
		//
		// Second case is already handled above, so we can assume that the stack
		// size is not a multiple of the system page size.
		psz := page_size()
		return error(ThreadCreationError.new("unable to set stack size ${stack_size}, `pthread_attr_setstacksize` failed with EINVAL, most likely the stack size is not a multiple of the system page size (${psz})"))
	}

	create_res := libc.pthread_create(&mut t.handle, &attr, start as fn (_ *mut void) -> *mut void, data)
	if create_res != 0 {
		libc.pthread_attr_destroy(&mut attr)

		// From documentation:
		// The pthread_create() function will fail if:
		//   [EAGAIN]  The system lacked the necessary resources to create
		//             another thread, or the system-imposed limit on the
		//             total number of threads in a process
		//             [PTHREAD_THREADS_MAX] would be exceeded.
		//
		//   [EPERM]   The caller does not have appropriate permission to set
		//             the required scheduling parameters or scheduling
		//             policy.
		//
		//   [EINVAL]  The value specified by attr is invalid.
		if create_res == libc.EAGAIN {
			return error(ThreadCreationError.new("unable to create thread, `pthread_create` failed with EAGAIN, the system lacked the necessary resources to create another thread"))
		}
		if create_res == libc.EPERM {
			return error(ThreadCreationError.new("unable to create thread, `pthread_create` failed with EPERM, the caller does not have appropriate permission to set the required scheduling parameters or scheduling policy"))
		}
		return error(ThreadCreationError.new("unable to create thread, `pthread_create` failed with code ${res}"))
	}

	// SAFETY: attr is always valid
	_ = libc.pthread_attr_destroy(&mut attr)
	return t
}

fn (t RawThread) join() -> ![unit, JoinThreadError] {
	res := libc.pthread_join(t.handle, nil)
	if res != 0 {
		return error(JoinThreadError{ msg: 'unable to join thread, `pthread_join` failed with code ${res}' })
	}
}

fn (t RawThread) detach() -> ![unit, DetachThreadError] {
	res := libc.pthread_detach(t.handle)
	if res != 0 {
		return error(DetachThreadError{ msg: 'unable to detach thread, `pthread_detach` failed with code ${res}' })
	}
}

fn (t RawThread) cancel() {
	libc.pthread_cancel(t.handle)
}

fn (t RawThread) id() -> usize {
	return 0 // TODO: t.handle as usize
}

pub fn send_signal(thread usize, sig i32) -> ! {
	ok := libc.pthread_kill(thread as libc.pthread_t, sig)
	if ok != 0 {
		return msg_err('unable to send signal to thread, `pthread_kill` failed')
	}
}

fn backtrace_signal_hander(num i32, info &signal.SigInfo, context &void) {
	// internal.rt.panic_mtx.lock()
	thread_id := internal.get_thread_id()
	thread_name := internal.get_thread_name()

	comptime if panic_strategy == 'unwind' && backtrace_mode != 'none' {
		fprintf(libc.STDERR, c'\nthread "%s" (%u):\n', thread_name.c_str(), thread_id)
		comptime if backtrace_mode == 'native' {
			print_backtrace()
		} $else {
			backtrace.display(skip: 2)
		}
	} $else {
		fprintf(libc.STDERR, c'thread "%s" (%u)\n', thread_name.c_str(), thread_id)
	}

	// internal.rt.panic_mtx.unlock()
	// internal.rt.panic_cond.notify_all()
}

pub fn setup_signal_handler_for_backtrace() {
	sa := signal.SigAction.new(backtrace_signal_hander, .sig_info, signal.SigSet.all())
	signal.sigaction(libc.SIGUSR1, &sa)
}
