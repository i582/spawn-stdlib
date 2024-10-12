module os

import fs
import mem
import sys.winapi

// readln reads a line from stdin and returns it as is, with the newline.
pub fn readln() -> string {
	max_line_chars := 256
	buf := mem.alloc(max_line_chars * 2) as &u16
	input_handle := winapi.GetStdHandle(winapi.STD_INPUT_HANDLE)
	mut read_bytes := 0 as usize
	if fs.is_atty(1) > 0 {
		res := winapi.ReadConsole(input_handle, buf, max_line_chars * 2, &mut read_bytes, nil)
		if !res {
			return ''
		}
		return string.from_wide_with_len(buf, read_bytes)
	}
	// TODO: process files?
	return ''
}

// readln_hidden reads a line from stdin without echoing the input.
// This is useful for password-like prompts.
pub fn readln_hidden() -> !string {
	std_handle := winapi.GetStdHandle(winapi.STD_INPUT_HANDLE)

	mut mode := 0 as u32
	winapi.GetConsoleMode(std_handle, &mut mode)
	winapi.SetConsoleMode(std_handle, mode & ~winapi.ENABLE_ECHO_INPUT)

	line := readln()

	winapi.SetConsoleMode(std_handle, mode)

	return line
}
