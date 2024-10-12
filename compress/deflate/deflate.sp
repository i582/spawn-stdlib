module deflate

import compress.base

// compress an array of bytes using deflate and returns the compressed bytes in a new array.
// Example:
// ```
// compressed := deflate.compress(b)!
// ```
pub fn compress(data []u8) -> ![]u8 {
	return base.compress(data, 0)
}

// decompress an array of bytes using deflate and returns the decompressed bytes in a new array.
// Example:
// ```
// decompressed := deflate.decompress(b)!
// ```
pub fn decompress(data []u8) -> ![]u8 {
	return base.decompress(data, 0)
}
