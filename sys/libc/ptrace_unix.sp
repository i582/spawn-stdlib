module libc

#[include("<sys/ptrace.h>")]

extern {
	#[enable_if(darwin || freebsd)]
	pub const (
		PT_TRACE_ME = 0
	)

	#[enable_if(linux)]
	pub const (
		PTRACE_TRACEME = 0
	)

	pub fn ptrace(request i32, pid u32, addr *void, data i32) -> i32
}
