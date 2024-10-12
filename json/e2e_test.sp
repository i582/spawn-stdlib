module main

import json

struct CodeActionParams {
	#[json("textDocument")]
	text_document TextDocumentIdentifier
	range         Range_
	context       CodeActionContext
}

pub struct CodeActionContext {
	diagnostics []Diagnostic
	only        []CodeActionKind

	#[json("triggerKind")]
	trigger_kind CodeActionTriggerKind
}

pub enum CodeActionTriggerKind {
	invoked
	automatic
}

pub enum DiagnosticSeverity {
	error = 1
	warning
	information
	hint
}

pub enum DiagnosticTag {
	unnecessary = 1
	deprecated
}

pub struct Diagnostic {
	range    Range_
	severity DiagnosticSeverity
	code     string

	#[json("codeDescription")]
	code_description string
	source           string
	message          string
	tags             []DiagnosticTag

	#[json("relatedInformation")]
	related_information []DiagnosticRelatedInformation
	data                string
}

pub struct DiagnosticRelatedInformation {
	location Location_
	message  string
}

pub struct Location_ {
	uri   DocumentUri
	range Range_
}

struct TextDocumentIdentifier {
	uri MyDocumentUri
}

pub struct Position {
	line      i32
	character i32
}

pub struct Range_ {
	start Position
	end   Position
}

pub type CodeActionKind = string

type MyDocumentUri = string

test "decode real world JSON LSP message" {
	params := '
    {
        "textDocument": {
            "uri": "file:///path/to/file"
        },
        "range": {
            "start": {
                "line": 1,
                "character": 2
            },
            "end": {
                "line": 3,
                "character": 4
            }
        },
        "context": {
            "diagnostics": [
                {
                    "range": {
                        "start": {
                            "line": 5,
                            "character": 6
                        },
                        "end": {
                            "line": 7,
                            "character": 8
                        }
                    },
                    "severity": 1,
                    "code": "code",
                    "codeDescription": "codeDescription",
                    "source": "source",
                    "message": "message",
                    "tags": [1, 2],
                    "relatedInformation": [
                        {
                            "location": {
                                "uri": "file:///path/to/file",
                                "range": {
                                    "start": {
                                        "line": 9,
                                        "character": 10
                                    },
                                    "end": {
                                        "line": 11,
                                        "character": 12
                                    }
                                }
                            },
                            "message": "message"
                        }
                    ],
                    "data": "data"
                }
            ],
            "only": ["only"],
            "triggerKind": 1
        }
    }
    '

	p := json.decode[CodeActionParams](params).unwrap()

	t.assert_eq(p.text_document.uri, "file:///path/to/file", "values should match")
	t.assert_eq(p.range.start.line, 1, "values should match")
	t.assert_eq(p.range.start.character, 2, "values should match")
	t.assert_eq(p.range.end.line, 3, "values should match")
	t.assert_eq(p.range.end.character, 4, "values should match")

	t.assert_eq(p.context.diagnostics[0].range.start.line, 5, "values should match")
	t.assert_eq(p.context.diagnostics[0].range.start.character, 6, "values should match")
	t.assert_eq(p.context.diagnostics[0].range.end.line, 7, "values should match")
	t.assert_eq(p.context.diagnostics[0].range.end.character, 8, "values should match")
	t.assert_eq(p.context.diagnostics[0].severity, DiagnosticSeverity.error, "values should match")
	t.assert_eq(p.context.diagnostics[0].code, "code", "values should match")
	t.assert_eq(p.context.diagnostics[0].code_description, "codeDescription", "values should match")
	t.assert_eq(p.context.diagnostics[0].source, "source", "values should match")
	t.assert_eq(p.context.diagnostics[0].message, "message", "values should match")
	t.assert_eq(p.context.diagnostics[0].tags[0], DiagnosticTag.unnecessary, "values should match")
	t.assert_eq(p.context.diagnostics[0].tags[1], DiagnosticTag.deprecated, "values should match")
	t.assert_eq(p.context.diagnostics[0].related_information[0].location.uri, "file:///path/to/file", "values should match")
	t.assert_eq(p.context.diagnostics[0].related_information[0].location.range.start.line, 9, "values should match")
	t.assert_eq(p.context.diagnostics[0].related_information[0].location.range.start.character, 10, "values should match")
	t.assert_eq(p.context.diagnostics[0].related_information[0].location.range.end.line, 11, "values should match")
	t.assert_eq(p.context.diagnostics[0].related_information[0].location.range.end.character, 12, "values should match")
	t.assert_eq(p.context.diagnostics[0].related_information[0].message, "message", "values should match")
	t.assert_eq(p.context.diagnostics[0].data, "data", "values should match")
	t.assert_eq(p.context.only[0], "only", "values should match")
	t.assert_eq(p.context.trigger_kind, CodeActionTriggerKind.automatic, "values should match")
}

test "encode JSON LSP message" {
	p := CodeActionParams{
		text_document: TextDocumentIdentifier{ uri: "file:///path/to/file" }
		range: Range_{ start: Position{ line: 1, character: 2 }, end: Position{ line: 3, character: 4 } }
		context: CodeActionContext{
			diagnostics: [
				Diagnostic{
					range: Range_{ start: Position{ line: 5, character: 6 }, end: Position{ line: 7, character: 8 } }
					severity: DiagnosticSeverity.error
					code: "code"
					code_description: "codeDescription"
					source: "source"
					message: "message"
					tags: [DiagnosticTag.unnecessary, DiagnosticTag.deprecated]
					related_information: [
						DiagnosticRelatedInformation{
							location: Location_{ uri: "file:///path/to/file", range: Range_{ start: Position{ line: 9, character: 10 }, end: Position{ line: 11, character: 12 } } }
							message: "message"
						},
					]
					data: "data"
				},
			]
			only: ["only" as CodeActionKind]
			trigger_kind: CodeActionTriggerKind.automatic
		}
	}

	s := json.encode(p)
	t.assert_eq(s, '{"textDocument":{"uri":"file:///path/to/file"},"range":{"start":{"line":1,"character":2},"end":{"line":3,"character":4}},"context":{"diagnostics":[{"range":{"start":{"line":5,"character":6},"end":{"line":7,"character":8}},"severity":1,"code":"code","codeDescription":"codeDescription","source":"source","message":"message","tags":[1,2],"relatedInformation":[{"location":{"uri":"file:///path/to/file","range":{"start":{"line":9,"character":10},"end":{"line":11,"character":12}}},"message":"message"}],"data":"data"}],"only":["only"],"triggerKind":1}}', "values should match")

	p2 := json.decode[CodeActionParams](s).unwrap()
	t.assert_eq[string](p2.str(), p.str(), "values should match")
}
