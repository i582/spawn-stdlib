module token

// Token represents a lexical token of the template language.
pub enum Token {
	eof
	illegal
	text
	open_brace
	close_brace
	ident
	variable
	dot
	int
	string
	if_
	else_
	end
	for_
	template

	// operators
	not
	and
	assign
	define
	cond_or
	cond_and
	equal
	not_equal
	le
	ge
	lt
	gt
	in_
	not_in
	plus
	minus
	pipe
	xor
	star
	slash
}

// str returns the string representation of the token.
pub fn (t Token) str() -> string {
	return match t {
		.eof => "EOF"
		.illegal => "illegal"
		.text => "text content"
		.open_brace => "{{"
		.close_brace => "}}"
		.ident => "identifier"
		.variable => "variable"
		.dot => "."
		.int => "integer literal"
		.string => "string literal"
		.if_ => "if"
		.else_ => "else"
		.end => "enc"
		.for_ => "for"
		.template => "template"
		.not => "!"
		.and => "&"
		.assign => "="
		.define => ":="
		.cond_or => "||"
		.cond_and => "&&"
		.equal => "=="
		.not_equal => "!="
		.le => "<="
		.ge => ">="
		.lt => "<"
		.gt => ">"
		.in_ => "in"
		.not_in => "!in"
		.plus => "+"
		.minus => "-"
		.pipe => "|"
		.xor => "^"
		.star => "*"
		.slash => "/"
	}
}

// Precedence represents the precedence of an operator.
pub type Precedence = i32

// LOWEST_PRECEDENCE represents the lowest precedence.
pub const LOWEST_PRECEDENCE = 0 as Precedence

// precedence returns the precedence of the token.
pub fn (t Token) precedence() -> Precedence {
	return match t {
		.cond_or => 1
		.cond_and => 2
		.equal, .not_equal, .le, .ge, .lt, .gt, .in_, .not_in => 3
		.plus, .minus, .xor => 4
		.star, .slash => 5
		.pipe => 6
		else => LOWEST_PRECEDENCE
	}
}
