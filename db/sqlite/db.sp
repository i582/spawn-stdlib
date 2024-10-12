module sqlite

pub struct Db {
	conn *sqlite3
}

// exec executes a query and returns the result.
// The result is a list of rows, each row is a list of values.
// The values are strings.
pub fn (db Db) exec(query string) -> ![Rows, SqlError] {
	mut stmt := nil as *sqlite3_stmt
	defer sqlite3_finalize(stmt)

	code := sqlite3_prepare_v2(db.conn, query.data, query.len as i32, &mut stmt, nil)
	if code != 0 {
		return error(db.last_error(code))
	}

	cols_count := sqlite3_column_count(stmt)
	mut rows := []Row{}
	for {
		step_code := sqlite3_step(stmt)
		if step_code != 100 {
			break
		}

		mut row := Row{}
		for i in 0 .. cols_count {
			col := sqlite3_column_text(stmt, i)
			row.vals.push(string.from_c_str(col))
		}
		rows.push(row)
	}

	return Rows{ rows: rows }
}

pub fn (db Db) close() -> ![bool, SqlError] {
	code := sqlite3_close(db.conn)
	if code != 0 {
		return error(db.last_error(code))
	}

	return true
}

pub fn (db Db) last_error(code i32) -> SqlError {
	return last_error(db.conn, code)
}

pub union Value = &mut i32 | &mut string

struct Row {
	vals []string
}

struct Rows {
	rows []Row

	cur i32 = -1
}

pub fn (r &mut Rows) next() -> bool {
	r.cur++
	return r.cur < r.rows.len
}

pub fn (r &Rows) scan(vals ...Value) {
	row := r.rows.get(r.cur) or { return }
	for i, val in vals {
		row_val := row.vals.get(i) or { break }

		if val is &mut i32 {
			*val = row_val.i32()
		} else {
			*val = row_val
		}
	}
}
