module signal

import sys.libc

pub type SigHandler = fn (num i32)

pub type SigActionHandler = fn (num i32, info &libc.siginfo_t, context &void)

pub type SigInfo = libc.siginfo_t

pub enum SaFlags {
	empty
	// When catching a `Signal.SIGCHLD` signal, the signal will be
	// generated only when a child process exits, not when a child process
	// stops.
	no_cld_stop = libc.SA_NOCLDSTOP
	// When catching a `Signal.SIGCHLD` signal, the system will not
	// create zombie processes when children of the calling process exit.
	no_cld_wait = libc.SA_NOCLDWAIT
	// Further occurrences of the delivered signal are not masked during
	// the execution of the handler.
	no_defer = libc.SA_NODEFER
	// The system will deliver the signal to the process on a signal stack,
	// specified by each thread with `sigaltstack(2)`.
	on_stack = libc.SA_ONSTACK
	// The handler is reset back to the default at the moment the signal is
	// delivered.
	reset_hand = libc.SA_RESETHAND
	// Requests that certain system calls restart if interrupted by this
	// signal.  See the man page for complete details.
	restart = libc.SA_RESTART
	// This flag is controlled internally by Nix.
	sig_info = libc.SA_SIGINFO
}

pub struct SigSet {
	sigset libc.sigset_t
}

pub fn (s &mut SigSet) add(signal Signal) {
	libc.sigaddset(&mut s.sigset, signal as i32)
}

pub fn (s &mut SigSet) clear(signal Signal) {
	libc.sigdelset(&mut s.sigset, signal as i32)
}

pub fn (s &SigSet) contains(signal Signal) -> bool {
	res := libc.sigismember(&s.sigset, signal as i32)
	return res == 1
}

pub struct SigAction {
	libc.SigAction
}

pub fn SigAction.new(handler SigActionHandler, flags SaFlags, mask SigSet) -> SigAction {
	return SigAction{
		sa_sigaction: handler
		sa_flags: flags as i32
		sa_mask: mask.sigset
	}
}

pub fn SigAction.handler(handler SigHandler, flags SaFlags, mask SigSet) -> SigAction {
	return SigAction{
		sa_handler: handler
		sa_flags: flags as i32
		sa_mask: mask.sigset
	}
}

pub fn sigaction(signal Signal, sigact &SigAction) -> bool {
	return libc.sigaction(signal as i32, &sigact.SigAction, nil) == 0
}

pub enum Signal {
	unknown = -1
	// Hangup
	SIGHUP = C.SIGHUP
	// Interrupt
	SIGINT = C.SIGINT
	// Quit
	SIGQUIT = C.SIGQUIT
	// Illegal instruction (not reset when caught)
	SIGILL = C.SIGILL
	// Trace trap (not reset when caught)
	SIGTRAP = C.SIGTRAP
	// Abort
	SIGABRT = C.SIGABRT
	// Bus error
	SIGBUS = C.SIGBUS
	// Floating point exception
	SIGFPE = C.SIGFPE
	// Kill (cannot be caught or ignored)
	SIGKILL = C.SIGKILL
	// User defined signal 1
	SIGUSR1 = C.SIGUSR1
	// Segmentation violation
	SIGSEGV = C.SIGSEGV
	// User defined signal 2
	SIGUSR2 = C.SIGUSR2
	// Write on a pipe with no one to read it
	SIGPIPE = C.SIGPIPE
	// Alarm clock
	SIGALRM = C.SIGALRM
	// Software termination signal from kill
	SIGTERM = C.SIGTERM
	// To parent on child stop or exit
	SIGCHLD = C.SIGCHLD
	// Continue a stopped process
	SIGCONT = C.SIGCONT
	// Sendable stop signal not from tty
	SIGSTOP = C.SIGSTOP
	// Stop signal from tty
	SIGTSTP = C.SIGTSTP
	// To readers pgrp upon background tty read
	SIGTTIN = C.SIGTTIN
	// Like TTIN if (tp->t_local&LTOSTOP)
	SIGTTOU = C.SIGTTOU
	// Urgent condition on IO channel
	SIGURG = C.SIGURG
	// Exceeded CPU time limit
	SIGXCPU = C.SIGXCPU
	// Exceeded file size limit
	SIGXFSZ = C.SIGXFSZ
	// Virtual time alarm
	SIGVTALRM = C.SIGVTALRM
	// Profiling time alarm
	SIGPROF = C.SIGPROF
	// Window size changes
	SIGWINCH = C.SIGWINCH
	// Bad system call
	SIGSYS = C.SIGSYS
	// Emulator trap
	// SIGEMT = C.SIGEMT // TODO: not defined on linux
	// Information request
	// SIGINFO = C.SIGINFO // TODO: not defined on linux
}

