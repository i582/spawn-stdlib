module libc

pub type sigset_t = u32

pub type mcontext_t = *mut __darwin_mcontext64

extern {
	#[typedef]
	pub struct __darwin_mcontext64 {
		__es __darwin_arm_exception_state64
		__ss __darwin_arm_thread_state64
		__ns __darwin_arm_neon_state64
	}

	pub struct __darwin_arm_exception_state64 {}

	pub struct __darwin_arm_thread_state64 {
		__x    [29]u64
		__fp   u64
		__lr   u64
		__sp   u64
		__pc   u64
		__cpsr u32
		__pad  u32
	}

	pub struct __darwin_arm_neon_state64 {}
}
