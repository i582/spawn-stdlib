module template

import text.template.token
import mem

struct Parser {
	scan &mut Scanner

	tok token.Token // 1 token look-ahead
	pos token.Pos
	lit string

	last_error ?TemplateError
}

fn Parser.new(scan &mut Scanner) -> &mut Parser {
	return &mut Parser{ scan: scan }
}

fn (p &mut Parser) unexpected(msg string) {
	p.error(p.pos, "unexpected ${msg}, got ${p.tok}", "")
}

fn (p &mut Parser) expected(msg string) {
	p.error(p.pos, "expected ${msg}, got ${p.tok}", "")
}

fn (p &mut Parser) error(pos token.Pos, msg string, help string) {
	if p.last_error != none {
		return
	}
	p.last_error = BaseTmplError{
		pos: pos
		msg: msg
		help: help
		template: p.scan.src
		filepath: p.scan.filepath
	} as ParseError
}

fn (p &mut Parser) next() -> token.Token {
	p.pos, p.tok, p.lit = p.scan.scan()

	return p.tok
}

fn (p &mut Parser) parse_template() -> File {
	p.next()
	return File{ stmts: p.parse_stmts() }
}

fn (p &mut Parser) parse_stmts() -> []Stmt {
	mut stmts := []Stmt{cap: 5}

	for p.tok != .eof {
		stmt := p.parse_stmt()
		if stmt is BadStmt {
			break
		}
		stmts.push(stmt)
	}

	return stmts
}

fn (p &mut Parser) parse_stmts_until_end() -> []Stmt {
	mut stmts := []Stmt{cap: 5}

	for p.tok != .eof {
		stmt := p.parse_stmt()
		if stmt is BadStmt {
			break
		}
		stmts.push(stmt)

		if stmt is EndStmt || stmt is ElseStmt {
			break
		}
	}

	return stmts
}

fn (p &mut Parser) parse_stmt() -> Stmt {
	if p.tok == .text {
		text := p.lit
		p.next()
		return TextStmt{ text: text }
	}

	if p.tok == .open_brace {
		p.next()
		if p.tok == .template {
			return p.parse_template_stmt()
		}
		if p.tok == .if_ {
			return p.parse_if_stmt()
		}
		if p.tok == .else_ {
			return p.parse_else_stmt()
		}
		if p.tok == .for_ {
			return p.parse_for_stmt()
		}
		if p.tok == .end {
			return p.parse_end_stmt()
		}

		return p.parse_expr_stmt()
	}

	p.unexpected("statement")
	return BadStmt{}
}

fn (p &mut Parser) parse_template_stmt() -> Stmt {
	p.next()

	name := p.parse_string()

	if p.tok == .close_brace {
		p.next()
		return TemplateStmt{ name: name.lit, name_pos: name.pos }
	}

	expr := p.parse_expr()

	if p.tok != .close_brace {
		p.expected("}}")
		return BadStmt{}
	}

	p.next()

	return TemplateStmt{ name: name.lit, arg: expr, name_pos: name.pos }
}

fn (p &mut Parser) parse_for_stmt() -> Stmt {
	p.next()
	expr := p.parse_expr()

	if p.tok != .close_brace {
		p.expected("}}")
		return BadStmt{}
	}

	p.next()

	stmts := p.parse_stmts_until_end()

	return ForStmt{ expr: expr, stmts: stmts }
}

fn (p &mut Parser) parse_if_stmt() -> Stmt {
	p.next()
	expr := p.parse_expr()

	if p.tok != .close_brace {
		p.expected("}}")
		return BadStmt{}
	}

	p.next()

	mut stmts := p.parse_stmts_until_end()
	if stmts.len > 0 {
		last := stmts.last()
		if last is ElseStmt {
			stmts.remove_last()
			return IfStmt{ cond: expr, stmts: stmts, else_: last }
		}
	}

	return IfStmt{ cond: expr, stmts: stmts }
}

fn (p &mut Parser) parse_else_stmt() -> Stmt {
	p.next()

	if p.tok != .close_brace {
		p.expected("}}")
		return BadStmt{}
	}

	p.next()

	stmts := p.parse_stmts_until_end()

	return ElseStmt{ stmts: stmts }
}

