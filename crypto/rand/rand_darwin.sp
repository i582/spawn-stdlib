module rand

import sys.darwin.random

// read returns an array with `count` random bytes.
pub fn read(count i32) -> ![[]u8, ReadError] {
	mut buffer := []u8{len: count}
	status := random.SecRandomCopyBytes(nil, count, buffer.data)
	if status != random.errSecSuccess {
		return error(ReadError{})
	}
	return buffer
}
