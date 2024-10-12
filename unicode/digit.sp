module unicode

// is_digit reports whether the rune is a decimal digit.
//
// Example:
// ```
// assert unicode.is_digit(`1`)
// assert unicode.is_digit(`𞅀`)
// assert unicode.is_digit(`A`) == false
// ```
pub fn is_digit(r rune) -> bool {
	if r <= MAX_LATIN1 {
		return `0` <= r && r <= `9`
	}
	return is_excluding_latin(DIGIT, r)
}
