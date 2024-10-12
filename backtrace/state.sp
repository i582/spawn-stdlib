module backtrace

import os

// shared_state stores cached state needed for backtrace functions.
//
// This variable is initialized lazily.
var shared_state = State{ inner: nil }

// State represents the state needed for this module to work.
struct State {
	inner *backtrace_state
}

// get gets the internal backtrace state, if it was nil then it is initialized.
fn (s &mut State) get() -> *backtrace_state {
	if s.inner == nil {
		s.inner = backtrace_create_state(unsafe { *os.ARGV }, 1, error_handler_impl, nil)
	}

	return s.inner
}
