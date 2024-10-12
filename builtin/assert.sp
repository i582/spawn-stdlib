module builtin

import intrinsics

#[track_caller]
fn assert_impl(cond bool, msg string, cond_str string) {
	if intrinsics.likely(cond) {
		return
	}

	if msg.len == 0 {
		panic("assertion '${cond_str}' failed")
	}

	panic("assertion '${cond_str}' failed: ${msg}")
}
