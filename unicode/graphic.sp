module unicode

// is_punct reports whether the rune is a Unicode punctuation character
// (category [`P`]).
//
// Example:
// ```
// assert unicode.is_punct(`,`)
// assert unicode.is_punct(`】`)
// assert unicode.is_punct(`A`) == false
// ```
pub fn is_punct(r rune) -> bool {
	if r <= MAX_LATIN1 {
		return PROPERTIES[(r & 0xFF) as u8] & pP != 0
	}
	return is_a(PUNCT, r)
}

// is_letter reports whether the rune is a letter (category [`L`]).
//
// Example:
// ```
// assert unicode.is_letter(`A`)
// assert unicode.is_letter(`Ы`)
// assert unicode.is_letter(`0`) == false
// ```
pub fn is_letter(r rune) -> bool {
	if r <= MAX_LATIN1 {
		return PROPERTIES[(r & 0xFF) as u8] & pLmask != 0
	}
	return is_excluding_latin(LETTER, r)
}