pub fn (s Signal) str() -> string {
	return if s == .SIGHUP {
		"SIGHUP"
	} else if s == .SIGINT {
		"SIGINT"
	} else if s == .SIGQUIT {
		"SIGQUIT"
	} else if s == .SIGILL {
		"SIGILL"
	} else if s == .SIGTRAP {
		"SIGTRAP"
	} else if s == .SIGABRT {
		"SIGABRT"
	} else if s == .SIGBUS {
		"SIGBUS"
	} else if s == .SIGFPE {
		"SIGFPE"
	} else if s == .SIGKILL {
		"SIGKILL"
	} else if s == .SIGUSR1 {
		"SIGUSR1"
	} else if s == .SIGSEGV {
		"SIGSEGV"
	} else if s == .SIGUSR2 {
		"SIGUSR2"
	} else if s == .SIGPIPE {
		"SIGPIPE"
	} else if s == .SIGALRM {
		"SIGALRM"
	} else if s == .SIGTERM {
		"SIGTERM"
	} else if s == .SIGCHLD {
		"SIGCHLD"
	} else if s == .SIGCONT {
		"SIGCONT"
	} else if s == .SIGSTOP {
		"SIGSTOP"
	} else if s == .SIGTSTP {
		"SIGTSTP"
	} else if s == .SIGTTIN {
		"SIGTTIN"
	} else if s == .SIGTTOU {
		"SIGTTOU"
	} else if s == .SIGURG {
		"SIGURG"
	} else if s == .SIGXCPU {
		"SIGXCPU"
	} else if s == .SIGXFSZ {
		"SIGXFSZ"
	} else if s == .SIGVTALRM {
		"SIGVTALRM"
	} else if s == .SIGPROF {
		"SIGPROF"
	} else if s == .SIGWINCH {
		"SIGWINCH"
	} else if s == .SIGSYS {
		"SIGSYS"
	} else {
		"unknown"
	}
}

pub fn signal_from_str(str string) -> Signal {
	return match str {
		"SIGHUP" => .SIGHUP
		"SIGINT" => .SIGINT
		"SIGQUIT" => .SIGQUIT
		"SIGILL" => .SIGILL
		"SIGTRAP" => .SIGTRAP
		"SIGABRT" => .SIGABRT
		"SIGBUS" => .SIGBUS
		"SIGFPE" => .SIGFPE
		"SIGKILL" => .SIGKILL
		"SIGUSR1" => .SIGUSR1
		"SIGSEGV" => .SIGSEGV
		"SIGUSR2" => .SIGUSR2
		"SIGPIPE" => .SIGPIPE
		"SIGALRM" => .SIGALRM
		"SIGTERM" => .SIGTERM
		"SIGCHLD" => .SIGCHLD
		"SIGCONT" => .SIGCONT
		"SIGSTOP" => .SIGSTOP
		"SIGTSTP" => .SIGTSTP
		"SIGTTIN" => .SIGTTIN
		"SIGTTOU" => .SIGTTOU
		"SIGURG" => .SIGURG
		"SIGXCPU" => .SIGXCPU
		"SIGXFSZ" => .SIGXFSZ
		"SIGVTALRM" => .SIGVTALRM
		"SIGPROF" => .SIGPROF
		"SIGWINCH" => .SIGWINCH
		"SIGSYS" => .SIGSYS
		else => .unknown
	}
}

const SIGNALS = [
	Signal.SIGHUP,
	Signal.SIGINT,
	Signal.SIGQUIT,
	Signal.SIGILL,
	Signal.SIGTRAP,
	Signal.SIGABRT,
	Signal.SIGBUS,
	Signal.SIGFPE,
	Signal.SIGKILL,
	Signal.SIGUSR1,
	Signal.SIGSEGV,
	Signal.SIGUSR2,
	Signal.SIGPIPE,
	Signal.SIGALRM,
	Signal.SIGTERM,
	Signal.SIGCHLD,
	Signal.SIGCONT,
	Signal.SIGSTOP,
	Signal.SIGTSTP,
	Signal.SIGTTIN,
	Signal.SIGTTOU,
	Signal.SIGURG,
	Signal.SIGXCPU,
	Signal.SIGXFSZ,
	Signal.SIGVTALRM,
	Signal.SIGPROF,
	Signal.SIGWINCH,
	Signal.SIGSYS,
	// Signal.SIGEMT,
	// Signal.SIGINFO,
]
