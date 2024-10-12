module backtrace

import os
import errno

// Backtrace is captured OS thread stack backtrace.
//
// This type represents a stack backtrace for an OS thread captured at a
// previous point in time.
//
// See [`capture`] for mre information.
pub struct Backtrace {
	frames []ResolvedFrame
}

// frames returns backtrace frames starting from [`skip`].
//
// Example:
// ```
// frames := backtrace.capture().unwrap().frames(skip: 1)
// for frame in frames {
//     println(frame.demangled_name())
// }
// ```
pub fn (b &Backtrace) frames(skip usize) -> []ResolvedFrame {
	return b.frames[skip..]
}

// capture captures a stack backtrace of the current thread.
//
// This function will capture a stack backtrace of the current OS thread of
// execution, returning a [`Backtrace`] type which can be later used to print
// the entire stack trace or render it to a string.
//
// Example:
// ```
// bt := backtrace.capture().unwrap()
// println(bt.frames.first().demangled_name())
// ```
pub fn capture() -> !Backtrace {
	mut frames := []ResolvedFrame{}
	threaded := 1
	state := backtrace_create_state(unsafe { *os.ARGV }, threaded, error_handler_impl, nil)
	backtrace_full(state, 0, capture_callback_impl, error_callback_impl, &mut frames)
	if no_debug_info() {
		return error(NoDebugInfoError{})
	}
	return Backtrace{ frames: frames }
}

// trace inspects the current call-stack, passing all active frames into the
// [`on_frame`] callback provided to calculate a stack trace.
//
// The given callback [`on_frame`] is yielded instances of a [`Frame`] which represent
// information about that call frame on the stack. The callback is yielded frames in
// a top-down fashion (most recently called functions first).
//
// The callback's return value is an indication of whether the backtrace should
// continue. Return `false` to terminate the backtrace and return immediately.
//
// Once a [`Frame`] is acquired you will likely want to call [`resolve_frame`]
// to convert the [`RawFrame`] (default value of the `Frame` union type that is passed
// to the [`on_frame`] callback) to a [`ResolvedFrame`] through which the name and/or
// filename/line number can be obtained.
//
// Example:
// ```
// backtrace.trace(fn (f backtrace.RawFrame) -> bool {
//     println(f)
//     return true
// })
// ```
// This example will print all [`WarFrame`] obtained for the current thread.
//
// ```
// backtrace.trace(fn (f backtrace.RawFrame) -> bool {
//     backtrace.resolve_frame(f, fn (s backtrace.ResolvedFrame) -> bool {
//         println(s.demangled_name())
//         return true
//     })
//     return true
// })
// ```
// This example will print all frame functions obtained for the current thread.
pub fn trace(on_frame fn (f RawFrame) -> bool) {
	cb := fn (data *mut void, pc *void) -> i32 {
		trace_data := data as *TraceData
		res := unsafe { trace_data.on_frame(RawFrame{ pc: pc as usize }) }
		if !res {
			return 1
		}

		return 0
	}

	data := TraceData{ on_frame: on_frame }
	backtrace_simple(shared_state.get(), 0, cb, error_handler_impl, &data as *void)
}

// trace_with_data inspects the current call-stack, passing all active frames into the
// [`on_frame`] callback provided to calculate a stack trace.
//
// This function is the same as [`trace`], but accepts user-defined data that will be
// passed to the [`on_frame`] callback. This can be useful for avoiding the cost of
// closures on hot paths, such as profiling.
//
// See [`trace`] for more info.
//
// Example:
// ```
// import prealloc
//
// struct Context {
//     trace *usize
//     len   i32
// }
//
// fn fast_backtrace() -> (*usize, i32) {
//     mut ctx := Context{ trace: prealloc.alloc(8 * 100) as *usize }
//
//     backtrace.trace_with_data(&mut ctx, fn (data &mut void, f backtrace.RawFrame) -> bool {
//         context := unsafe { data as &mut Context }
//         if context.len > 100 {
//             return false
//         }
//
//         unsafe {
//             context.trace[context.len] = f.pc()
//         }
//
//         context.len++
//         return true
//     })
//
//     return ctx.trace, ctx.len
// }
// ```
// In this example we collect the backtrace into a pre-allocated C-like array.
// This is necessary because if [`fast_backtrace`] is used inside a signal handler,
// we cannot allocate memory using normal methods.
pub fn trace_with_data(user_data &mut void, on_frame fn (d &void, f RawFrame) -> bool) {
	cb := fn (data *mut void, pc *void) -> i32 {
		trace_data := data as *TraceDataEx
		res := unsafe { trace_data.on_frame(trace_data.user_data, RawFrame{ pc: pc as usize }) }
		if !res {
			return 1
		}
		return 0
	}

	trace_data := TraceDataEx{ on_frame: on_frame, user_data: user_data }
	backtrace_simple(shared_state.get(), 0, cb, error_handler_impl, &trace_data as *void)
}

