module template

import strings
import io

// This file contains the implementation of renderer for the template engine.

// Value represents a value that can be used in the template engine.
//
// It uses in [`Template.render`] method to define the data for the template and
// in [`Template.func`] method to define a new function to use in the template.
pub union Value = i32 |
                  string |
                  bool |
                  map[string]Value |
                  []Value

// is_true returns true if the value is considered as true.
pub fn (v Value) is_true() -> bool {
	return match v {
		i32 => v != 0
		string => v != ''
		bool => v
		map[string]Value => v.len > 0
		[]Value => v.len > 0
	}
}

struct Renderer {
	tmpl        Template
	value_stack []Value
	variables   map[string]Value = map[string]Value{}

	func_map map[string]TemplateFn

	w io.Writer
}

fn Renderer.new_buffered(tmpl Template, func_map map[string]TemplateFn) -> &mut Renderer {
	return &mut Renderer{
		tmpl: tmpl
		func_map: func_map
		w: strings.new_builder(100) as io.Writer
	}
}

fn Renderer.new(w io.Writer, tmpl Template, func_map map[string]TemplateFn) -> &mut Renderer {
	return &mut Renderer{
		w: w
		func_map: func_map
		tmpl: tmpl
	}
}

fn (r &mut Renderer) render_to(w io.Writer, root Value) {
	r.w = w
	r.value_stack.push(root)

	for stmt in r.tmpl.root.stmts {
		r.render_stmt(stmt, root) or { continue }
	}
}

fn (r &mut Renderer) render(root Value) -> !string {
	r.value_stack.push(root)

	for stmt in r.tmpl.root.stmts {
		r.render_stmt(stmt, root)!
	}

	if r.w is strings.Builder {
		return r.w.str_view()
	}

	return ''
}

fn (r &mut Renderer) write(data string) {
	r.w.write_string(data) or {}
}

fn (r &mut Renderer) render_template(tmpl Template, root Value) -> ! {
	r.value_stack.push(root)
	for stmt in tmpl.root.stmts {
		r.render_stmt(stmt, root)!
	}
	r.value_stack.pop()
}

fn (r &mut Renderer) render_stmts(stmts []Stmt, val Value) -> ! {
	for stmt in stmts {
		r.render_stmt(stmt, val)!
	}
}

fn (r &mut Renderer) render_stmt(stmt Stmt, val Value) -> ! {
	if stmt is TextStmt {
		if stmt.text.ends_with('\n') {
			r.write(stmt.text[..stmt.text.len - 1])
			return
		}

		r.write(stmt.text)
	}

	if stmt is TemplateStmt {
		tmpl_name := unwrap_string(stmt.name)
		tmpl := r.tmpl.children.get(tmpl_name) or {
			available_tmpls := r.tmpl.children.keys().join(', ')
			mut help := "did you forget to call `add_template()` method?"
			if available_tmpls.len > 0 {
				help = help + " Known templates: ${available_tmpls}"
			}
			return error(BaseTmplError{
				filepath: r.tmpl.filepath
				template: r.tmpl.content
				pos: stmt.name_pos
				msg: 'template `${tmpl_name}` not found'
				help: help
			} as RendererError)
		}
		if arg := stmt.arg {
			tmpl_val := r.eval_expr(arg, val)!
			r.render_template(tmpl, tmpl_val)!
			return
		}
		r.render_template(tmpl, val)!
	}

	if stmt is VarDecl {
		name := stmt.ident.ident
		value := r.eval_expr(stmt.expr, val)!
		r.variables[name] = value
	}

	if stmt is AssignStmt {
		name := stmt.ident.ident
		value := r.eval_expr(stmt.expr, val)!
		r.variables[name] = value
	}

	if stmt is StatementStmt {
		r.render_expr(stmt.expr, val)!
	}

	if stmt is IfStmt {
		cond := r.eval_expr(stmt.cond, val)!
		if cond.is_true() {
			r.render_stmts(stmt.stmts, val)!
		} else {
			if else_ := stmt.else_ {
				r.render_stmts(else_.stmts, val)!
			}
		}
	}

	if stmt is ForStmt {
		iter_val := r.eval_expr(stmt.expr, val)!
		if iter_val is []Value {
			values := iter_val

			for item in values {
				r.value_stack.push(item)
				r.render_stmts(stmt.stmts, item)!
				r.value_stack.pop()
			}
		}
	}
}

fn (r &mut Renderer) render_expr(expr Expr, val Value) -> ! {
	value := r.eval_expr(expr, val)!
	r.write(r.render_value(value))
}

fn (r &mut Renderer) render_value(val Value) -> string {
	if val is string {
		return val
	}

	return ''
}

fn (r &mut Renderer) eval_expr(expr Expr, val Value) -> !Value {
	if expr is Dot {
		return r.value_stack.last()
	}

	if expr is Var {
		return r.variables[expr.ident]
	}

	if expr is Lit {
		if expr.tok == .int {
			return expr.lit.i32()
		}

		if expr.tok == .string {
			return expr.lit
		}
	}

	if expr is RootSelector {
		dot_value := r.value_stack.last()
		field := expr.ident.ident
		if dot_value is map[string]Value {
			return dot_value[field]
		}
	}

	if expr is &mut Selector {
		qualifier := r.eval_expr(expr.expr, val)!
		field := expr.ident.ident

		if qualifier is map[string]Value {
			return qualifier[field]
		}
	}

	if expr is &mut PipeCall {
		expr_val := r.eval_expr(expr.expr, val)!
		func := r.func_map.get(expr.name.ident) or {
			return error(BaseTmplError{
				filepath: r.tmpl.filepath
				template: r.tmpl.content
				pos: expr.name.pos
				msg: 'function `${expr.name.ident}` not found'
			} as RendererError)
		}
		return func(expr_val)
	}

	if expr is &mut BinExpr {
		left := r.eval_expr(expr.left, val)!
		right := r.eval_expr(expr.right, val)!

		op := expr.op

		if op == .gt {
			if left is string && right is string {
				return unwrap_string(left) > unwrap_string(right)
			}
			if left is i32 && right is i32 {
				return left > right
			}
		}

		if op == .ge {
			if left is string && right is string {
				return unwrap_string(left) >= unwrap_string(right)
			}
			if left is i32 && right is i32 {
				return left >= right
			}
		}

		if op == .lt {
			if left is string && right is string {
				return unwrap_string(left) < unwrap_string(right)
			}
			if left is i32 && right is i32 {
				return left < right
			}
		}

		if op == .le {
			if left is string && right is string {
				return unwrap_string(left) <= unwrap_string(right)
			}
			if left is i32 && right is i32 {
				return left <= right
			}
		}

		if op == .equal {
			if left is string && right is string {
				return unwrap_string(left) == unwrap_string(right)
			}
			if left is i32 && right is i32 {
				return left == right
			}
		}

		if op == .not_equal {
			if left is string && right is string {
				return unwrap_string(left) != unwrap_string(right)
			}
			if left is i32 && right is i32 {
				return left != right
			}
		}

		if op == .plus {
			if left is string && right is string {
				return unwrap_string(left) + unwrap_string(right)
			}
			if left is i32 && right is i32 {
				return left + right
			}
			if left is []Value && right is []Value {
				return left + right
			}
		}
	}

	return ''
}

fn unwrap_string(str string) -> string {
	if str.starts_with('"') {
		return str.remove_surrounding('"', '"')
	}
	return str.remove_surrounding("'", "'")
}
