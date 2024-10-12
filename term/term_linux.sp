module term

import fs
import env
import sys.libc

// get_terminal_size returns the size of the terminal in characters.
pub fn get_terminal_size() -> Size {
	if fs.is_atty(1) < 0 || env.find('TERM') == 'dumb' {
		return Size{
			width: DEFAULT_COLUMNS_SIZE
			height: DEFAULT_ROWS_SIZE
		}
	}

	mut w := libc.winsize{}
	libc.ioctl(1, libc.TIOCGWINSZ, &mut w)
	return Size{
		width: w.ws_col as usize
		height: w.ws_row as usize
	}
}
