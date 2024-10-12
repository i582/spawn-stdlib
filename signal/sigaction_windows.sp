module signal

pub type SigHandler = fn (num i32)

pub type SigActionHandler = fn (num i32, info &i32, context &void)

pub struct SigAction {}

pub enum SaFlags {
	empty
	no_cld_stop
	no_cld_wait
	no_defer
	on_stack
	reset_hand
	restart
	sig_info
}

pub struct SigSet {
	sigset u32
}

pub fn SigSet.all() -> SigSet {
	return SigSet{ sigset: 0 }
}

pub fn SigSet.empty() -> SigSet {
	return SigSet{ sigset: 0 }
}

pub fn SigAction.new(handler SigActionHandler, flags SaFlags, mask SigSet) -> SigAction {
	return SigAction{}
}

pub fn SigAction.handler(handler SigHandler, flags SaFlags, mask SigSet) -> SigAction {
	return SigAction{}
}

pub fn sigaction(signal Signal, sigact &SigAction) -> bool {
	return false
}

pub enum Signal {
	unknown
	SIGHUP
	SIGINT
	SIGQUIT
	SIGILL
	SIGTRAP
	SIGABRT
	SIGBUS
	SIGFPE
	SIGKILL
	SIGUSR1
	SIGSEGV
	SIGUSR2
	SIGPIPE
	SIGALRM
	SIGTERM
	SIGCHLD
	SIGCONT
	SIGSTOP
	SIGTSTP
	SIGTTIN
	SIGTTOU
	SIGURG
	SIGXCPU
	SIGXFSZ
	SIGVTALRM
	SIGPROF
	SIGWINCH
	SIGSYS
}
