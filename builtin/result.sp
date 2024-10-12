module builtin

// Error is a base interface for all error types.
// It provides a single required method [`msg`] that returns a string
// representation of the error.
//
// By default, [`Result`] types such as `!i32` use the [`Error`] interface
// to represent errors.
// Any type that implements [`Error`] can be used as an error type.
//
// [`source`] method is used to return the lower-level error that caused
// this error, see the method documentation for more information.
pub interface Error {
	// msg returns a string representation of the error.
	// Usually it contains a human-readable description of the error and
	// used to display error messages to the user.
	fn msg(self) -> string

	// source returns the lower-level error that caused this error, if any.
	//
	// For example, if your API needs to open some file, and the file is not found,
	// you may want to return own error type `ApiNotFound` and in this method return
	// the underlying FS error that returned by the system.
	//
	// Example:
	// ```
	// struct ApiNotFound {
	//     endpoint string
	//     source   fs.FsError
	// }
	//
	// fn (e ApiNotFound) msg() -> string {
	//     return '${e.endpoint}: file not found'
	// }
	//
	// fn (e ApiNotFound) source() -> ?fs.FsError {
	//     return e.source
	// }
	//
	// fn do_something() -> ![ApiNotFound] {}
	//
	// fn main() {
	//    do_something() or {
	//        err_num := err.source().unwrap().num
	//        // do something with data from the source error
	//    }
	// }
	// ```
	fn source(self) -> ?Error {
		return none
	}
}

// Result is a type that represents either Data or [Error].
//
// Result is used for error handling in Spawn, usually it is used as a return
// type of functions that may fail. Returned error can be handled by the caller
// with `or {}` block or propagated up the call stack with `!` operator.
//
// Spawn uses special syntax for Result types:
// - `!T` is a shorthand for `Result[T, Error]`
// - `![T, E]` is a shorthand for `Result[T, E]`
// - `![E]` is a shorthand for `Result[unit, E]`
// - `!` is a shorthand for `Result[unit, Error]`
//
// Example:
// ```
// import fs
//
// fn do_something() -> !i32 {
//     //               ^ this function returns Result type since it can fail
//
//     // read_file can fail, so it returns Result type
//     fs.read_file("file.txt") or {
//         panic('failed to read file: ${err.msg()}')
//     }
//     // or
//     fs.read_file("file2.txt")!
// }
// ```
//
// ## Handling errors
//
// Main way to handle errors in Spawn is to use `or {}` block. This block runs
// if the [`Result`] contains an error. Inside the block, you can handle the error
// and return from the function or do some cleanup. You can also return default
// value from the block.
//
// Example:
// ```
// import fs
//
// fn do_something() -> !string {
//     data := fs.read_file("a.txt") or { "default data" }
//     // ... do something with data
//     return data
// }
// ```
//
// Each `or {}` block defines an implicit variable `err` that contains the error
// from the [`Result`]. You can use this variable to get the error message or other
// error properties.
//
// Example:
// ```
// import fs
//
// fn do_something() -> !string {
//     data := fs.read_file("a.txt") or {
//         println('failed to read file: ${err.msg()}')
//         return error(err)
//     }
// }
// ```
//
// ## Propagating errors
//
// Write `or { return err }` is quite verbose, so Spawn provides a shorthand
// operator `!` that propagates the error up the call stack.
//
// Example:
// ```
// import fs
//
// fn do_something() -> !string {
//     data := fs.read_file("a.txt")!
//     // ... do something with data
//     return data
// }
// ```
// Is same as:
// ```
// import fs
//
// fn do_something() -> !string {
//     data := fs.read_file("a.txt") or { return err }
//     // ... do something with data
//     return data
// }
// ```
//
// ## `unwrap` and `expect` methods
//
// Result types is convinient for quick prototyping since it provides several
// helper methods to work with errors and data not as safe as using `or {}` block,
// but more concise.
//
// Usually, if error is quite unexpected you can use [`Result.unwrap`] method to
// get the data from the result. If `Result` contains an error, `unwrap` will panic
// with the default error message. To set a custom error message you can
// use [`Result.expect`] method.
//
// ```
// import fs
//
// fn main() {
//     data := fs.read_file("file.txt").unwrap()
//     //                               ^^^^^^^^ if we know that file exists,
//     //                                        we can use `unwrap` to get the
//     //                                        data from the Result
//     // ... do something with data
// }
// ```
//
// DON'T use `unwrap` in production code, always handle errors properly with `or {}` block
// or `!` operator.
//
// ## Constructing errors
//
// Main way to construct errors is to use [`error`] function. It creates a new `Result`
// with the error value.
//
// Example:
// ```
// fn do_something() -> !string {
//     return error('something went wrong')
// }
// ```
//
// This type should be implemented via union type to provide more ways
// to optimize the code.
pub struct Result[TData, TError: Error] {
	data     TData
	error    TError
	is_error bool
}

// is_ok returns true if the Result contains data.
pub fn (r Result[TData, TError]) is_ok() -> bool {
	return !r.is_error
}

// is_err returns true if the Result contains an error.
pub fn (r Result[TData, TError]) is_err() -> bool {
	return r.is_error
}

