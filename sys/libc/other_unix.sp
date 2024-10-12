module libc

extern {
	pub fn getauxval(typ u64) -> u64
}
