module base

#[include_path("$SPAWN_ROOT/thirdparty/zip")]
#[include("miniz.h")]
#[cflags_if(darwin && arm64, "$SPAWN_ROOT/thirdparty/zip/miniz.o")]
#[cflags_if(!(darwin && arm64), "$SPAWN_ROOT/thirdparty/zip/miniz.c")]

extern {
	fn tdefl_compress_mem_to_heap(source_buf *void, source_buf_len usize, out_len *mut usize, flags i32) -> *mut void
	fn tinfl_decompress_mem_to_heap(source_buf *void, source_buf_len usize, out_len *mut usize, flags i32) -> *mut void
}
