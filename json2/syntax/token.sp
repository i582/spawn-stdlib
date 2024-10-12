module syntax

enum Token {
	eof
	illegal
	comment
	lbrack // [
	rbrack // ]
	lbrace // {
	rbrace // }
	comma  // ,
	colon  // :
	string
	number
	true_
	false_
	null
}
