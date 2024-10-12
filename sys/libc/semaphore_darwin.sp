module libc

#[include("<dispatch/dispatch.h>")]

extern {
	pub const (
		DISPATCH_TIME_NOW     = 0
		DISPATCH_TIME_FOREVER = 0
	)

	pub struct dispatch_semaphore_t {}
	pub struct dispatch_object_t {}
	pub type dispatch_time_t = u64

	pub fn dispatch_semaphore_create(initial i32) -> dispatch_semaphore_t
	pub fn dispatch_semaphore_wait(sem dispatch_semaphore_t, timeout dispatch_time_t) -> i32
	pub fn dispatch_semaphore_signal(sem dispatch_semaphore_t)
	pub fn dispatch_time(when dispatch_time_t, delta i64) -> dispatch_time_t
}