// resolve_frame resolve a previously capture [`frame`] to a [`ResolvedFrame`],
// passing the frame to the specified [`on_frame`] callback.
//
// The callback returns true or false and the this value will be returned
// from [`resolve_frame`] as well. This allows the backtrace to stop if some
// frame is found.
//
// Example:
// ```
// backtrace.trace(fn (f backtrace.RawFrame) -> bool {
//     return backtrace.resolve_frame(f, fn (s backtrace.ResolvedFrame) -> bool {
//         if s.demangled_name() == "mod.my_function" {
//             return false
//         }
//         println(s.demangled_name())
//         return true
//     })
// })
// ```
pub fn resolve_frame(frame RawFrame, on_frame fn (s ResolvedFrame) -> bool) -> bool {
	cb := fn (data *mut void, pc *void, filename *u8, line i32, fn_name *u8) -> i32 {
		resolve_data := data as *mut ResolveData

		resolved_frame := ResolvedFrame{
			pc: pc
			filename: string.from_c_str(filename)
			line: line
			func: string.from_c_str(fn_name)
		}
		unsafe {
			res := resolve_data.on_frame(resolved_frame)
			resolve_data.return_value = res
		}
		return 0
	}

	mut data := ResolveData{ on_frame: on_frame }
	backtrace_pcinfo(shared_state.get(), frame.pc, cb, error_handler_impl, &mut data as *mut void)

	return data.return_value
}

// resolve_pc resolved a Programm Counter [`pc`] of previously capture
// frame to a [`ResolvedFrame`].
//
// If [`pc`] cannot be resolved, the function returns `none`.
//
// This function is similar to [`resolve_frame`], but is better suited
// for cases where the backtrace was obtained separately storing only
// the pc values and then these counters need to be resolved.
//
// Example:
// ```
// pcs := [0x00, 0x01] // just for example
// frame := backtrace.resolve_pc(pcs[0]) or { return }
// println(frame.demangled_name())
// ```
pub fn resolve_pc(pc usize) -> ?ResolvedFrame {
	mut info := ResolvedFrame{}

	backtrace_pcinfo(shared_state.get(), pc, fn (data *mut void, this_pc *void, filename_ptr *u8, line i32, fn_name_ptr *u8) -> i32 {
		inf := data as *mut ResolvedFrame
		unsafe {
			inf.pc = this_pc
			inf.filename = string.from_c_str(filename_ptr)
			inf.line = line
			inf.func = string.from_c_str(fn_name_ptr)
		}
		return 0
	}, error_handler_impl, &mut info)

	if info.func.len == 0 || info.line == 0 {
		return none
	}
	return info
}

// capture_callback_impl is a callback that is called for each frame found.
#[no_inline]
fn capture_callback_impl(data *mut void, pc *void, filename_ptr *u8, line i32, fn_name_ptr *u8) -> i32 {
	mut filename := '???'
	if filename_ptr != nil {
		filename = string.view_from_c_str(filename_ptr)
	}
	mut func_name := '???'
	if fn_name_ptr != nil {
		func_name = string.view_from_c_str(fn_name_ptr)
	}

	if data != nil {
		// SAFETY: data is always a pointer to an array of ResolvedFrame.
		unsafe {
			frames := data as *mut []ResolvedFrame
			(*frames).push(ResolvedFrame{
				pc: pc
				filename: filename.clone()
				line: line
				func: func_name
			})
		}
	}

	return 0
}

#[no_inline]
fn error_callback_impl(data *void, msg *u8, errnum i32) {
	eprint('libbacktrace error:', string.view_from_c_str(msg))
	if errnum > 0 {
		eprint(' :')
		eprint(errno.from_i32(errnum).desc())
	}
	// errnum == -1 is a special case when no debug info was found.
	if errnum == -1 {
		no_debug_info_found.store(true, .seq_cst)
	}
	eprintln()
}

#[no_inline]
fn error_handler_impl(data *void, msg *u8, errnum i32) {
	eprint('create state libbacktrace error:', string.view_from_c_str(msg))
	if errnum > 0 {
		eprint(' :')
		eprint(errno.from_i32(errnum).desc())
	}
	eprintln()
}

struct TraceData {
	on_frame fn (f RawFrame) -> bool
}

struct TraceDataEx {
	on_frame  fn (d &void, f RawFrame) -> bool
	user_data &mut void
}

struct ResolveData {
	on_frame     fn (f ResolvedFrame) -> bool
	return_value bool
}
