module log

import io
import fs
import env

pub fn check_if_terminal(w io.Writer) -> bool {
	if w is fs.File {
		return is_terminal(w.fno)
	}
	return false
}

pub fn is_terminal(fd i32) -> bool {
	comptime if windows {
		env_conemu := env.find('ConEmuANSI')
		if env_conemu == 'ON' {
			return true
		}
		// 4 is enable_virtual_terminal_processing
		return (fs.is_atty(fd) & 0x0004) > 0
	}

	return fs.is_atty(fd) > 0
}
