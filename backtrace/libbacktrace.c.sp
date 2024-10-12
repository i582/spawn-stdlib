module backtrace

// This file contains descriptions for the libbactrace library functions
// that are used to obtain backtraces with `--backtrace full`.

#[cflags_if(backtrace_mode == 'full' && darwin && arm64, '$SPAWN_ROOT/thirdparty/libbacktrace/backtrace.o')]
#[cflags_if(backtrace_mode == 'full' && darwin && !arm64, '$SPAWN_ROOT/thirdparty/libbacktrace/backtrace.c')]
#[cflags_if(backtrace_mode == 'full' && !darwin, '$SPAWN_ROOT/thirdparty/libbacktrace/backtrace.c')]
#[include_path('$SPAWN_ROOT/thirdparty/libbacktrace')]
#[include('backtrace.h')]

extern {
	#[typedef]
	struct backtrace_state {}

	#[spawnfmt.skip]
    fn backtrace_create_state(filename *u8,
                              threaded i32,
                              err_cb BacktraceErrorCb,
                              data *mut void) -> *backtrace_state

	#[spawnfmt.skip]
    fn backtrace_full(state *backtrace_state,
                      skip i32,
                      cb BacktraceFullCb,
                      err_cb BacktraceErrorCb,
                      data *mut void) -> i32

	#[spawnfmt.skip]
    fn backtrace_simple(state *backtrace_state,
                        skip i32,
                        cb BacktraceSimpleCb,
                        err_cb BacktraceErrorCb,
                        data *mut void) -> i32

	#[spawnfmt.skip]
    fn backtrace_pcinfo(state *backtrace_state,
                        pc usize,
                        cb BacktraceFullCb,
                        err_cb BacktraceErrorCb,
                        data *mut void) -> i32

	#[spawnfmt.skip]
    fn backtrace_syminfo(state *backtrace_state,
                         addr usize,
                         cb BacktraceSyminfoCb,
                         err_cb BacktraceErrorCb,
                         data *mut void) -> i32
}

// BacktraceFullCb represents a callback passed to [`backtrace_full`] and [`backtrace_pcinfo`] functions.
type BacktraceFullCb = fn (data *mut void, pc *void, filename *u8, line i32, fn_name *u8) -> i32

// BacktraceSimpleCb represents a callback passed to [`backtrace_simple`] function.
type BacktraceSimpleCb = fn (data *mut void, pc *void) -> i32

// BacktraceErrorCb represents a callback passed to all functions.
// Called when an error occurs.
type BacktraceErrorCb = fn (data *mut void, msg *u8, errnum i32)

// BacktraceSyminfoCb represents a callback passed to [`backtrace_syminfo`] function.
type BacktraceSyminfoCb = fn (data *mut void, pc *void, symname *u8, symval usize, symsize usize) -> i32