// ok returns an `Option` that contains the data if the Result
// contains data or `none` if the Result contains an error.
pub fn (r Result[TData, TError]) ok() -> ?TData {
	if r.is_error {
		return none
	}

	return r.data
}

// err returns an `Option` that contains the error if the Result
// contains an error or `none` if the Result contains data.
pub fn (r Result[TData, TError]) err() -> ?TError {
	if r.is_error {
		return r.error
	}

	return none
}

// unwrap returns the data from the Result or panics if the Result
// contains an error.
//
// Since this function may panic, it is not recommended to use it in
// production code. Use `or {}` block or `!` operator.
//
// This function panics if the Result contains an error. See [`Result.expect`]
// to set a custom panic message.
//
// Example:
// ```
// import fs
//
// fn main() {
//     data := fs.read_file("file.txt").unwrap()
//     // ... do something with data
// }
// ```
#[track_caller]
pub fn (r Result[TData, TError]) unwrap() -> TData {
	if r.is_error {
		panic('`Result.unwrap()` called on error `${r.error.msg()}`')
	}

	return r.data
}

// unwrap_err returns the error from the Result or panics if the Result
// contains data.
//
// Since this function may panic, it is not recommended to use it in
// production code. Use `or {}` block or `!` operator.
//
// This function panics if the Result contains data. See [`Result.expect_err`]
// to set a custom panic message.
#[track_caller]
pub fn (r Result[TData, TError]) unwrap_err() -> TError {
	if !r.is_error {
		panic('`Result.unwrap_err()` called on non-error')
	}

	return r.error
}

// unwrap_or returns the data from the Result or the default value if the Result
// contains an error.
//
// This method is similar to `or {}` block, but can be used in call chains more
// easily.
//
// Example:
//
// ```
// import fs
//
// fn main() {
//     data := fs.read_file("data.txt").
//         unwrap_or("1,2,3").
//         split(",").
//         map(|el| el.trim_spaces())
//     // ... do something with data
// }
// ```
pub fn (r Result[TData, TError]) unwrap_or(def TData) -> TData {
	if r.is_error {
		return def
	}

	return r.data
}

// expect returns the data from the Result or panics with a custom message
// if the Result contains an error.
//
// Since this function may panic, it is not recommended to use it in
// production code. Use `or {}` block or `!` operator.
//
// This function panics if the Result contains an error. See [`Result.unwrap`]
// to get the default panic message.
#[track_caller]
pub fn (r Result[TData, TError]) expect(msg string) -> TData {
	if r.is_error {
		panic(msg)
	}

	return r.data
}

// expect_err returns the error from the Result or panics with a custom message
// if the Result contains data.
//
// Since this function may panic, it is not recommended to use it in
// production code. Use `or {}` block or `!` operator.
//
// This function panics if the Result contains data. See [`Result.unwrap_err`]
// to get the default panic message.
#[track_caller]
pub fn (r Result[TData, TError]) expect_err(msg string) -> TError {
	if !r.is_error {
		panic(msg)
	}

	return r.error
}

// str returns a string representation of the Result.
//
// For example, if the Result contains data, it returns `Result(42)`
// and if the Result contains an error, it returns `Result(err: error message)`.
pub fn (r Result[TData, TError]) str() -> string
	where TData: Display
{
	if r.is_error {
		return 'Result(err: ${r.error.msg()})'
	}

	str := r.data.str()
	return 'Result(${str})'
}

// debug_str returns a debug string representation of the Result.
//
// For example, if the Result contains data, it returns `Result(42)`
// and if the Result contains an error, it returns `Result(err: error message)`.
pub fn (r Result[TData, TError]) debug_str() -> string
	where TData: Debug
{
	if r.is_error {
		return 'Result(err: ${r.error.msg()})'
	}

	str := r.data.debug_str()
	return 'Result(${str})'
}

// equal returns true if the Result is equal to the other Result.
//
// Result is equal if both Results are errors and their errors are equal
// or both Results are data and their data are equal.
pub fn (r Result[TData, TError]) equal(other Result[TData, TError]) -> bool
	where TData: Equality, 
          TError: Equality
{
	if r.is_error != other.is_error {
		return false
	}

	if r.is_error {
		return r.error.equal(other.error)
	}

	return r.data.equal(other.data)
}

// error returns a new Result with the error value.
//
// Usually `TData` type parameter is inferred from the context,
// for example when return result of this function.
//
// Example:
// ```
// fn make_request(req Req) -> !string {
//     if req.name == "POST" {
//         return error("POST request is not implemented yet")
//     }
//     return "Hello World!"
// }
// ```
pub fn error[TData, TError: Error](err TError) -> ![TData, TError] {
	return Result[TData, TError]{
		error: err
		is_error: true
	}
}

pub fn msg_err[TData](msg string) -> ![TData, Error] {
	return Result[TData, Error]{
		error: BaseError{ msg: msg } as Error
		is_error: true
	}
}

pub struct BaseError {
	msg string
}

pub fn (e BaseError) msg() -> string {
	return e.msg
}

pub fn BaseError.new[TData](msg string) -> ![TData, Error] {
	return Result[TData, Error]{
		error: BaseError{ msg: msg } as Error
		is_error: true
	}
}
