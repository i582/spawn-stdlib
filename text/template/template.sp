module template

import fs
import io

// new creates a new template from a string with the given name.
//
// If the template is invalid, a [`TemplateError`] is returned.
//
// Example:
// ```
// tmpl := template.new("example", "Hello, {{ .name }}!").unwrap()
// ```
pub fn new(name string, content string) -> ![Template, TemplateError] {
	return Template.new(name, "<template>", content)
}

// load creates a new template from a file with the given name.
//
// If the file cannot be read or the template is invalid, a [`TemplateError`] is returned.
//
// Example:
// ```
// tmpl := template.load("example", "example.tmpl").unwrap()
// ```
pub fn load(name string, path string) -> ![Template, TemplateError] {
	return Template.load(name, path)
}

// TemplateFn is a function type describing a function that can be used in a template
// to transform a value.
pub type TemplateFn = fn (_ Value) -> Value

// Template represents a parsed template.
pub struct Template {
	// name is the name of the template.
	name string

	// content is the raw content of the template.
	content string

	// filepath is the path to the file where the template was loaded from
	// or "<template>" if it was created from a string.
	filepath string

	// root is the root node of the parsed template.
	root File

	// func_map is a map of functions that can be used in the template.
	//
	// To add a function, use the [`Template.func`] method.
	func_map map[string]TemplateFn = map[string]TemplateFn{}

	// children is a map of child templates that can be included in the template.
	//
	// To add a child template, use the [`Template.add_template`] method.
	children map[string]Template = map[string]Template{}
}

// load creates a new template from a string with the given name.
//
// See [`template.load`] for more information.
fn Template.load(name string, path string) -> ![Template, TemplateError] {
	content := fs.read_file(path) or {
		return error(err as TemplateCannotBeLoaded)
	}
	return Template.new(name, path, content)
}

// new creates a new template from a string with the given name.
//
// See [`template.new`] for more information.
fn Template.new(name string, filepath string, content string) -> ![Template, TemplateError] {
	s := Scanner.new(content, filepath)
	p := Parser.new(s)
	root := p.parse_template()
	if last_error := p.last_error {
		return error(last_error)
	}

	return Template{
		name: name
		content: content
		filepath: filepath
		root: root
	}
}

// func adds a function to the template that can be used in the template.
//
// Example:
// ```
// tmpl.func("upper", fn (v template.Value) -> template.Value {
//     if v is string {
//        return v.to_upper()
//     }
//
//     return v
// })
// ```
pub fn (t &mut Template) func(name string, f TemplateFn) {
	t.func_map[name] = f
}

// add_template adds a child template to the template that can
// be included in the template.
//
// Example:
// ```
// tmpl := template.new("main", '
//     {{ template "header" }}
//     Hello, {{ .name }}!
// ').unwrap()
// header := template.new("header", "<header>Header</header>").unwrap()
// tmpl.add_template(header)
// ```
pub fn (t &mut Template) add_template(tmpl Template) {
	t.children[tmpl.name] = tmpl
}

// render renders the template with the given data and returns the result as a string.
//
// If the data is invalid or the template cannot be rendered, a [`TemplateError`] is returned.
//
// Example:
// ```
// tmpl := template.new("example", "Hello, {{ .name }}!").unwrap()
// result := tmpl.render({ "name": "World" as template.Value }).unwrap()
// ```
pub fn (t &Template) render(data map[string]Value) -> !string {
	r := Renderer.new_buffered(*t, t.func_map)
	return r.render(data)
}

fn (t &Template) render_to(w io.Writer, data map[string]Value) {
	r := Renderer.new(w, *t, t.func_map)
	r.render_to(w, data)
}
