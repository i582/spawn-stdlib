module main

import toml
import testing
import strings

fn parse(str string) -> (string, string) {
	mut errs := strings.new_builder(100)
	report_cb := fn (err toml.ParseError) {
		errs.write_str(err.to_string())
		errs.write_str('\n\n')
	}

	s := toml.Scanner.new(str, report_cb)
	p := toml.Parser.new(s, report_cb)
	f := p.parse()

	if errs.len != 0 {
		return "", errs.str_view()
	}

	return f.str(), ""
}

test "Parser" {
	s := testing.Suit.create(t, "Parser", fn (c testing.Case) -> string {
		ast_str, errors := parse(c.code)
		if errors.len != 0 {
			return errors
		}
		return ast_str
	})
	s.run_test_in_dir("y/toml/tests/parser").unwrap()
}
