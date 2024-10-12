module winapi

#[include("<synchapi.h>")]

extern {
	pub const (
		ERROR_TIMEOUT = 0
	)

	pub const INFINITE = 0

	pub struct CONDITION_VARIABLE {}

	pub fn InitializeConditionVariable(v *CONDITION_VARIABLE)
	pub fn WakeConditionVariable(v *CONDITION_VARIABLE)
	pub fn WakeAllConditionVariable(v *CONDITION_VARIABLE)
	pub fn SleepConditionVariableSRW(v *CONDITION_VARIABLE, SRWLock *SRWLOCK, dwMilliseconds u32, Flags u32) -> i32

	pub struct SRWLOCK {}

	pub fn InitializeSRWLock(l *SRWLOCK)
	pub fn AcquireSRWLockExclusive(l *SRWLOCK)
	pub fn ReleaseSRWLockExclusive(l *SRWLOCK)
	pub fn AcquireSRWLockShared(l *SRWLOCK)
	pub fn ReleaseSRWLockShared(l *SRWLOCK)

	pub fn TryAcquireSRWLockShared(l *SRWLOCK) -> i32
	pub fn TryAcquireSRWLockExclusive(l *SRWLOCK) -> i32

	pub fn CreateSemaphoreA(lpSemaphoreAttributes *void, lInitialCount i32, lMaximumCount i32, lpName *u8) -> HANDLE
	pub fn ReleaseSemaphore(hSemaphore HANDLE, lReleaseCount i32, lpPreviousCount *i32) -> i32
}
