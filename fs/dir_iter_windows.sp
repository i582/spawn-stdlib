module fs

import sys.winapi

type DirHandle = winapi.HANDLE

// new creates a new iterator instance.
//
// See [`read_dir_iter`].
pub fn DirIterator.new(path string) -> !DirIterator {
	path_files := '${path}\\*'.to_wide()
	mut find_data := winapi.WIN32_FIND_DATA{}
	handle := winapi.FindFirstFileW(path_files, &mut find_data)
	if handle == winapi.INVALID_HANDLE_VALUE {
		err := winapi.last_error().expect("no last error when returning INVALID_HANDLE_VALUE")
		return error(err.with_context('could not open directory "${path}"'))
	}
	first_file := string.from_wide(unsafe { &find_data.cFileName[0] })
	return DirIterator{ path: path, handle: handle, first_file: if first_file == '.' { '' } else { first_file } }
}

// close closes the internal handle.
//
// Subsequent calls on an already closed iterator are safe.
pub fn (it &mut DirIterator) close() {
	if it.handle == nil {
		return
	}
	winapi.FindClose(it.handle)
	it.handle = nil
}

fn (it &mut DirIterator) next_impl() -> ?string {
	if it.first_file.len > 0 {
		file := it.first_file
		it.first_file = ''
		return file
	}

	mut find_data := winapi.WIN32_FIND_DATA{}
	for winapi.FindNextFileW(it.handle, &mut find_data) > 0 {
		name := string.from_wide(unsafe { &find_data.cFileName[0] })
		if name in ['', '.', '..'] {
			continue
		}
		return name
	}

	it.close()
	return none
}
