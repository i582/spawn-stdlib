module builtin

// println is a built-in function that prints arguments to the standard output.
// It accepts any number of arguments of any type and prints them in order,
// separated by spaces, followed by a newline character.
pub fn println(s ...any)

// print is a built-in function that prints arguments to the standard output.
// It accepts any number of arguments of any type and prints them in order,
// separated by spaces.
pub fn print(s ...any)

// eprintln is a built-in function that prints arguments to the standard error.
// It accepts any number of arguments of any type and prints them in order,
// separated by spaces, followed by a newline character.
pub fn eprintln(s ...any)

// eprint is a built-in function that prints arguments to the standard error.
// It accepts any number of arguments of any type and prints them in order,
// separated by spaces.
pub fn eprint(s ...any)

// todo is a special placeholder function to mark unfinished code.
// It panics with a message 'TODO: s'.
//
// Example:
// ```
// fn foo() {
//     todo('not implemented')
// }
// ```
#[track_caller]
pub fn todo(s string) -> never {
	panic('TODO: ${s}')
}

// unreachable is used to indicate that a certain point in the program is not reachable.
// If program execution reaches this point, the program will panic.
#[cold]
#[no_inline]
#[track_caller]
pub fn unreachable() -> never {
	panic('unreachable')
}
