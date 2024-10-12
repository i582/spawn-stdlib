module main

import toml
import testing
import strings

fn pretty_print(str string) -> (string, string) {
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

	mut printer := toml.PrettyPrinter.new()
	res := printer.print(f)

	return res, ""
}

test "Pretty Printer" {
	s := testing.Suit.create(t, "Pretty Printer", fn (c testing.Case) -> string {
		res, errors := pretty_print(c.code)
		if errors.len != 0 {
			return errors
		}
		return res
	})
	s.run_test_in_dir("y/toml/tests/pretty_printer").unwrap()
}
