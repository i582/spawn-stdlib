module term

import fs
import env
import sys.winapi

// get_terminal_size returns the size of the terminal in characters.
pub fn get_terminal_size() -> Size {
	if fs.is_atty(1) > 0 && env.find('TERM') != 'dumb' {
		mut info := winapi.CONSOLE_SCREEN_BUFFER_INFO{}
		if winapi.GetConsoleScreenBufferInfo(winapi.GetStdHandle(winapi.STD_OUTPUT_HANDLE), &mut info) {
			return Size{
				width: (info.srWindow.Right - info.srWindow.Left + 1) as usize
				height: (info.srWindow.Bottom - info.srWindow.Top + 1) as usize
			}
		}
	}
	return Size{
		width: DEFAULT_COLUMNS_SIZE
		height: DEFAULT_ROWS_SIZE
	}
}

// clear clears the terminal screen.
pub fn clear() -> bool {
	// based on https://docs.microsoft.com/en-us/windows/console/clearing-the-screen#example-2.
	hconsole := winapi.GetStdHandle(winapi.STD_OUTPUT_HANDLE)
	mut csbi := winapi.CONSOLE_SCREEN_BUFFER_INFO{}
	mut scrollrect := winapi.SMALL_RECT{}
	mut scrolltarget := winapi.COORD{}
	mut fill := winapi.CHAR_INFO{}

	// Get the number of character cells in the current buffer.
	if !winapi.GetConsoleScreenBufferInfo(hconsole, &mut csbi) {
		return false
	}
	// Scroll the rectangle of the entire buffer.
	scrollrect.Left = 0
	scrollrect.Top = 0
	scrollrect.Right = csbi.dwSize.X as u16
	scrollrect.Bottom = csbi.dwSize.Y as u16

	// Scroll it upwards off the top of the buffer with a magnitude of the entire height.
	scrolltarget.X = 0
	scrolltarget.Y = 0 - csbi.dwSize.Y

	// Fill with empty spaces with the buffer's default text attribute.
	unsafe {
		fill.Char.UnicodeChar = ` `
	}
	fill.Attributes = csbi.wAttributes

	// Do the scroll
	winapi.ScrollConsoleScreenBuffer(hconsole, &scrollrect, nil, scrolltarget, &fill)

	// Move the cursor to the top left corner too.
	csbi.dwCursorPosition.X = 0
	csbi.dwCursorPosition.Y = 0

	winapi.SetConsoleCursorPosition(hconsole, csbi.dwCursorPosition)
	return true
}
