module term

import fs
import env

// clear clears the terminal screen.
pub fn clear() -> bool {
	if fs.is_atty(1) <= 0 || env.find('TERM') == 'dumb' {
		return false
	}
	print('\x1b[2J')
	print('\x1b[H')
	fs.flush_stdout()
	return true
}
