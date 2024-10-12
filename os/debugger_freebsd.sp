module os

import sys.libc

// debugger_present returns true if the current process is being debugged
//
// In this case, it is useful to change the behavior to provide more information
// or do something to prevent reverse engineering.
pub fn debugger_present() -> bool {
	return libc.ptrace(libc.PT_TRACE_ME, 0, 1 as *void, 0) == -1
}
