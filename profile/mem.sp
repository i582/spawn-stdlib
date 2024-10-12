module profile

import os
import fs
import signal
import time
import sync.atomic
import mem.gc
import prealloc
import backtrace

var running = atomic.Bool.from(false)

// is_running returns true if the memory profiler is running.
pub fn is_running() -> bool {
	return running.load(.seq_cst)
}

// alloc allocates a block of memory of the given size and returns a pointer to it.
// Used automatically by the compiler to allocate memory for objects in `mem.alloc`
// when the memory profiler is running.
//
// Don't use this function directly, use `mem.alloc` instead.
pub fn alloc(size usize) -> &mut u8 {
	ptr := gc.alloc(size)
	if ptr == nil {
		panic('failed to allocate memory')
	}

	if num_samples < MAX_SAMPLES {
		samples[num_samples].trace = fast_backtrace(&mut samples[num_samples].size)
		samples[num_samples].alloc = size
		num_samples++
	}

	return unsafe { &mut *ptr } // mem.assume_safe_mut(ptr)
}

// init_mem initializes the memory profiler.
// The memory profiler will save the profile to the given file when the program exits.
pub fn init_mem(file string) {
	samples.ensure_cap(MAX_SAMPLES)
	unsafe { samples.set_len(MAX_SAMPLES) }

	signal.signal(.SIGINT, fn (s signal.Signal) {
		end_mem()
		save_mem()
		os.exit(0)
	})

	prealloc.init()

	running.store(true, .seq_cst)
	filename = file
	start_time = time.system_now()
}

// pause_mem pauses the memory profiler.
pub fn pause_mem() {
	running.store(false, .seq_cst)
}

// resume_mem resumes the memory profiler.
pub fn resume_mem() {
	running.store(true, .seq_cst)
}

// end_mem stops the memory profiler.
pub fn end_mem() {
	end_time = time.system_now()
	running.store(false, .seq_cst)
}

// save_mem saves the memory profile to the file specified in `init_mem`.
pub fn save_mem() {
	if filename.len == 0 {
		// likely missed `runtime.save_mem()` call in non profile mode
		return
	}
	pause_mem()
	mut file := fs.open_file(filename, 'w') or { panic('failed to open `${filename}` file to save profile') }

	file.write_string('Type: mem\n') or {}
	file.write_string('Samples: ${num_samples}\n') or {}
	file.write_string('Start Time: ${start_time.unix_nanos() / 1000}\n') or {}
	file.write_string('Duration: ${end_time.duration_since(start_time).as_nanos()}\n') or {}

	file.write_string('--------------------------\n') or {}

	for i in 0 .. num_samples {
		sample := samples[i]

		for j := sample.size - 1; j >= 0; j-- {
			pc := unsafe { sample.trace[j] }
			info := backtrace.resolve_pc(pc) or { continue }

			fun_name := info.demangled_name()
			if fun_name == 'mem.alloc' || fun_name == 'profile.alloc' {
				break
			}

			if j != 0 && j != sample.size - 1 {
				file.write_string(';') or {}
			}

			file.write_string(fun_name) or {}
			file.write_string('>') or {}
			file.write_string(info.filename) or {}
			file.write_string('>') or {}
			file.write_string(info.line.str()) or {}
		}

		file.write_string(':${sample.alloc}') or {}
		file.write_string('\n') or {}
	}

	file.close() or {}
	prealloc.cleanup()
}
