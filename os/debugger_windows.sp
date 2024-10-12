module os

import sys.winapi

// debugger_present returns true if the current process is being debugged
//
// In this case, it is useful to change the behavior to provide more information
// or do something to prevent reverse engineering.
pub fn debugger_present() -> bool {
	return winapi.IsDebuggerPresent()
}
