module sqlite

pub struct SqlError {
	code i32
	msg  string
}

pub fn last_error(db *sqlite3, code i32) -> SqlError {
	msg := sqlite3_errmsg(db)
	return SqlError{
		code: code
		msg: string.from_c_str(msg)
	}
}

pub fn (e SqlError) msg() -> string {
	return e.msg
}
