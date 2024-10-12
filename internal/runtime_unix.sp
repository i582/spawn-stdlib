module internal

import os
import signal
import sys.libc

pub fn get_thread_handle() -> u32 {
	return 0 // TODO: pthread_self()
}

pub fn segfault_handler(sig i32, info &signal.SigInfo, context &void) {
	if sig != signal.Signal.SIGSEGV {
		return
	}

	mut buf := [200]u8{}
	libc.snprintf(&mut buf[0], 200, c"fatal error: invalid memory address or nil pointer dereference (address: 0x%08lx)
[signal: %d: segmentation fault]", info.si_addr as usize, sig)
	panic(string.view_from_c_str(&buf[0]))
}

pub fn setup_segfault_handler() {
	act := signal.SigAction.new(segfault_handler, .sig_info, signal.SigSet.empty())
	if !signal.sigaction(.SIGSEGV, &act) {
		println("Failed to set up SIGSEGV handler")
		os.exit(1)
	}
}
