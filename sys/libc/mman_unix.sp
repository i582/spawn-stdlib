module libc

#[include("<sys/mman.h>")]

extern {
	pub const (
		MAP_PRIVATE = 0
		MAP_ANON    = 0
		MAP_STACK   = 0
		MAP_FIXED   = 0
	)

	pub const (
		PROT_NONE  = 0
		PROT_READ  = 0
		PROT_WRITE = 0
	)

	pub const (
		MAP_FAILED = nil as *void
	)

	pub fn mmap(addr *void, len usize, prot i32, flags i32, fd i32, offset i64) -> *mut void
	pub fn munmap(addr *mut void, len usize) -> i32
	pub fn mprotect(addr *mut void, len usize, prot i32) -> i32
}
