module profile

import os

// block_segments returns a list of memory segments that should be blocked from
// being profiled. This way we can avoid strange failures in GCC unwind library.
fn block_segments() -> [](usize, usize) {
	exe_name := os.ARGS[0]
	blocklist := ["libc", "libgcc", "pthread",
	              "vdso", "dyld", "libsystem_c", "libsystem_platform",
	              "libsystem_malloc", "libsystem_notify"]

	mut segments := [](usize, usize){}

	os.SharedLibrary.each(fn (l &os.SharedLibrary) -> os.IterationControl {
		if l.name() == exe_name {
			for segment in l.segments() {
				if segment.name() == '__PAGEZERO' {
					// add pagezero segment to blocklist
					avam := segment.actual_virtual_memory_address(l)
					start := avam

					// THIS IS MOSTLY HACK, on macOS ARM64 I get strange
					// failures in GCC unwind library, and blocking additional
					// 1MB of memory seems to fix the issue.
					end := start + segment.len() + 1_048_576
					segments.push((start, end))
				}
			}
		}

		if !blocklist.any(|lib| l.name().contains(lib)) {
			// library not in blocklist, skip
			return .keep_going
		}

		for segment in l.segments() {
			avam := segment.actual_virtual_memory_address(l)
			start := avam
			end := start + segment.len()
			segments.push((start, end))
		}

		return .keep_going
	})

	return segments
}
