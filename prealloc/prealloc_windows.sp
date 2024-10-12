module prealloc

pub fn init() {}

pub fn alloc(size usize) -> &mut u8 {
	todo('not implemented yet')
}

pub fn calloc(size usize, count usize) -> &mut u8 {
	todo('not implemented yet')
}

pub fn realloc(ptr &u8, ptr_size usize, new_size usize) -> &mut u8 {
	todo('not implemented yet')
}

pub fn stats() {}

pub fn cleanup() {}
