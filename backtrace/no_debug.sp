module backtrace

import sync.atomic

var (
	// no_debug_info_found set to true if no debug info was found during stack trace
	// collection. Use `no_debug_info()` to get the value.
	no_debug_info_found = atomic.Bool.from(false)
)

// no_debug_info returns true if no debug info was found.
// This function is thread safe.
pub fn no_debug_info() -> bool {
	return no_debug_info_found.load(.seq_cst)
}
