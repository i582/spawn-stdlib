module template

import text.template.token

// This file defines the AST for the template language.

struct File {
	stmts []Stmt
}

union Stmt = TextStmt |
             TemplateStmt |
             StatementStmt |
             VarDecl |
             AssignStmt |
             IfStmt |
             ElseStmt |
             ForStmt |
             BadStmt |
             EndStmt

// TextStmt is a statement that will be output as-is.
struct TextStmt {
	text string
}

// TemplateStmt is a statement that will be evaluated as a template.
// Example:
// ```
// {{ template "name" }}
// {{ template "name" .Person }}
// ```
struct TemplateStmt {
	name     string
	name_pos token.Pos
	arg      ?Expr
}

// StatementStmt is a statement that can be evaluated
// and will produce output.
//
// Example:
// ```
// {{ .name }}
// {{ .name | upper }}
// ```
struct StatementStmt {
	expr Expr
}

// VarDecl is a variable declaration statement.
// Example:
// ```
// {{ $name := "world" }}
// ```
struct VarDecl {
	ident Var
	expr  Expr
}

// AssignStmt is an assignment statement.
// Example:
// ```
// {{ $name = "world" }}
// ```
struct AssignStmt {
	ident Var
	expr  Expr
}

// IfStmt is an if statement.
// Example:
// ```
// {{ if .show }}
// Hello {{ .name }}
// {{ end }}
// ```
struct IfStmt {
	cond  Expr
	stmts []Stmt
	else_ ?ElseStmt
}

// ElseStmt is an else statement.
// Example:
// ```
// {{ if .show }}
// Hello {{ .name }}
// {{ else }}
// Hello world
// {{ end }}
// ```
struct ElseStmt {
	stmts []Stmt
}

// ForStmt is a for statement.
// Example:
// ```
// {{ for .names }}
// Hello {{ .name }}
// {{ end }}
// ```
struct ForStmt {
	expr  Expr
	stmts []Stmt
}

// EndStmt is an marker end statement.
// Example:
// ```
// {{ end }}
// ```
struct EndStmt {}

// BadStmt is a statement that is used for invalid or missing statements.
struct BadStmt {}

union Expr = RootSelector |
             &mut Selector |
             Dot |
             &mut PipeCall |
             Ident |
             Var |
             &mut BinExpr |
             Lit |
             BadExpr

fn (e Expr) pos() -> token.Pos {
	return match e {
		RootSelector => e.ident.pos
		&mut Selector => e.expr.pos().union_with(e.ident.pos)
		Dot => e.pos
		&mut PipeCall => e.expr.pos().union_with(e.name.pos)
		Ident => e.pos
		Var => e.pos
		&mut BinExpr => e.left.pos().union_with(e.right.pos())
		Lit => e.pos
		BadExpr => token.Pos{}
	}
}

// RootSelector is a selector expression that starts with a dot.
// Example:
// ```
// {{ .name }}
// ```
struct RootSelector {
	ident Ident
}

// Selector is a selector expression.
// Example:
// ```
// {{ .name.first }}
// ```
struct Selector {
	expr  Expr
	ident Ident
}

// Dot is a dot expression.
// Example:
// ```
// {{ . }}
// ```
struct Dot {
	pos token.Pos
}

// PipeCall is a pipe function call expression.
// Example:
// ```
// {{ .name | upper | reverse }}
// ```
// The first argument is the expression that will be piped into the function.
// The second argument is the function that will be called.
struct PipeCall {
	expr Expr
	name Ident
}

// Ident is an identifier expression.
// Example:
// ```
// {{ name }}
// ```
struct Ident {
	ident string
	pos   token.Pos
}

// Var is a variable reference expression.
// Example:
// ```
// {{ $name }}
// ```
struct Var {
	ident string
	pos   token.Pos
}

// BinExpr is a binary expression.
// Example:
// ```
// {{ 1 + 2 }}
// ```
struct BinExpr {
	left  Expr
	op    token.Token
	right Expr
}

// Lit is a literal expression.
// Example:
// ```
// {{ "hello" }}
// {{ 1 }}
// ```
struct Lit {
	lit string
	tok token.Token
	pos token.Pos
}

// BadExpr is an expression that is used for invalid or missing expressions.
struct BadExpr {}
