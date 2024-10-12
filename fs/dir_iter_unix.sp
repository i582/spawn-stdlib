module fs

import sys.libc
import intrinsics

type DirHandle = *libc.DIR

// new creates a new iterator instance.
//
// See [`read_dir_iter`].
pub fn DirIterator.new(path string) -> !DirIterator {
	dir := libc.opendir(path.c_str())
	if dir == nil {
		return error('could not open directory "${path}"')
	}
	return DirIterator{ path: path, handle: dir }
}

// close closes the internal handle.
//
// Subsequent calls on an already closed iterator are safe.
pub fn (it &mut DirIterator) close() {
	if it.handle == nil {
		return
	}
	libc.closedir(it.handle)
	it.handle = nil
}

fn (it &mut DirIterator) next_impl() -> ?string {
	if intrinsics.unlikely(it.handle == nil) {
		panic('using iterator after closing')
	}

	for {
		ent := libc.readdir(it.handle)
		if ent == nil {
			break
		}

		name := string.from_c_str(unsafe { &(*ent).d_name[0] as *u8 })
		if name in ['', '.', '..'] {
			continue
		}
		return name
	}

	it.close()
	return none
}
