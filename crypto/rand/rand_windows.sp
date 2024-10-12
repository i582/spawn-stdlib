module rand

import sys.windows.bcrypt

// read returns an array with `count` random bytes.
pub fn read(count i32) -> ![[]u8, ReadError] {
	mut buffer := []u8{len: count}
	// When we use BCRYPT_USE_SYSTEM_PREFERRED_RNG the hAlgorithm parameter must be NULL.
	status := bcrypt.BCryptGenRandom(0, buffer.data, count, bcrypt.BCRYPT_USE_SYSTEM_PREFERRED_RNG)
	if status != 0 {
		return error(ReadError{})
	}
	return buffer
}
