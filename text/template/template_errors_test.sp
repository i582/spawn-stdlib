module main

import text.template

test "no closing }} at the end of template" {
	text := "Hello {{ .name "
	err := template.new("test", text).unwrap_err()

	t.assert_true(err is template.ParseError, "expected error should be a ParseError")
	p_err := err as template.ParseError
	t.assert_eq(p_err.msg(), "<template>:1:0: expected }}, got EOF
Hello {{ .name 

", "msg should match")
}

test "no closing }} with text after" {
	text := "Hello {{ .name , how are you?"
	err := template.new("test", text).unwrap_err()

	t.assert_true(err is template.ParseError, "expected error should be a ParseError")
	p_err := err as template.ParseError
	t.assert_eq(p_err.msg(), "<template>:1:15: expected }}, got illegal
Hello {{ .name , how are you?

", "msg should match")
}

test "no closing }} with HTML tag after" {
	text := "Hello <b>{{ .name </b>"
	err := template.new("test", text).unwrap_err()

	t.assert_true(err is template.ParseError, "expected error should be a ParseError")
	p_err := err as template.ParseError
	t.assert_eq(p_err.msg(), "<template>:1:19: unexpected operand expression, got `/`
Hello <b>{{ .name </b>
                   ^
help: maybe you forgot to close the expression with '}}'?
", "msg should match")
}

test "not a variable on left side of var declaration" {
	text := "Hello {{ .name := 100 }}"
	err := template.new("test", text).unwrap_err()

	t.assert_true(err is template.ParseError, "expected error should be a ParseError")
	p_err := err as template.ParseError
	t.assert_eq(p_err.msg(), "<template>:1:10: left side of variable declaration must be a variable, for example $age
Hello {{ .name := 100 }}
          ^^^^
", "msg should match")
}

test "not a variable on left side of assign" {
	text := "Hello {{ .name = 100 }}"
	err := template.new("test", text).unwrap_err()

	t.assert_true(err is template.ParseError, "expected error should be a ParseError")
	p_err := err as template.ParseError
	t.assert_eq(p_err.msg(), "<template>:1:10: left side of assignment must be a variable, for example $age
Hello {{ .name = 100 }}
          ^^^^
", "msg should match")
}

test "template directive with integer name" {
	text := "Hello {{ template 10 }}"
	err := template.new("test", text).unwrap_err()

	t.assert_true(err is template.ParseError, "expected error should be a ParseError")
	p_err := err as template.ParseError
	t.assert_eq(p_err.msg(), "<template>:1:18: expected string literal, got integer literal
Hello {{ template 10 }}
                  ^^
", "msg should match")
}

test "function call with non identifier after |" {
	text := "Hello {{ .name | 10 }}"
	err := template.new("test", text).unwrap_err()

	t.assert_true(err is template.ParseError, "expected error should be a ParseError")
	p_err := err as template.ParseError
	t.assert_eq(p_err.msg(), "<template>:1:17: expected identifier, got integer literal
Hello {{ .name | 10 }}
                 ^^
", "msg should match")
}

test "non identifier after ." {
	text := "Hello {{ .name.10 }}"
	err := template.new("test", text).unwrap_err()

	t.assert_true(err is template.ParseError, "expected error should be a ParseError")
	p_err := err as template.ParseError
	t.assert_eq(p_err.msg(), "<template>:1:15: expected identifier, got integer literal
Hello {{ .name.10 }}
               ^^
", "msg should match")
}

test "usage of undefined function" {
	text := "Hello {{ .name | foo }}"
	tmpl := template.new("test", text).unwrap()
	err := tmpl.render({ "name": "John" as template.Value }).unwrap_err()
	t.assert_eq(err.msg(), "<template>:1:17: function `foo` not found
Hello {{ .name | foo }}
                 ^^^
", "msg should match")
}

test "usage of undefined template" {
	text := "Hello {{ template 'foo' }}"
	tmpl := template.new("test", text).unwrap()
	err := tmpl.render({ "name": "John" as template.Value }).unwrap_err()

	t.assert_eq(err.msg(), "<template>:1:18: template `foo` not found
Hello {{ template 'foo' }}
                  ^^^^^
help: did you forget to call `add_template()` method?
", "msg should match")
}

test "usage of wrong spelled of template" {
	text := "Hello {{ template 'boo' }}"
	mut tmpl := template.new("test", text).unwrap()
	foo_tmpl := template.new("foo", "Hello {{ .name }}").unwrap()
	tmpl.add_template(foo_tmpl)
	err := tmpl.render({ "name": "John" as template.Value }).unwrap_err()

	t.assert_eq(err.msg(), "<template>:1:18: template `boo` not found
Hello {{ template 'boo' }}
                  ^^^^^
help: did you forget to call `add_template()` method? Known templates: foo
", "msg should match")
}
