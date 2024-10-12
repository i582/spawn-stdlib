module libc

extern {
	type SigHandler = fn (num i32)
	type SigActionHandler = fn (num i32, info &siginfo_t, context &void)

	pub const (
		SA_NOCLDSTOP = 0
		SA_NOCLDWAIT = 0
		SA_NODEFER   = 0
		SA_ONSTACK   = 0
		SA_RESETHAND = 0
		SA_RESTART   = 0
		SA_SIGINFO   = 0
	)

	pub struct SigAction {
		sa_sigaction SigActionHandler
		sa_handler   SigHandler
		sa_mask      sigset_t
		sa_flags     i32
	}

	pub struct siginfo_t {
		si_signo  i32
		si_errno  i32
		si_code   i32
		si_pid    i32
		si_uid    i32
		si_status i32
		si_addr   *void
		si_value  i32
		si_band   i32
		pad       [7]usize
	}

	pub struct stack_t {
		ss_sp    *void
		ss_size  usize
		ss_flags i32
	}

	pub struct ucontext_t {
		uc_onstack  i32
		uc_sigmask  sigset_t
		uc_stack    stack_t
		uc_link     *ucontext_t
		uc_mcsize   i32
		uc_mcontext mcontext_t
	}

	pub fn sigfillset(set *mut sigset_t)
	pub fn sigemptyset(set *mut sigset_t)
	pub fn sigaddset(set *mut sigset_t, signum i32) -> i32
	pub fn sigdelset(set *mut sigset_t, signum i32) -> i32
	pub fn sigismember(set *sigset_t, signum i32) -> i32
	pub fn sigaction(signum i32, action *SigAction, old_action *SigAction) -> i32
}
