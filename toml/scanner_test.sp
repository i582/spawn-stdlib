module main

import toml.token
import toml
import testing
import strings

struct Token {
	tok token.Token
	lit string
	pos token.Pos
}

fn (t Token) equal(o Token) -> bool {
	return t.tok == o.tok && t.lit == o.lit && t.pos == o.pos
}

fn (t Token) str() -> string {
	prep_lit := t.lit.replace('\n', '\\n')
	return '${t.pos}: ${t.tok} (${prep_lit})'
}

fn scan(str string) -> ([]Token, string) {
	mut errs := strings.new_builder(100)
	s := toml.Scanner.new(str, fn (err toml.ParseError) {
		errs.write_str(err.to_string())
		errs.write_str('\n\n')
	})
	mut toks := []Token{}

	for {
		pos, tok, lit := s.scan()
		toks.push(Token{ tok: tok, lit: lit, pos: pos })
		if tok == .eof {
			break
		}
	}

	if errs.len != 0 {
		return [], errs.str_view()
	}

	return toks, ""
}

test "Scanner" {
	s := testing.Suit.create(t, "Scanner", fn (c testing.Case) -> string {
		tokens, errors := scan(c.code)
		if errors.len != 0 {
			return errors
		}
		return tokens.map(fn (el Token) -> string {
			return el.str()
		}).join("\n")
	})
	s.run_test_in_dir("y/toml/tests/scanner").unwrap()
}
