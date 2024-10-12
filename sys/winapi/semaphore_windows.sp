module winapi

import sys.libc
import time
import mem

// This implementation based on https://github.com/DanielTillett/Simple-Windows-Posix-Semaphore

pub const (
	PTHREAD_PROCESS_SHARED  = 1
	PTHREAD_PROCESS_PRIVATE = 2
)

pub struct Sem {
	inner &mut ArchSem
}

struct ArchSem {
	handle HANDLE
}

pub fn sem_init(sem &mut Sem, pshared i32, value u32) -> ! {
	mut buf := [24]u8{}
	pv := mem.to_heap_mut(&mut ArchSem{})
	if value > MAX_I32 as u32 {
		return error('sem_init error: value is too large')
	}

	if pshared != PTHREAD_PROCESS_SHARED {
		libc.sprintf(buf.mut_raw(), c"Global\\%p", pv)
	}

	pv.handle = CreateSemaphoreA(nil, value, MAX_I32, buf.mut_raw())
	if pv.handle == nil {
		err := GetLastError()
		return error('sem_init error: CreateSemaphoreA failed: error: ${err}')
	}

	sem.inner = pv
}

pub fn sem_wait(sem &Sem) -> i32 {
	if WaitForSingleObject(sem.inner.handle, INFINITE) != WAIT_OBJECT_0 {
		return set_errno(EINVAL)
	}

	return 0
}

pub fn sem_trywait(sem &Sem) -> i32 {
	mut rc := WaitForSingleObject(sem.inner.handle, 0)
	if rc == WAIT_OBJECT_0 {
		return 0
	}

	if rc == WAIT_TIMEOUT {
		return set_errno(EAGAIN)
	}

	return set_errno(EINVAL)
}

pub fn sem_timedwait(sem &Sem, dur time.Duration) -> i32 {
	rc := WaitForSingleObject(sem.inner.handle, dur.as_millis() as u32)
	if rc == WAIT_OBJECT_0 {
		return 0
	}

	if rc == WAIT_TIMEOUT {
		return set_errno(ETIMEDOUT)
	}

	return set_errno(EINVAL)
}

pub fn sem_post(sem &Sem) -> i32 {
	if ReleaseSemaphore(sem.inner.handle, 1, nil) == 0 {
		return set_errno(EINVAL)
	}

	return 0
}

pub fn sem_getvalue(sem &Sem, value &mut i32) -> i32 {
	mut previous := 0
	match WaitForSingleObject(sem.inner.handle, 0) {
		WAIT_OBJECT_0 => {
			if ReleaseSemaphore(sem.inner.handle, 1, &mut previous) == 0 {
				return set_errno(EINVAL)
			}

			*value = previous + 1
		}
		WAIT_TIMEOUT => {
			*value = 0
		}
		else => return set_errno(EINVAL)
	}

	return 0
}

pub fn sem_destroy(sem &Sem) -> i32 {
	if CloseHandle(sem.inner.handle) == 0 {
		return set_errno(EINVAL)
	}
	return 0
}

fn set_errno(result i32) -> i32 {
	if result != 0 {
		C.errno = result
		return -1
	}

	return 0
}
