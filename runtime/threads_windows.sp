module runtime

import sys.winapi

struct RawThread {
	handle winapi.HANDLE
}

fn RawThread.create[T](stack_size usize, data *mut T, start fn (_ *mut T) -> *mut void) -> ![RawThread, ThreadCreationError] {
	handle := winapi.CreateThread(nil, stack_size as u32, start as *void, data, 0, nil)
	if handle == nil {
		err := winapi.last_error().expect('handle is nil, but no error is set')
		return error(ThreadCreationError.new('unable to create thread, ${err.with_context("CreateThread failed").msg()}'))
	}

	return RawThread{ handle: handle }
}

fn (t RawThread) join() -> ![unit, JoinThreadError] {
	res := winapi.WaitForSingleObject(t.handle, winapi.INFINITE)
	if res != winapi.WAIT_OBJECT_0 {
		return error(JoinThreadError{ msg: 'unable to join thread,`WaitForSingleObject` failed: code ${res}' })
	}
}

fn (t RawThread) detach() -> ![unit, DetachThreadError] {
	res := winapi.CloseHandle(t.handle)
	if res == 0 {
		if err := winapi.last_error() {
			return error(DetachThreadError{ msg: 'unable to detach thread, ${err.with_context("CloseHandle failed").msg()}' })
		}
	}
}

fn (t RawThread) cancel() {
	winapi.TerminateThread(t.handle, 0)
}

fn (t RawThread) id() -> usize {
	return 0 // TODO: t.handle as usize
}
