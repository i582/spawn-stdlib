module gzip

import hash.crc32
import compress.base

// compress an array of bytes using zlib and returns the compressed bytes in a new array.
// Example:
// ```
// compressed := zlib.compress(b)!
// ```
pub fn compress(data []u8) -> ![]u8 {
	mut compressed := base.compress(data, 0) or { return error(err) }

	// add gzip header
	compressed.prepend_ptr(&([
		0x1f as u8, 0x8b, // magic
		0x08, // compression method
		0x00, // flags
		0x00, 0x00, 0x00, 0x00, // mtime
		0x00, // extra flags
		0xff, // operating system (0xff = unknown)
	] as [10]u8)[0], 10)

	// add gzip footer
	checksum := crc32.sum(data)
	length := data.len
	compressed.push_fixed([
		checksum.truncate_cast_to_u8(),
		(checksum >> 8).truncate_cast_to_u8(),
		(checksum >> 16).truncate_cast_to_u8(),
		(checksum >> 24).truncate_cast_to_u8(),
		(length & 0xFF).truncate_cast_to_u8(),
		(length >> 8).truncate_cast_to_u8(),
		(length >> 16).truncate_cast_to_u8(),
		(length >> 24).truncate_cast_to_u8(),
	] as [8]u8, 8)

	return compressed
}

// decompress an array of bytes using zlib and returns the decompressed bytes in a new array.
// Example:
// ```
// decompressed := zlib.decompress(b)!
// ```
pub fn decompress(data []u8) -> ![]u8 {
	// TODO: correctly handle the gzip header and footer
	return base.decompress(data, 0x1)
}
