module libc

#[include("<limits.h>")] // needed for PTHREAD_STACK_MIN

extern {
	pub struct pthread_attr_t {}

	pub fn pthread_self() -> pthread_t
	pub fn pthread_getname_np(thread pthread_t, buf *mut u8, len usize) -> i32

	pub fn pthread_create(thread *mut pthread_t, attr *pthread_attr_t, start_routine fn (arg *mut void) -> *void, arg *mut void) -> i32
	pub fn pthread_join(thread pthread_t, retval **void) -> i32
	pub fn pthread_detach(thread pthread_t) -> i32
	pub fn pthread_kill(thread pthread_t, sig i32) -> i32
	pub fn pthread_cancel(thread pthread_t) -> i32

	pub const (
		PTHREAD_STACK_MIN = 0
	)

	pub fn pthread_attr_init(attr *mut pthread_attr_t) -> i32
	pub fn pthread_attr_destroy(attr *mut pthread_attr_t) -> i32
	pub fn pthread_attr_setstacksize(attr *mut pthread_attr_t, stack_size usize) -> i32

	pub const (
		EINVAL    = 0
		ETIMEDOUT = 0
		EAGAIN    = 0
		EPERM     = 0

		PTHREAD_PROCESS_SHARED  = 0
		PTHREAD_PROCESS_PRIVATE = 0

		PTHREAD_RWLOCK_PREFER_WRITER_NONRECURSIVE_NP = 0
	)

	pub struct pthread_cond_t {}
	pub struct pthread_condattr_t {}

	pub fn pthread_cond_init(c *pthread_cond_t, attr *pthread_condattr_t) -> i32
	pub fn pthread_cond_wait(c *pthread_cond_t, m *pthread_mutex_t) -> i32
	pub fn pthread_cond_timedwait(c *pthread_cond_t, m *pthread_mutex_t, abstime *timespec) -> i32
	pub fn pthread_cond_signal(c *pthread_cond_t) -> i32
	pub fn pthread_cond_broadcast(c *pthread_cond_t) -> i32
	pub fn pthread_cond_destroy(c *pthread_cond_t) -> i32

	pub fn pthread_condattr_init(attr *mut pthread_condattr_t) -> i32
	pub fn pthread_condattr_setpshared(attr *mut pthread_condattr_t, val i32) -> i32
	pub fn pthread_condattr_destroy(attr *pthread_condattr_t) -> i32

	pub struct pthread_mutex_t {}
	pub struct pthread_mutexattr_t {}

	pub fn pthread_mutex_init(m *mut pthread_mutex_t, attr *pthread_mutexattr_t) -> i32
	pub fn pthread_mutex_lock(m *pthread_mutex_t) -> i32
	pub fn pthread_mutex_unlock(m *pthread_mutex_t) -> i32
	pub fn pthread_mutex_destroy(m *pthread_mutex_t) -> i32

	pub struct pthread_rwlockattr_t {}

	pub fn pthread_rwlockattr_init(attr *mut pthread_rwlockattr_t) -> i32
	pub fn pthread_rwlockattr_setkind_np(attr *pthread_rwlockattr_t, val i32) -> i32
	pub fn pthread_rwlockattr_setpshared(attr *pthread_rwlockattr_t, pshared i32) -> i32
	pub fn pthread_rwlockattr_destroy(attr *pthread_rwlockattr_t) -> i32

	pub struct pthread_rwlock_t {}

	pub fn pthread_rwlock_init(l *mut pthread_rwlock_t, attrs *pthread_rwlockattr_t) -> i32
	pub fn pthread_rwlock_rdlock(l *pthread_rwlock_t) -> i32
	pub fn pthread_rwlock_wrlock(l *pthread_rwlock_t) -> i32
	pub fn pthread_rwlock_tryrdlock(l *pthread_rwlock_t) -> i32
	pub fn pthread_rwlock_trywrlock(l *pthread_rwlock_t) -> i32
	pub fn pthread_rwlock_unlock(l *pthread_rwlock_t) -> i32
	pub fn pthread_rwlock_destroy(l *pthread_rwlock_t) -> i32
}
