module os

import env
import mem
import fs
import sys.libc
import term.termios

// readln reads a line from stdin and returns it as is, with the newline.
pub fn readln() -> string {
	mut max := 0 as usize
	mut buf := nil as *mut u8
	nr_chars := libc.getline(&mut buf, &mut max, C.stdin)

	if nr_chars > 0 {
		ret := string.view_from_c_str_len(buf, nr_chars).clone()

		if buf != nil {
			// from doc:
			// If linep points to a NULL pointer, a new buffer will be allocated
			// so we need to free it to avoid memory leak
			unsafe { mem.c_free(buf) }
		}

		return ret
	}

	return ""
}

// readln_hidden reads a line from stdin without echoing the input.
// This is useful for password-like prompts.
pub fn readln_hidden() -> !string {
	if fs.is_atty(1) <= 0 || env.find('TERM') == 'dumb' {
		return error('Password prompt not supported in this environment')
	}

	old_termios := termios.Termios.for_fd(fd: libc.STDIN_FILENO)

	mut new_termios := old_termios
	new_termios.disable_echo()
	new_termios.apply_to(libc.STDIN_FILENO, libc.TCSANOW)

	password := readln()

	old_termios.apply_to(libc.STDIN_FILENO, libc.TCSANOW)

	return password
}
