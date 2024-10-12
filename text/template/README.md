# `template` module

Template module provides an implementation of template text engine.

Example:

```spawn
import template

fn main() {
    tmpl := template.new('test', '
    <p>
        <p>Hello, {{ .name }}</p>
    </p>
    '.trim_indent()).unwrap()

    println(tmpl.render({
        'name': "John" as template.Value
    }).unwrap())
}
```

Output:

```txt
<p>
    <p>Hello, John</p>
</p>
```

## Usage

Template can be loaded from a string or a file. To load a template from a file,
use `template.load()` function.

```spawn
tmpl := template.load('path/to/template.html').unwrap()
```

To load a template from a string, use `template.new()` function.

```spawn
tmpl := template.new('test', '<p>Hello, {{ .name }}</p>').unwrap()
```

Both functions return an error if the template is invalid. To show nice looking
error message, use `or {}` and call `render()` method.

```spawn
import template

fn main() {
    tmpl := template.new('test', '
    <p>
        <p>Hello, {{ .name </p>
    </p>
    '.trim_indent()) or {
        println(err.render())
        return
    }
}
```

Output:

```txt
<template>:2:24: unexpected operand expression, got `/`
    <p>Hello, {{ .name </p>
                        ^
help: maybe you forgot to close the expression with '}}'?
```

To render a template, use `render()` method. Method accepts a map with
values to render the template. Current compiler implementation requires
to cast first value to `template.Value` explicitly. If you want to pass array
or map as value, cast first element to `template.Value` as well:

```spawn
tmpl.render({
    'name': "John" as template.Value
    'title': "Mr."
    'childrens': ["Alice" as template.Value, "Bob", "Charlie"]
}).unwrap()
```

If while rendering a template an error occurs, it is returned from `render()`
method. As for loading a template, to show nice looking error message,
use `or {}` and call `render()` method.

## Embedding templates

Templates can be embedded in each other. To embed a template, use
[`template` statement](#template).

```txt
{{ template "header" }}
```

In order for the template to be found, call `add_template()` method on the
template.

```spawn
other_tmplr := template.new('header', '<header><h1>Header</h1></header>').unwrap()
tmpl.add_template(other_tmplr).unwrap()
```

## Call functions on values

To call a function on a value, use [pipe call](#pipe-call) syntax.

```txt
{{ .name | upper }}
```

To define a function, use `func()` method on the template.

```spawn
tmpl.func('upper', fn (value template.Value) -> template.Value {
    if value is string {
        return value.to_upper()
    }
    return value
})
```

Function must accept a `template.Value` and return a `template.Value`. If
function is not found, an error is returned from `render()` method.

## Template syntax

Template engine uses Go-like template syntax.

To render a value, write an expression inside double curly braces. To access
current value, use `.`. To access nested value, use dot notation.

```txt
<p>Hello, {{ .name }}</p>
<p>Your age is {{ .extra_info.age }}</p>
```

### Statements

#### If

If statement is used to conditionally render a block of text.

```txt
{{ if .is_admin }}
    <p>Welcome, admin!</p>
{{ end }}
```

If condition is false block will not be rendered. To render other block if
condition is false, use `else` statement.

```txt
{{ if .is_admin }}
    <p>Welcome, admin!</p>
{{ else }}
    <p>Welcome, user!</p>
{{ end }}
```

#### For

For statement is used to iterate over a list of values and render a block
for each value.

```txt
{{ for .users }}
    <p>{{ .name }}</p>
{{ end }}
```

Dot in for statement block refers to the current iteration value.

#### Variables

To define a variable, use `$name := value` syntax.

```txt
{{ $name := .name }}
<p>Hello, {{ $name }}</p>
```

Defined variable can be used in the same block or in nested blocks.

To reassign a variable, use `$name = value` syntax.

```txt
{{ $name := .name }}
{{ if .is_admin }}
    {{ $name = "Admin" }}
{{ end }}

<p>Hello, {{ $name }}</p>
```

#### Template

To include another template, use `template` statement.

```txt
{{ template "header" }}
```

By default, if no explicit value is passed, current value is used. To pass
a value, write it after template name.

```txt
{{ template "header" .header }}
```

If no template is found, an error is returned from `render()` method.

### Expressions

Expressions are used to render values. It's used inside double curly braces.

#### Root (dot)

Root or dot expression is used to access current value.

```txt
<p>Hello, {{ . }}</p>
```

#### Selector

Selector expression is used to access nested values.

```txt
<p>Hello, {{ .name }}</p>
<p>Your age is {{ .extra_info.age }}</p>
```

#### Variable

Variable expression is used to access variables.

```txt
{{ $name }}
```

#### Integer literal

Integer literal is used to define an integer value.

```txt
{{ 42 }}
```

For now only 10-based integers are supported without `_` separator.

#### String literal

String literal is used to define a string value.

```txt
{{ "Hello, world!" }}
```

#### Pipe call

Pipe call is used to call a function on a value.

```txt
{{ .name | upper }}
```

Pipe call can be chained.

```txt
{{ .name | upper | reverse }}
```
