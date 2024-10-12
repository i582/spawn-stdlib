module profile

import prealloc
import backtrace

struct Context {
	trace *usize
	len   i32
}

fn fast_backtrace(size &mut i32) -> *usize {
	mut ctx := Context{ trace: prealloc.alloc(8 * 100) as *usize }

	backtrace.trace_with_data(&mut ctx, fn (data &mut void, f backtrace.RawFrame) -> bool {
		context := unsafe { data as &mut Context }
		if context.len > 100 {
			return false
		}

		unsafe {
			context.trace[context.len] = f.pc()
		}

		context.len++
		return true
	})

	*size = ctx.len
	return ctx.trace
}
