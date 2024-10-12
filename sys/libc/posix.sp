module libc

#[include("<unistd.h>")]

pub const (
	SC_NPROCESSORS_ONLN = _SC_NPROCESSORS_ONLN
	SC_PAGESIZE         = _SC_PAGESIZE
)

extern {
	const (
		_SC_NPROCESSORS_ONLN = 0
		_SC_PAGESIZE         = 0
	)

	pub fn sysconf(name i32) -> u64
}
