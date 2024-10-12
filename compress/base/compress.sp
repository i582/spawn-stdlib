module base

import mem

const MAX_BLOCK_SIZE = 1 as u64 << 32

pub fn compress(data []u8, flags i32) -> ![]u8 {
	if data.len > MAX_BLOCK_SIZE {
		return msg_err("data too large, ${data.len} > ${MAX_BLOCK_SIZE}")
	}

	mut compressed_len := 0 as usize

	compressed := tdefl_compress_mem_to_heap(data.raw(), data.len, &mut compressed_len, flags)
	if compressed == nil {
		return msg_err("failed to compress data")
	}

	if compressed_len > MAX_BLOCK_SIZE {
		return msg_err("compressed data too large, ${compressed_len} > ${MAX_BLOCK_SIZE}")
	}

	our_compressed := Array.from_ptr[u8](unsafe { compressed as *u8 }, compressed_len)

	// we should free the compressed data since `tdefl_compress_mem_to_heap` allocates it
	// with plain `malloc`, so GC doesn't know about it.
	mem.c_free(compressed)

	return our_compressed
}

pub fn decompress(data []u8, flags i32) -> ![]u8 {
	if data.len > MAX_BLOCK_SIZE {
		return msg_err("data too large, ${data.len} > ${MAX_BLOCK_SIZE}")
	}

	mut decompressed_len := 0 as usize

	decompressed := tinfl_decompress_mem_to_heap(data.raw(), data.len, &mut decompressed_len, flags)
	if decompressed == nil {
		return msg_err("failed to decompress data")
	}

	if decompressed_len > MAX_BLOCK_SIZE {
		return msg_err("decompressed data too large, ${decompressed_len} > ${MAX_BLOCK_SIZE}")
	}

	our_decompressed := Array.from_ptr[u8](unsafe { decompressed as *u8 }, decompressed_len)

	// we should free the decompressed data since `tinfl_decompress_mem_to_heap` allocates it
	// with plain `malloc`, so GC doesn't know about it.
	mem.c_free(decompressed)

	return our_decompressed
}
