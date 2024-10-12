module profile

import os
import signal
import fs
import time
import strings
import prealloc
import backtrace
import sys.libc

var (
	bsegments = [](usize, usize){}
)

// init_cpu initializes the CPU profiler with given sample rate in microseconds.
// The profiler will write its output to the given file.
pub fn init_cpu(rate i32, file string) {
	samples.ensure_cap(MAX_SAMPLES)
	unsafe { samples.set_len(MAX_SAMPLES) }

	bsegments = block_segments()
	register_signal_handler()

	signal.signal(.SIGINT, fn (s signal.Signal) {
		end_cpu()
		save_cpu()
		os.exit(0)
	})

	prealloc.init()

	set_timer(rate)

	sample_rate = rate
	filename = file
	start_time = time.system_now()
}

// pause_cpu pauses the CPU profiler.
pub fn pause_cpu() {
	set_timer(0)
}

// resume_cpu resumes the CPU profiler.
pub fn resume_cpu() {
	set_timer(sample_rate)
}

// end_cpu stops the CPU profiler.
pub fn end_cpu() {
	end_time = time.system_now()
	set_timer(0)
	unregister_signal_handler()
}

// save_cpu saves the CPU profiler output to the file specified in `init_cpu`.
pub fn save_cpu() {
	mut file := fs.open_file(filename, 'w') or { panic('failed to open `${filename}` file to save profile') }

	file.write_string('Type: cpu\n') or {}
	file.write_string('Samples: ${num_samples}\n') or {}
	file.write_string('Sample Rate: ${sample_rate * 1000}\n') or {}
	file.write_string('Start Time: ${start_time.unix_nanos() / 1000}\n') or {}
	file.write_string('Duration: ${end_time.duration_since(start_time).as_nanos()}\n') or {}

	file.write_string('--------------------------\n') or {}

	mut sb := strings.new_builder(100)

	for i in 0 .. num_samples {
		sample := samples[i]
		mut frame_index := 0 as usize

		for j := sample.size - 1; j >= 0; j-- {
			pc := unsafe { sample.trace[j] }
			info := backtrace.resolve_pc(pc) or { continue }

			fun_name := info.demangled_name()
			if fun_name == 'profile.cpu_handler' || fun_name == '_sigtramp' {
				break
			}

			if j != 0 && j != sample.size - 1 {
				sb.write_str(';')
			}

			sb.write_str(fun_name)
			sb.write_str('>')
			sb.write_str(info.filename)
			sb.write_str('>')
			sb.write_str(info.line.str())
			frame_index++
		}

		sb.write_str('\n')
	}

	file.write_string(sb.str()) or {}

	file.close() or {}
	prealloc.cleanup()
}

fn cpu_handler(signal i32, info &libc.siginfo_t, ctx &void) {
	if num_samples >= MAX_SAMPLES {
		return
	}

	ucontext := unsafe { ctx as *mut void as *mut libc.ucontext_t }
	mut addr := 0 as usize

	comptime if darwin && arm64 {
		unsafe {
			mcontext := (*ucontext).uc_mcontext
			if mcontext != nil {
				addr = (*mcontext).__ss.__pc
			}
		}
	}

	if addr != 0 && is_blocklisted(addr) {
		return
	}

	samples[num_samples].trace = fast_backtrace(&mut samples[num_samples].size)
	num_samples++
}

fn set_timer(rate i32) {
	mut timer := libc.itimerval{}
	timer.it_value.tv_sec = 0
	timer.it_value.tv_usec = rate
	timer.it_interval = timer.it_value
	if libc.setitimer(libc.ITIMER_PROF, &mut timer, nil) != 0 {
		panic('failed to set timer for SIGPROF, profiling is not available')
	}
}

fn register_signal_handler() {
	// SA_RESTART will only restart a syscall when it's safe to do so,
	// e.g. when it's a blocking read(2) or write(2). See man 7 signal.
	act := signal.SigAction.new(cpu_handler, .restart, signal.SigSet.empty())
	if !signal.sigaction(.SIGPROF, &act) {
		panic('failed to set signal handler for SIGPROF, profiling is not available')
	}
}

fn unregister_signal_handler() {
	signal.signal(.SIGPROF, libc.SIG_IGN as signal.SignalHandler)
}

fn is_blocklisted(pc usize) -> bool {
	for seg in bsegments {
		if pc >= seg[0] && pc < seg[1] {
			return true
		}
	}
	return false
}
