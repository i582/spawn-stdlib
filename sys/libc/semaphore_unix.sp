module libc

// semaphore.h is not available on darwin
#[enable_if(!darwin)]
#[include("<semaphore.h>")]

extern {
	pub struct sem_t {}

	pub fn sem_init(sem *sem_t, _ i32, initial u32) -> i32
	pub fn sem_post(sem *sem_t) -> i32
	pub fn sem_wait(sem *sem_t) -> i32
	pub fn sem_trywait(sem *sem_t) -> i32
	pub fn sem_timedwait(sem *sem_t, abstime *timespec) -> i32
	pub fn sem_destroy(sem *sem_t) -> i32
	pub fn sem_close(sem *sem_t) -> i32
}
