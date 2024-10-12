module main

import text.template

test "simple template" {
	text := "Hello {{ .name }}!"
	tmpl := template.new("test", text).unwrap()
	rendered := tmpl.render({ "name": "world" as template.Value }).unwrap()

	t.assert_eq(rendered, "Hello world!", "expected rendered text is not equal to actual")
}

test "selector expression" {
	text := "Hello {{ .person.name }}!"
	tmpl := template.new("test", text).unwrap()
	rendered := tmpl.render({
		"person": { "name": "John" as template.Value } as template.Value
	}).unwrap()

	t.assert_eq(rendered, "Hello John!", "expected rendered text is not equal to actual")
}

test "if stmt" {
	text := "{{ if .name == 'John' }} Hello John! {{ end }}"
	tmpl := template.new("test", text).unwrap()
	rendered := tmpl.render({ "name": "John" as template.Value }).unwrap()

	t.assert_eq(rendered, " Hello John! ", "expected rendered text is not equal to actual")
}

test "if stmt with else" {
	text := "{{ if .name == 'John' }} Hello John! {{ else }} Hello Stranger! {{ end }}"
	tmpl := template.new("test", text).unwrap()
	rendered := tmpl.render({ "name": "Joe" as template.Value }).unwrap()

	t.assert_eq(rendered, " Hello Stranger! ", "expected rendered text is not equal to actual")
}

test "for stmt" {
	text := "{{ for .names }} Hello {{ . }}! {{ end }}"
	tmpl := template.new("test", text).unwrap()
	rendered := tmpl.render({
		"names": ["John" as template.Value, "Doe"] as template.Value
	}).unwrap()

	t.assert_eq(rendered, " Hello John!  Hello Doe! ", "expected rendered text is not equal to actual")
}

test "call function" {
	text := "{{ .name | upper }}"
	mut tmpl := template.new("test", text).unwrap()

	tmpl.func("upper", fn (v template.Value) -> template.Value {
		return (v as string).to_upper()
	})

	rendered := tmpl.render({
		"name": "John" as template.Value
	}).unwrap()

	t.assert_eq(rendered, "JOHN", "expected rendered text is not equal to actual")
}

test "several function call" {
	text := "{{ .name | upper | lower }}"
	mut tmpl := template.new("test", text).unwrap()

	tmpl.func("upper", fn (v template.Value) -> template.Value {
		return (v as string).to_upper()
	})

	tmpl.func("lower", fn (v template.Value) -> template.Value {
		return (v as string).to_lower()
	})

	rendered := tmpl.render({
		"name": "John" as template.Value
	}).unwrap()

	t.assert_eq(rendered, "john", "expected rendered text is not equal to actual")
}

test "var decl" {
	text := "{{ $name := .user.name }} Hello {{ $name }}!"
	tmpl := template.new("test", text).unwrap()
	rendered := tmpl.render({
		"user": { "name": "John" as template.Value } as template.Value
	}).unwrap()

	t.assert_eq(rendered, " Hello John!", "expected rendered text is not equal to actual")
}

test "var decl with reassign" {
	text := "{{ $name := .user.name }}
{{ $name = 'Mr. ' + $name }}
Hello {{ $name }}!"
	tmpl := template.new("test", text).unwrap()
	rendered := tmpl.render({
		"user": { "name": "John" as template.Value } as template.Value
	}).unwrap()

	t.assert_eq(rendered, "\nHello Mr. John!", "expected rendered text is not equal to actual")
}

test "var decl with conditional reassign" {
	text := "{{ $name := .user.name }}
{{ if .user.age > 20 }}
{{ $name = 'Mr. ' + $name }}
{{ end }}
Hello {{ $name }}!"
	tmpl := template.new("test", text).unwrap()
	rendered := tmpl.render({
		"user": {
			"name": "John" as template.Value
			"age":  30 as template.Value
		} as template.Value
	}).unwrap()

	t.assert_eq(rendered, "\nHello Mr. John!", "expected rendered text is not equal to actual")
}

test "template stmt without arg" {
	mut tmpl := template.new("test", 'Hello {{ template "user_tmpl" }}').unwrap()
	tmpl2 := template.new("user_tmpl", 'John').unwrap()
	tmpl.add_template(tmpl2)

	rendered := tmpl.render({ "name": "John" as template.Value }).unwrap()

	t.assert_eq(rendered, "Hello John", "expected rendered text is not equal to actual")
}

test "template stmt with dot arg" {
	mut tmpl := template.new("test", 'Hello {{ template "user_tmpl" . }}').unwrap()
	tmpl2 := template.new("user_tmpl", '{{ .name }}').unwrap()
	tmpl.add_template(tmpl2)

	rendered := tmpl.render({ "name": "John" as template.Value }).unwrap()

	t.assert_eq(rendered, "Hello John", "expected rendered text is not equal to actual")
}

test "template stmt with dot arg and selector" {
	mut tmpl := template.new("test", 'Hello {{ template "user_tmpl" . }}').unwrap()
	tmpl2 := template.new("user_tmpl", '{{ .user.name }}').unwrap()
	tmpl.add_template(tmpl2)

	rendered := tmpl.render({ "user": { "name": "John" as template.Value } as template.Value }).unwrap()

	t.assert_eq(rendered, "Hello John", "expected rendered text is not equal to actual")
}

test "template stmt with selector arg" {
	mut tmpl := template.new("test", 'Hello {{ template "user_tmpl" .user }}').unwrap()
	tmpl2 := template.new("user_tmpl", '{{ .name }}').unwrap()
	tmpl.add_template(tmpl2)

	rendered := tmpl.render({ "user": { "name": "John" as template.Value } as template.Value }).unwrap()

	t.assert_eq(rendered, "Hello John", "expected rendered text is not equal to actual")
}

test "template stmt with deep selector arg" {
	mut tmpl := template.new("test", 'Hello {{ template "user_tmpl" .user.name }}').unwrap()
	tmpl2 := template.new("user_tmpl", '{{ . }}').unwrap()
	tmpl.add_template(tmpl2)

	rendered := tmpl.render({ "user": { "name": "John" as template.Value } as template.Value }).unwrap()

	t.assert_eq(rendered, "Hello John", "expected rendered text is not equal to actual")
}

test "render to writer" {
	// TODO:
	//     mut sb := strings.new_builder(100)
	//     w := sb as io.Writer
	//
	//     text := "{{ $name := .user.name }}
	// {{ if .user.age > 20 }}
	// {{ $name = 'Mr. ' + $name }}
	// {{ end }}
	// Hello {{ $name }}!"
	//     tmpl := template.new("test", text)
	//     tmpl.render_to(w, {
	//         "user": {
	//             "name": "John" as template.Value
	//             "age":  30 as template.Value
	//         } as template.Value
	//     })
	//
	//     sb.len = 10
	//     t.assert_eq(sb.str(), "Hello John", "expected rendered text is not equal to actual")
}
