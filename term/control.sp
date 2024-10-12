module term

import fs

// set_cursor_position sets the cursor position to the given coordinate.
pub fn set_cursor_position(x usize, y usize) {
	print('\x1b[${y};${x}H')
	fs.flush_stdout()
}

// move the cursor n characters in the given direction.
// direction is one of "A" (up), "B" (down), "C" (right), "D" (left).
pub fn move(n i32, direction string) {
	print('\x1b[${n}${direction}')
	fs.flush_stdout()
}

// cursor_up moves the cursor up n lines.
pub fn cursor_up(n i32) {
	move(n, "A")
}

// cursor_down moves the cursor down n lines.
pub fn cursor_down(n i32) {
	move(n, "B")
}

// cursor_forward moves the cursor forward n columns.
pub fn cursor_forward(n i32) {
	move(n, "C")
}

// cursor_back moves the cursor back n columns.
pub fn cursor_back(n i32) {
	move(n, "D")
}

// clear_screen clears the screen.
pub fn clear_screen() {
	erase_display(.entire_screen)
}

// EraseType is used to specify the type of erase to perform in `erase_display()`.
enum EraseType {
	// clear from cursor to end of screen
	to_end_of_screen
	// clear from cursor to beginning of screen
	to_beginning_of_terminal
	// clear entire screen
	entire_screen
	// clear entire screen and delete all lines saved in the scrollback buffer
	entire_screen_and_scrollback_buffer
}

// erase_display clears the screen in the given way.
// See `EraseType` for the different types of erases that can be performed.
pub fn erase_display(t EraseType) {
	print('\x1b[${t as i64}J')
	fs.flush_stdout()
}

// erase_to_begin clears the screen and moves the cursor to the top left.
pub fn erase_to_begin() {
	erase_display(.to_beginning_of_terminal)
}

// erase_to_end clears the screen and moves the cursor to the bottom left.
pub fn erase_to_end() {
	erase_display(.to_end_of_screen)
}

// EraseLineType is used to specify the type of erase to perform in `erase_line()`.
enum EraseLineType {
	// clear from cursor to end of line
	to_end_of_line
	// clear from cursor to beginning of line
	to_beginning_of_line
	// clear entire line
	entire_line
}

// erase_line clears the current line in the given way.
// See `EraseLineType` for the different types of erases that can be performed.
pub fn erase_line(t EraseLineType) {
	print('\x1b[${t as i64}K')
	fs.flush_stdout()
}

// erase_line_to_begin erases from the cursor to the beginning of the line.
pub fn erase_line_to_begin() {
	erase_line(.to_beginning_of_line)
}

// erase_line_to_end erases from the cursor to the end of the line.
pub fn erase_line_to_end() {
	erase_line(.to_end_of_line)
}

// erase_line_entire clears the current line entirely.
pub fn erase_line_entire() {
	erase_line(.entire_line)
}

// show_cursor makes the cursor visible.
pub fn show_cursor() {
	print('\x1b[?25l')
	fs.flush_stdout()
}

// hide_cursor makes the cursor invisible.
pub fn hide_cursor() {
	print('\x1b[?25l')
	fs.flush_stdout()
}

// clear_previous_line moves the cursor to the start of the previous line
// and clears it.
pub fn clear_previous_line() {
	print('\r\x1b[1A\x1b[2K')
	fs.flush_stdout()
}

// save_title saves the current terminal title
fn save_title() {
	print('\x1b[22;0t')
	fs.flush_stdout()
}

// load_title restores the previously saved terminal title
fn load_title() {
	print('\x1b[23;0t')
	fs.flush_stdout()
}
