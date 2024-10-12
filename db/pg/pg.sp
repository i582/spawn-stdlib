module pg

// Value represents a value that can be passed as a query parameter.
union Value = string |
              i32 |
              f64 |
              bool |
              []u8

// bytes returns representation of the value as bytes.
pub fn (v Value) bytes() -> []u8 {
	return unsafe {
		match v {
			string => v.bytes_no_copy()
			i32 => v.str().bytes_no_copy()
			f64 => v.str().bytes_no_copy()
			bool => v.str().bytes_no_copy()
			[]u8 => v
		}
	}
}

// DB represents a connection to a PostgreSQL database.
pub struct DB {
	conn Conn
}

// close closes the database connection.
pub fn (db DB) close() {
	db.conn.close()
}

// exec executes a query without returning any rows.
// args are optional and can be used to pass query parameters.
//
// Use [`query`] to get rows from a query.
pub fn (db DB) exec(query string, args ...Value) -> ! {
	res := db.exec_impl(query, ...args)!
	db.handle_error(res, 'exec')!
}

// query executes a query and returns the resulting rows.
// args are optional and can be used to pass query parameters.
//
// Use [`exec`] to execute a query without returning any rows.
pub fn (db DB) query(query string, args ...Value) -> !Rows {
	res := db.exec_impl(query, ...args)!
	db.handle_error(res, 'query')!
	return Rows{
		rows: PQntuples(res)
		res: res
	}
}

fn (db DB) exec_impl(query string, args ...Value) -> !*PGresult {
	if args.len == 0 {
		// fast path, just execute the query
		res := PQexec(db.conn.inner, query.c_str())
		return res
	}

	args_bytes := args.map(|arg| arg.bytes().raw())
	start := args_bytes.raw() as *u8
	return PQexecParams(db.conn.inner, query.c_str(), args_bytes.len as i32, nil, start, nil, nil, 0)
}

fn (db DB) handle_error(res *PGresult, label string) -> ! {
	err := db.conn.last_error() or { return }
	PQclear(res)
	return error('PostgreSQL ${label} error: ${err}')
}

pub struct Rows {
	rows i32
	res  *PGresult

	last_idx  i32
	last_cols []?string
}

pub fn (r &mut Rows) close() {
	PQclear(r.res)
}

pub fn (r &mut Rows) column_name(index i32) -> string {
	return string.view_from_c_str(PQfname(r.res, index))
}

pub fn (r &mut Rows) columns() -> []?string {
	return r.last_cols
}

pub fn (r &mut Rows) fetch_all() -> []Row {
	return Rows.parse_result(r.res)
}

fn Rows.parse_result(res *PGresult) -> []Row {
	nr_rows := PQntuples(res)
	nr_cols := PQnfields(res)

	mut rows := []Row{}
	for i in 0 .. nr_rows {
		mut row := Row{}
		for j in 0 .. nr_cols {
			if PQgetisnull(res, i, j) != 0 {
				row.vals.push(none)
			} else {
				val := PQgetvalue(res, i, j)
				row.vals.push(string.view_from_c_str(val))
			}
		}
		rows.push(row)
	}

	PQclear(res)
	return rows
}

pub fn (r &mut Rows) next() -> bool {
	if r.last_idx >= r.rows {
		return false
	}

	r.last_cols = []
	for i in 0 .. PQnfields(r.res) {
		if PQgetisnull(r.res, r.last_idx, i) != 0 {
			r.last_cols.push(none)
		} else {
			val := PQgetvalue(r.res, r.last_idx, i)
			r.last_cols.push(string.view_from_c_str(val))
		}
	}

	r.last_idx++
	return true
}

pub struct Row {
	vals []?string
}

struct Conn {
	inner *PGconn
}

fn Conn.open(conninfo string) -> !Conn {
	conn := PQconnectdb(conninfo.c_str())
	if conn == nil {
		return error('Failed to connect to database')
	}

	status := PQstatus(conn)
	if status != CONNECTION_OK {
		msg := string.view_from_c_str(PQerrorMessage(conn)).clone()
		PQfinish(conn)
		return error('Failed to connect to database: ${msg}')
	}

	return Conn{ inner: conn }
}

fn (c Conn) last_error() -> ?string {
	e := string.view_from_c_str(PQerrorMessage(c.inner))
	if e == '' {
		return none
	}
	// remove trailing newline to make error messages nicer to output
	return e.trim_end('\n')
}

fn (c Conn) close() {
	PQfinish(c.inner)
}

pub struct Config {
	host     string = 'localhost'
	port     i32    = 5432
	user     string
	password string
	dbname   string
}

// as_conninfo returns the configuration as a connection string.
// The connection string can be used to connect to the database using
// [`connect_with_conninfo`].
pub fn (c Config) as_conninfo() -> string {
	return 'host=${c.host} port=${c.port} user=${c.user} dbname=${c.dbname} password=${c.password}'
}

// connect creates a new database connection.
//
// Use [`connect_with_conninfo`] to connect using a connection string.
//
// Example:
// ```
// fn main() {
//    db := pg.connect(pg.Config{ ... })
//    defer db.close()
//
//    // ...
// }
// ```
pub fn connect(config Config) -> !DB {
	return connect_with_conninfo(config.as_conninfo())
}

// connect_with_conninfo creates a new database connection using a connection string.
// The connection string should be in the format accepted by PostgreSQL.
//
// Use [`connect`] to connect using a configuration struct.
pub fn connect_with_conninfo(conninfo string) -> !DB {
	conn := Conn.open(conninfo)!
	return DB{ conn: conn }
}
