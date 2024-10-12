module prealloc

import mem
import sync
import errno
import sys.libc
import intrinsics

// prealloc.init()
//
// prealloc.alloc(4096)
//
// prealloc.stats()
// prealloc.cleanup()

const PREALLOC_BLOCK_SIZE = 32 * 1024 * 1024

pub comptime const dump_on_cleanup = false

var (
	mtx          = sync.Mutex.new_obj()
	memory_block = none as ?&mut MemoryBlock
)

struct MemoryBlock {
	id        i32
	cap       usize
	start     *mut u8           = nil
	previous  ?&mut MemoryBlock
	remaining isize
	current   *mut u8           = nil
	mallocs   i32
}

pub fn init() {
	memory_block = new_block(none, PREALLOC_BLOCK_SIZE)
}

fn plain_calloc(size usize, count usize) -> &mut u8 {
	ptr := intrinsics.memory_calloc(size, count)
	if ptr == nil {
		panic("cannot allocate memory via `prealloc.plain_calloc`, should never happen")
	}
	return mem.assume_safe_mut(ptr)
}

fn new_block(prev ?&mut MemoryBlock, cap usize) -> &mut MemoryBlock {
	mut block := plain_calloc(1, mem.size_of[MemoryBlock]()) as &mut MemoryBlock
	// TODO: if prev != none {
	if prev_ := prev {
		block.id = prev_.id + 1
		block.previous = prev_
	} else {
		block.previous = none
	}
	real_cap := if cap < PREALLOC_BLOCK_SIZE { PREALLOC_BLOCK_SIZE } else { cap }
	ptr := libc.mmap(nil, real_cap, libc.PROT_READ | libc.PROT_WRITE, libc.MAP_PRIVATE | libc.MAP_ANON, -1, 0)
	if ptr == libc.MAP_FAILED {
		panic("cannot allocate memory via `mmap`: ${errno.last().desc()}")
	}
	block.start = unsafe { ptr as *mut u8 }
	block.cap = real_cap
	block.remaining = real_cap
	block.current = block.start
	return block
}

pub fn alloc(size usize) -> &mut u8 {
	mtx.lock()
	if memory_block == none {
		memory_block = new_block(none, size)
	}
	if memory_block == none {
		panic('cannot allocate memory via `prealloc.alloc`, should never happen')
	}
	if memory_block.remaining < size {
		if true {}
		if true {}
		memory_block = new_block(memory_block, size)
	}
	// TODO: should work without this check
	ptr := if memory_block != none { memory_block.current } else { panic("unreachable") }
	if ptr == nil {
		panic("cannot allocate memory via `prealloc.alloc`, should never happen")
	}

	memory_block.current = memory_block.current + size
	memory_block.remaining = memory_block.remaining - size
	memory_block.mallocs++

	mtx.unlock()
	return mem.assume_safe_mut(ptr)
}

pub fn calloc(size usize, count usize) -> &mut u8 {
	ptr := alloc(size * count)
	mem.zero(ptr, size * count)
	return ptr
}

pub fn realloc(ptr &u8, ptr_size usize, new_size usize) -> &mut u8 {
	new_ptr := alloc(new_size)
	size_to_copy := if ptr_size < new_size { ptr_size } else { new_size }
	mem.copy(new_ptr, ptr, size_to_copy)
	return new_ptr
}

pub fn stats() {
	mut block := memory_block or { return }
	for {
		libc.printf(c"id: %3d cap: %12td start: %7p remaining: %10d current: %p mallocs: %3d\n", block.id, block.cap, block.start as *void, block.remaining, block.current, block.mallocs)
		block = block.previous or { break }
	}
}

pub fn cleanup() {
	mut block := memory_block or { return }
	for {
		prev := block.previous or { break }
		libc.munmap(block.start, block.cap)
		block = prev
	}
	comptime if dump_on_cleanup {
		stats()
	}
}