fn (p &mut Parser) parse_end_stmt() -> Stmt {
	p.next()

	if p.tok != .close_brace {
		p.expected("}}")
		return BadStmt{}
	}

	p.next()

	return EndStmt{}
}

fn (p &mut Parser) parse_expr_stmt() -> Stmt {
	expr := p.parse_expr()

	if p.tok == .define {
		if expr !is Var {
			p.error(expr.pos(), "left side of variable declaration must be a variable, for example $age", "")
			return BadStmt{}
		}

		p.next()

		val := p.parse_expr()

		if p.tok != .close_brace {
			p.expected("}}")
			return BadStmt{}
		}

		p.next()

		return VarDecl{ ident: expr, expr: val }
	}

	if p.tok == .assign {
		if expr !is Var {
			p.error(expr.pos(), "left side of assignment must be a variable, for example $age", "")
			return BadStmt{}
		}

		p.next()

		val := p.parse_expr()

		if p.tok != .close_brace {
			p.expected("}}")
			return BadStmt{}
		}

		p.next()

		return AssignStmt{ ident: expr, expr: val }
	}

	if p.tok != .close_brace {
		p.expected("}}")
		return BadStmt{}
	}

	p.next()
	return StatementStmt{ expr: expr }
}

fn (p &mut Parser) parse_expr() -> Expr {
	return p.parse_bin_expr(token.LOWEST_PRECEDENCE + 1)
}

fn (p &mut Parser) parse_bin_expr(prec token.Precedence) -> Expr {
	mut expr := p.parse_unary_expr()

	for _ in 0 .. 200 {
		op, op_prec, op_pos := p.tok, p.tok.precedence(), p.pos
		if op_prec < prec {
			return expr
		}

		if op == .pipe {
			p.next()
			right := p.parse_ident()

			expr = mem.to_heap_mut(&mut PipeCall{ expr: expr, name: right })
			continue
		}

		p.next()
		right := p.parse_bin_expr(op_prec + 1)
		expr = mem.to_heap_mut(&mut BinExpr{ left: expr, op: op, right: right })
	}

	return expr
}

fn (p &mut Parser) parse_unary_expr() -> Expr {
	return p.parse_primary_expr()
}

fn (p &mut Parser) parse_primary_expr() -> Expr {
	mut expr := p.parse_operand_expr()

	for _ in 0 .. 100 {
		if p.tok == .dot {
			p.next()
			expr = p.parse_selector_expr(expr)
			continue
		}

		break
	}

	return expr
}

fn (p &mut Parser) parse_operand_expr() -> Expr {
	if p.tok == .ident {
		return p.parse_ident()
	}

	if p.tok == .variable {
		ident := p.lit
		pos := p.pos
		p.next()
		return Var{ ident: ident, pos: pos }
	}

	if p.tok == .dot {
		dot_pos := p.pos
		p.next()
		if p.tok == .close_brace {
			return Dot{ pos: dot_pos }
		}

		ident := p.parse_ident()
		return RootSelector{ ident: ident }
	}

	if p.tok == .int {
		value := p.lit
		pos := p.pos
		p.next()
		return Lit{ lit: value, tok: .int, pos: pos }
	}

	if p.tok == .string {
		return p.parse_string()
	}

	p.error(p.pos, "unexpected operand expression, got `${p.tok}`", "maybe you forgot to close the expression with '}}'?")
	return BadExpr{}
}

fn (p &mut Parser) parse_selector_expr(expr Expr) -> &mut Selector {
	sel := p.parse_ident()
	return &mut Selector{ expr: expr, ident: sel }
}

fn (p &mut Parser) parse_ident() -> Ident {
	if p.tok != .ident {
		p.expected("identifier")
		return Ident{}
	}

	ident := p.lit
	pos := p.pos
	p.next()

	return Ident{ ident: ident, pos: pos }
}

fn (p &mut Parser) parse_string() -> Lit {
	if p.tok != .string {
		p.expected("string literal")
		return Lit{ tok: .string }
	}

	value := p.lit
	pos := p.pos
	p.next()
	return Lit{ lit: value, tok: .string, pos: pos }
}
