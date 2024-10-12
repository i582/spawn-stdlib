module unicode

// This file based on https://github.com/mattn/go-runewidth. Thank you!

// rune_width returns the width of the given rune, taking into account whether
// the context is East Asian or not. In East Asian contexts, some characters
// may have different widths compared to default context.
//
// Note: The width of a rune is the number of cells in [`r`], see http://www.unicode.org/reports/tr11/
//
// Example:
// ```
// assert unicode.rune_width(`a`, false) == 1
// assert unicode.rune_width(`好`, true) == 2
// ```
//
// See also [`Width`] and [`Width.rune_width`] for a more flexible way
// to get the width.
pub fn rune_width(r rune, east_asian bool) -> usize {
	if east_asian {
		return east_asian_condition.rune_width(r)
	}

	return default_condition.rune_width(r)
}

// string_width calculates the total width of the given string based on the
// width of each rune, in the provided [`Width`] context.
//
// The return value can be thought of as the actual width in ASCII characters,
// so "你好" will have a length of 4, which means that on the screen its width
// will be same as for word "Some" with a length of 4.
//
// Example:
// ```
// assert unicode.string_width("hello") == 5
// assert unicode.string_width("你好") == 4
// ```
pub fn string_width(s string, east_asian bool) -> usize {
	if east_asian {
		return east_asian_condition.string_width(s)
	}

	return default_condition.string_width(s)
}

var (
	default_condition    = Width{}
	east_asian_condition = Width{}
)

// Width represents internal state.
//
// Set [`east_asian_width`] to true to compute width in East Asian context.
// [`Width`] with [`strict_emoji_neutral`] equal to true will return an
// emoji width of 2.
pub struct Width {
	east_asian_width     bool
	strict_emoji_neutral bool = true
}

// rune_width returns the width of the given rune, taking into account whether
// the context is East Asian or not. In East Asian contexts, some characters
// may have different widths compared to default context.
//
// Note: The width of a rune is the number of cells in [`r`], see http://www.unicode.org/reports/tr11/
//
// Example:
// ```
// w := unicode.Width{ east_asian_width: true, strict_emoji_neutral: false }
// assert w.rune_width(`😀`, false) == 2
// ```
pub fn (c &Width) rune_width(r rune) -> usize {
	if r < 0 || r > MAX_VALID_RUNE {
		return 0
	}

	if !c.east_asian_width {
		return match {
			r < 0x20 => 0
			(r >= 0x7F && r <= 0x9F) || r == 0xAD => 0
			r < 0x300 => 1
			in_table(r, NARROW) => 1
			in_tables(r, NONPRINT, COMBINING) => 0
			in_table(r, DOUBLEWIDTH) => 2
			else => 1
		}
	}

	return match {
		in_tables(r, NONPRINT, COMBINING) => 0
		in_table(r, NARROW) => 1
		in_tables(r, AMBIGUOUS, DOUBLEWIDTH) => 2
		!c.strict_emoji_neutral && in_tables(r, AMBIGUOUS, EMOJI, NARROW) => 2
		else => 1
	}
}

// string_width calculates the total width of the given string based on the
// width of each rune, in the provided [`Width`] context.
//
// The return value can be thought of as the actual width in ASCII characters,
// so "你好" will have a length of 4, which means that on the screen its width
// will be same as for word "Some" with a length of 4.
//
// Example:
// ```
// w := unicode.Width{ east_asian_width: true }
// assert w.string_width("hello") == 5
// assert w.string_width("你好") == 4
// ```
pub fn (c &Width) string_width(s string) -> usize {
	mut res := 0 as usize
	for r in s.runes_iter() {
		res += c.rune_width(r)
	}
	return res
}

fn in_tables(r rune, ts ...[]In) -> bool {
	for t in ts {
		if in_table(r, t) {
			return true
		}
	}
	return false
}

fn in_table(r rune, t []In) -> bool {
	if r < t[0].lo {
		return false
	}

	mut bot := 0
	mut top := (t.len - 1) as i32

	for top >= bot {
		mid := (bot + top) >> 1

		match {
			t[mid].hi < r => {
				bot = mid + 1
			}
			t[mid].lo > r => {
				top = mid - 1
			}
			else => return true
		}
	}

	return false
}
