module pg

#[include("<libpq-fe.h>")]
#[include("<pg_config.h>")]
#[include_path_if(linux, "/usr/include/postgresql")]
#[include_path_if(darwin, "/opt/local/include/postgresql11")]
#[include_path_if(darwin, "/usr/local/opt/libpq/include")]
#[include_path_if(darwin, "/opt/homebrew/include")]
#[include_path_if(darwin, "/opt/homebrew/opt/libpq/include")]
#[library_path_if(darwin, "/opt/local/lib/postgresql11")]
#[library_path_if(darwin, "/usr/local/opt/libpq/lib")]
#[library_path_if(darwin, "/opt/homebrew/lib")]
#[library_path_if(darwin, "/opt/homebrew/opt/libpq/lib")]
#[include_path_if(freebsd, "/usr/local/include")]
#[library_path_if(freebsd, "/usr/local/lib")]
#[cflags_if(!windows, "-lpq")]
#[cflags_if(windows, "-llibpq")]

extern {
	pub const (
		CONNECTION_OK                = 0
		CONNECTION_BAD               = 0
		CONNECTION_STARTED           = 0 // Waiting for connection to be made.
		CONNECTION_MADE              = 0 // Connection OK; waiting to send.
		CONNECTION_AWAITING_RESPONSE = 0 // Waiting for a response from the postmaster.
		CONNECTION_AUTH_OK           = 0 // Received authentication; waiting for backend startup.
		CONNECTION_SETENV            = 0 // Negotiating environment.
		CONNECTION_SSL_STARTUP       = 0 // Negotiating SSL.
		CONNECTION_NEEDED            = 0 // i32ernal state: connect() needed . Available in PG 8
		CONNECTION_CHECK_WRITABLE    = 0 // Check if we could make a writable connection. Available since PG 10
		CONNECTION_CONSUME           = 0 // Wait for any pending message and consume them. Available since PG 10
		CONNECTION_GSS_STARTUP       = 0 // Negotiating GSSAPI; available since PG 12
	)

	pub const (
		PGRES_EMPTY_QUERY    = 0 // empty query string was executed
		PGRES_COMMAND_OK     = 0 // a query command that doesn't return anything was executed properly by the backend
		PGRES_TUPLES_OK      = 0 // a query command that returns tuples was executed properly by the backend, PGresult contains the result tuples
		PGRES_COPY_OUT       = 0 // Copy Out data transfer in progress
		PGRES_COPY_IN        = 0 // Copy In data transfer in progress
		PGRES_BAD_RESPONSE   = 0 // an unexpected response was recv'd from the backend
		PGRES_NONFATAL_ERROR = 0 // notice or warning message
		PGRES_FATAL_ERROR    = 0 // query failed
		PGRES_COPY_BOTH      = 0 // Copy In/Out data transfer in progress
		PGRES_SINGLE_TUPLE   = 0 // single tuple from larger resultset
	)

	pub struct PGresult {}
	pub struct PGconn {}

	fn PQconnectdb(conninfo *u8) -> *PGconn
	fn PQstatus(conn *PGconn) -> i32
	fn PQerrorMessage(conn *PGconn) -> *u8
	fn PQexec(res *PGconn, query *u8) -> *PGresult
	fn PQgetisnull(res *PGresult, _ i32, _ i32) -> i32
	fn PQgetvalue(res *PGresult, _ i32, _ i32) -> *u8
	fn PQresultStatus(res *PGresult) -> i32
	fn PQntuples(res *PGresult) -> i32
	fn PQnfields(res *PGresult) -> i32
	fn PQfname(res *PGresult, field_index i32) -> *u8
	fn PQexecParams(conn *PGconn, command *u8, nParams i32, paramTypes *i32, paramValues *u8, paramLengths *i32, paramFormats *i32, resultFormat i32) -> *PGresult
	fn PQputCopyData(conn *PGconn, buffer *u8, nbytes i32) -> i32
	fn PQputCopyEnd(conn *PGconn, errmsg *u8) -> i32
	fn PQgetCopyData(conn *PGconn, buffer **u8, async i32) -> i32
	fn PQclear(res *PGresult)
	fn PQfreemem(ptr *void)
	fn PQfinish(conn *PGconn)
}
