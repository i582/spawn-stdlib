module rand

import mem
import errno
import sys.linux.syscall

const MAX_READ_BATCH_SIZE = 256

// read returns an array with `count` random bytes.
pub fn read(count i32) -> ![[]u8, ReadError] {
	mut buffer := mem.alloc(count) as *mut u8
	mut read_bytes := 0
	for read_bytes < count {
		mut batch_size := count - read_bytes
		if batch_size > MAX_READ_BATCH_SIZE {
			batch_size = MAX_READ_BATCH_SIZE
		}

		n := unsafe { get_random_syscall(batch_size, buffer + read_bytes) }
		if n == -1 {
			msg := errno.last().desc()
			return error(ReadError{ msg: msg })
		}
		read_bytes += n
	}
	return unsafe { Array.from_ptr_no_copy[u8](buffer, count) }
}

fn get_random_syscall(count i32, buffer *mut void) -> i32 {
	return syscall.syscall(syscall.SYS_getrandom, buffer, count as *void, 0 as *void)
}
