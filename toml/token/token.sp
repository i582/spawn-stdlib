module token

pub enum Token {
	eof
	illegal
	newline
	whitespace
	comment
	lbrack        // [
	rbrack        // ]
	double_lbrack // [[
	double_rbrack // ]]
	lbrace        // {
	rbrace        // }
	lparen        // (
	rparen        // )
	comma         // ,
	assign        // =
	dot           // .
	colon         // :
	string
	triple_string
	integer
	float
	true_
	false_
	ident
	datetime
}

pub struct Pos {
	offset usize
	len    usize
}

pub fn (p Pos) equal(other Pos) -> bool {
	return p.offset == other.offset && p.len == other.len
}

pub fn (p &Pos) str() -> string {
	return '${p.offset}:${p.len}'
}
