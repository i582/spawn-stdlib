module internal

import mem
import mem.gc
import sys.libc
import profile
import prealloc

#[include("<setjmp.h>")]
#[include("<signal.h>")]

extern {
	fn closure_create(fun *void, data *void) -> *void
	fn closure_get_data() -> *mut void
}

pub var rt = Rt{}

pub comptime const (
	no_segfault_handler = false
)

pub struct DeferredFunction {
	func fn (_ *void)
	data *void
}

pub struct Thread {
	id usize
}

pub struct Rt {
	defer_stack  []DeferredFunction
	panic_buffer libc.jmp_buf
	panicked     bool
	panic_msg    ?string

	running_threads []Thread
}

pub struct Event {
	timestamp u64
	allocs    usize
}

pub fn register_thread(id usize) {
	rt.running_threads.push(Thread{ id: id })
}

pub fn set_panicked(msg string) {
	rt.panicked = true
	rt.panic_msg = msg
}

pub fn deferfn(func fn (_ *void), data *void) {
	rt.defer_stack.push(DeferredFunction{ func: func, data: data })
}

pub fn flushdefers(is_panic bool) {
	// When panicking, we want to run all defers only when panic strategy is
	// 'unwind'. In abort mode, we just want to abort immediately, so we don't
	// run any defers if we are panicking.
	comptime if panic_strategy == 'abort' {
		if is_panic {
			// Only panic should not run defers in abort mode, in other cases
			// defers should be run normally.
			return
		}
	}

	for rt.defer_stack.len > 0 {
		df := rt.defer_stack.pop() or { break }
		df.func(df.data)
	}
}

pub fn recoverimpl() {
	if !rt.panicked {
		return
	}
	rt.panicked = false
	libc.longjmp(rt.panic_buffer, 1)
}

pub fn runtimeinit() {
	comptime if !no_segfault_handler {
		setup_segfault_handler()
	}
	comptime if use_prealloc {
		prealloc.init()
	}
	comptime if with_gc {
		gc.init()
	}

	builtin_init()

	rt.defer_stack.ensure_cap(20)
}

pub fn runtimecleanup() {
	comptime if use_prealloc {
		prealloc.cleanup()
	}

	comptime if profile.is_cpu {
		profile.end_cpu()
		profile.save_cpu()
	}

	comptime if profile.is_mem {
		profile.end_mem()
		profile.save_mem()
	}

	// TODO:
	// comptime if profile.is_per_function {
	//     profile.dump_per_function_profiling()
	// }
}

pub fn closurecreate[F](fun F, data &void) -> F {
	return closure_create(fun as &void, data) as F
}

#[skip_profile]
pub fn closuregetdata() -> &mut void {
	data := closure_get_data()
	if data == nil {
		panic('closure is not created with closurecreate() or corrupted')
	}
	return mem.assume_safe_mut(data)
}
