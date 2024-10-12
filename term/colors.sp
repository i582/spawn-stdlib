module term

// format returns the given `msg` with open and close ANSI escape codes.
pub fn format(msg string, open string, close string) -> string {
	return '\x1b[${open}m${msg}\x1b[${close}m'
}

// format_rgb returns the given `msg` with the given rgb color.
pub fn format_rgb(r i32, g i32, b i32, msg string, open string, close string) -> string {
	return '\x1b[${open};2;${r};${g};${b}m${msg}\x1b[${close}m'
}

// rgb returns the given `msg` with the given rgb color.
pub fn rgb(r i32, g i32, b i32, msg string) -> string {
	return format_rgb(r, g, b, msg, '38', '39')
}

// bg_rgb returns the given `msg` with the given rgb color as background.
pub fn bg_rgb(r i32, g i32, b i32, msg string) -> string {
	return format_rgb(r, g, b, msg, '48', '49')
}

// hex returns the given `msg` with the given hex color.
pub fn hex(hx i32, msg string) -> string {
	return format_rgb(hx >> 16, hx >> 8 & 0xff, hx & 0xff, msg, '38', '39')
}

// bg_hex returns the given `msg` with the given hex color as background.
pub fn bg_hex(hx i32, msg string) -> string {
	return format_rgb(hx >> 16, hx >> 8 & 0xff, hx & 0xff, msg, '48', '49')
}

// reset resets all formatting for `msg`.
pub fn reset(msg string) -> string {
	return format(msg, '0', '0')
}

// bold returns the given `msg` in bold.
pub fn bold(msg string) -> string {
	return format(msg, '1', '22')
}

// dim returns the dimmed `msg`.
pub fn dim(msg string) -> string {
	return format(msg, '2', '22')
}

// italic returns the given `msg` in italic.
pub fn italic(msg string) -> string {
	return format(msg, '3', '23')
}

// underline returns the underlined `msg`.
pub fn underline(msg string) -> string {
	return format(msg, '4', '24')
}

// slow_blink will surround the `msg` with ANSI escape codes for blinking (less than 150 times per minute).
pub fn slow_blink(msg string) -> string {
	return format(msg, '5', '25')
}

// rapid_blink will surround the `msg` with ANSI escape codes for blinking (over 150 times per minute).
// Note that unlike slow_blink, this is not very widely supported.
pub fn rapid_blink(msg string) -> string {
	return format(msg, '6', '26')
}

// inverse inverses the given `msg`.
pub fn inverse(msg string) -> string {
	return format(msg, '7', '27')
}

// hidden hides the given `msg`.
pub fn hidden(msg string) -> string {
	return format(msg, '8', '28')
}

// strikethrough returns the given `msg` in strikethrough.
pub fn strikethrough(msg string) -> string {
	return format(msg, '9', '29')
}

// black formats the `msg` in black.
pub fn black(msg string) -> string {
	return format(msg, '30', '39')
}

// red formats the `msg` in red.
pub fn red(msg string) -> string {
	return format(msg, '31', '39')
}

// green formats the `msg` in green.
pub fn green(msg string) -> string {
	return format(msg, '32', '39')
}

// yellow formats the `msg` in yellow.
pub fn yellow(msg string) -> string {
	return format(msg, '33', '39')
}

// blue formats the `msg` in blue.
pub fn blue(msg string) -> string {
	return format(msg, '34', '39')
}

// magenta formats the `msg` in magenta.
pub fn magenta(msg string) -> string {
	return format(msg, '35', '39')
}

// cyan formats the `msg` in cyan.
pub fn cyan(msg string) -> string {
	return format(msg, '36', '39')
}

// white formats the `msg` in white.
pub fn white(msg string) -> string {
	return format(msg, '37', '39')
}

// bg_black formats the `msg` in black background.
pub fn bg_black(msg string) -> string {
	return format(msg, '40', '49')
}

// bg_red formats the `msg` in red background.
pub fn bg_red(msg string) -> string {
	return format(msg, '41', '49')
}

// bg_green formats the `msg` in green background.
pub fn bg_green(msg string) -> string {
	return format(msg, '42', '49')
}

// bg_yellow formats the `msg` in yellow background.
pub fn bg_yellow(msg string) -> string {
	return format(msg, '43', '49')
}

// bg_blue formats the `msg` in blue background.
pub fn bg_blue(msg string) -> string {
	return format(msg, '44', '49')
}

// bg_magenta formats the `msg` in magenta background.
pub fn bg_magenta(msg string) -> string {
	return format(msg, '45', '49')
}

// bg_cyan formats the `msg` in cyan background.
pub fn bg_cyan(msg string) -> string {
	return format(msg, '46', '49')
}

// bg_white formats the `msg` in white background.
pub fn bg_white(msg string) -> string {
	return format(msg, '47', '49')
}

// gray formats the `msg` in gray (equivalent to `bright_black`).
pub fn gray(msg string) -> string {
	return bright_black(msg)
}

// bright_black formats the `msg` in bright black.
pub fn bright_black(msg string) -> string {
	return format(msg, '90', '39')
}

// bright_red formats the `msg` in bright red.
pub fn bright_red(msg string) -> string {
	return format(msg, '91', '39')
}

// bright_green formats the `msg` in bright green.
pub fn bright_green(msg string) -> string {
	return format(msg, '92', '39')
}

// bright_yellow formats the `msg` in bright yellow.
pub fn bright_yellow(msg string) -> string {
	return format(msg, '93', '39')
}

// bright_blue formats the `msg` in bright blue.
pub fn bright_blue(msg string) -> string {
	return format(msg, '94', '39')
}

// bright_magenta formats the `msg` in bright magenta.
pub fn bright_magenta(msg string) -> string {
	return format(msg, '95', '39')
}

// bright_cyan formats the `msg` in bright cyan.
pub fn bright_cyan(msg string) -> string {
	return format(msg, '96', '39')
}

// bright_white formats the `msg` in bright white.
pub fn bright_white(msg string) -> string {
	return format(msg, '97', '39')
}

// bright_bg_black formats the `msg` in bright black background.
pub fn bright_bg_black(msg string) -> string {
	return format(msg, '100', '49')
}

// bright_bg_red formats the `msg` in bright red background.
pub fn bright_bg_red(msg string) -> string {
	return format(msg, '101', '49')
}

// bright_bg_green formats the `msg` in bright green background.
pub fn bright_bg_green(msg string) -> string {
	return format(msg, '102', '49')
}

// bright_bg_yellow formats the `msg` in bright yellow background.
pub fn bright_bg_yellow(msg string) -> string {
	return format(msg, '103', '49')
}

// bright_bg_blue formats the `msg` in bright blue background.
pub fn bright_bg_blue(msg string) -> string {
	return format(msg, '104', '49')
}

// bright_bg_magenta formats the `msg` in bright magenta background.
pub fn bright_bg_magenta(msg string) -> string {
	return format(msg, '105', '49')
}

// bright_bg_cyan formats the `msg` in bright cyan background.
pub fn bright_bg_cyan(msg string) -> string {
	return format(msg, '106', '49')
}

// bright_bg_white formats the `msg` in bright white background.
pub fn bright_bg_white(msg string) -> string {
	return format(msg, '107', '49')
}
