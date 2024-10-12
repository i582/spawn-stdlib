module pg

// This file contains mostly experimental code and is not yet ready for production use.

import strings
import reflection
import intrinsics

// select_as executes a query and returns the resulting rows as a typed struct.
// args are optional and can be used to pass query parameters.
//
// Example:
// ```
// struct User {
//    id   i32
//    name string
// }
//
// fn main() {
//    // db connection setup
//    // ...
//
//    users := db.select_as[User]('SELECT id, name FROM users').unwrap()
//    for user in users {
//       println(user)
//    }
// }
// ```
pub fn (db DB) select_as[T: reflection.Struct](query string, args ...Value) -> !TypedRows[T] {
	res := db.exec_impl(query, ...args)!
	db.handle_error(res, 'select')!
	return TypedRows[T]{
		rows: PQntuples(res)
		res: res
	}
}

pub fn (db DB) insert[T: reflection.Struct](val T) -> ! {
	mut table := ""

	comptime if attr := type_info[T]().attr("table") {
		table = attr.args[0].remove_surrounding('"', '"')
	} $else {
		intrinsics.compiler_error('struct must have a `table` attribute to be used with `insert` method')
	}

	if table.len == 0 {
		return error("table name must not be empty")
	}

	mut fields := []string{}
	comptime for field in T.fields {
		fields.push(field.name)
	}

	mut values := []Value{}
	comptime for field in T.fields {
		comptime if field.typ is i32 {
			values.push(val.$(field.name) as i32 as Value)
		}

		comptime if field.typ is f64 {
			values.push(val.$(field.name) as f64 as Value)
		}

		comptime if field.typ is string {
			values.push(val.$(field.name) as string as Value)
		}

		comptime if field.typ is bool {
			values.push(val.$(field.name) as bool as Value)
		}

		comptime if field.typ is []u8 {
			values.push(val.$(field.name) as []u8 as Value)
		}
	}

	mut query_sb := strings.new_builder(100)
	query_sb.write_str('INSERT INTO ${table} (')
	query_sb.write_str(fields.join(', '))
	query_sb.write_str(') VALUES (')
	for i in 0 .. values.len {
		query_sb.write_str('$${i + 1}')
		if i < values.len - 1 {
			query_sb.write_str(', ')
		}
	}
	query_sb.write_str(')')

	query := query_sb.str_view()

	res := db.exec_impl(query, ...values)!
	db.handle_error(res, 'insert')!
}

pub struct TypedRows[T: reflection.Struct] {
	rows i32
	res  *PGresult

	last_idx  i32
	last_cols []?string
}

pub fn (r &mut TypedRows[T]) close() {
	PQclear(r.res)
}

pub fn (r &mut TypedRows[T]) column_name(index i32) -> string {
	return string.view_from_c_str(PQfname(r.res, index))
}

pub fn (r &mut TypedRows[T]) columns() -> []?string {
	return r.last_cols
}

pub fn (r &mut TypedRows[T]) get() -> T {
	count_cols := PQnfields(r.res)
	mut col_names := []string{cap: count_cols}
	for i in 0 .. count_cols {
		col_names.push(r.column_name(i))
	}

	mut res := T{}

	for i, col in col_names {
		comptime for field in T.fields {
			if field.name == col {
				last_col := r.last_cols[i] or { continue }
				comptime if field.typ is i32 {
					res.$(field.name) = last_col.i32()
				}

				comptime if field.typ is f64 {
					res.$(field.name) = last_col.f64()
				}

				comptime if field.typ is string {
					res.$(field.name) = last_col
				}

				comptime if field.typ is bool {
					res.$(field.name) = last_col.bool()
				}

				comptime if field.typ is []u8 {
					res.$(field.name) = last_col.bytes()
				}
			}
		}
	}

	return res
}

pub fn (r &mut TypedRows[T]) next() -> ?T {
	if !r.next_row() {
		return none
	}

	return r.get()
}

pub fn (r &mut TypedRows[T]) next_row() -> bool {
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
