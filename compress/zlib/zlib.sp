module zlib

import compress.base

const (
	TDEFL_WRITE_ZLIB_HEADER      = 0x01000
	TINFL_FLAG_PARSE_ZLIB_HEADER = 0x1
)

// compress an array of bytes using zlib and returns the compressed bytes in a new array.
// Example:
// ```
// compressed := zlib.compress(b)!
// ```
pub fn compress(data []u8) -> ![]u8 {
	return base.compress(data, TDEFL_WRITE_ZLIB_HEADER)
}

// decompress an array of bytes using zlib and returns the decompressed bytes in a new array.
// Example:
// ```
// decompressed := zlib.decompress(b)!
// ```
pub fn decompress(data []u8) -> ![]u8 {
	return base.decompress(data, TINFL_FLAG_PARSE_ZLIB_HEADER)
}
