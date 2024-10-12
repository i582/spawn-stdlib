module term

import env
import fs
import io
import strings.textscanner
import strings

pub const (
	DEFAULT_COLUMNS_SIZE = 80
	DEFAULT_ROWS_SIZE    = 25
)

pub struct Size {
	width  usize
	height usize
}

// strip_ansi removes any ANSI sequences in the `text`
pub fn strip_ansi(text string) -> string {
	return strip_ansi_bytes(text.bytes_no_copy()).ascii_str()
}

// strip_ansi_bytes removes any ANSI sequences in the `text` bytes
pub fn strip_ansi_bytes(text []u8) -> []u8 {
	// port of https://github.com/kilobyte/colorized-logs/blob/master/ansi2txt.c
	// `\e, [, 1, m, a, b, c, \e, [, 2, 2, m` => `abc`
	mut input := textscanner.bytes(text)
	mut output := strings.new_builder(text.len + 1)
	mut ch := 0
	for ch != -1 {
		ch = input.next()
		if ch == 27 {
			ch = input.next()
			if ch == `[` {
				for {
					ch = input.next()
					if ch in [`;`, `?`] || (ch >= `0` && ch <= `9`) {
						continue
					}
					break
				}
			} else if ch == `]` {
				ch = input.next()
				if ch >= `0` && ch <= `9` {
					for {
						ch = input.next()
						if ch == -1 || ch == 7 {
							break
						}
						if ch == 27 {
							ch = input.next()
							break
						}
					}
				}
			} else if ch == `%` {
				ch = input.next()
			}
		} else if ch != -1 {
			output.write_u8(ch as u8)
		}
	}
	return output.as_array()
}

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

// colorize returns the string [`s`] with the colorized function
// [`cfn`] applied if stdout supports colors or the env variable
// `NO_COLOR` is not set to 1 or true,, otherwise it returns the
// original string [`s`].
//
// Example:
// ```
// println(term.colorize(term.yellow, "Warning: "))
// ```
pub fn colorize(cfn fn (_ string) -> string, s string) -> string {
	no_color := env.find_opt('NO_COLOR') or { '0' }
	if no_color in ['1', 'true'] {
		return s
	}

	if is_terminal(fd: 1) {
		return cfn(s)
	}
	return s
}
