module libproc

extern {
	pub fn proc_pidpath(pid i32, buffer *void, buffersize u32) -> i32
}
