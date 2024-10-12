module syscall

#[include("<sys/syscall.h>")]

extern {
	pub const (
		SYS_getrandom = 318
	)

	pub fn syscall(number i32, va ...*void) -> i32
}
