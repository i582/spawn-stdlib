module sqlite

// connect connects to a SQLite database.
pub fn connect(name string) -> ![Db, SqlError] {
	mut conn := nil as *sqlite3
	code := sqlite3_open_v2(name.c_str(), &mut conn, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, nil)
	if code != 0 {
		return error(last_error(conn, code))
	}

	if conn == nil {
		return error(last_error(conn, code))
	}

	return Db{ conn: conn }
}

// version return the version of SQLite.
pub fn version() -> string {
	return string.from_c_str(sqlite3_libversion())
}

// version_number return the version number of SQLite.
//
// For instance, the version `3.8.11.1` corresponds to the integer `3008011`.
pub fn version_number() -> usize {
	return sqlite3_libversion_number() as usize
}
