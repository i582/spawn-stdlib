module token

// Pos represents a position in the input string.
pub struct Pos {
	offset usize
	len    usize
}

// str returns a string representation of the position.
pub fn (p &Pos) str() -> string {
	return '(${p.offset}, ${p.len})'
}

// union_with returns a new position that represents the union of the two positions.
// First position must be less than or equal to the second position.
pub fn (p &Pos) union_with(other Pos) -> Pos {
	return Pos{
		offset: p.offset
		len: other.offset + other.len - p.offset
	}
}
