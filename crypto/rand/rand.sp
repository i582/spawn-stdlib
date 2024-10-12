module rand

// bytes returns an array with `count` random bytes.
pub fn bytes(count i32) -> ![[]u8, ReadError] {
	return read(count)
}
