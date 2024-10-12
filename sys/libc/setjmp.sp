module libc

extern {
	pub type jmp_buf = i32

	pub fn longjmp(env jmp_buf, val i32) -> never
}
