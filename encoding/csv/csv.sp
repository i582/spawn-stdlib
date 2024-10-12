module csv

import io
import bufio
import strings

// INVALID_DELIM is an error that occurs when a field or comment delimiter is invalid.
pub const INVALID_DELIM = "csv: invalid field or comment delimiter"

// Record describes one record from a CSV file.
pub struct Record {
	values []string
}

// get gets the value of the field by index.
pub fn (r &Record) get(index usize) -> ?string {
	return r.values.get(index)
}

// as_array returns an array of strings that contains all the fields of a given record.
pub fn (r &Record) as_array() -> []string {
	return r.values
}

// RecordView describes view to one record from a CSV file.
//
// You must not store an instance of this structure outside the loop!
// See [`ReaderViewIterator`] documentation for more information.
pub struct RecordView {
	values []string
}

// get gets the value of the field by index.
//
// This method returns a string that is valid even after the next
// call to [`Reader.read_record`] or next iteration of [`ReaderViewIterator`].
//
// See also [`get_view`] to get value without allocation.
pub fn (r &RecordView) get(index usize) -> ?string {
	return r.values.get(index)?.clone()
}

// get_view gets the value of the field by index.
//
// This method returns a string that will be no longer valid after
// the next call to [`Reader.read_record`] or next iteration of [`ReaderViewIterator`].
//
// If you want to store a string outside the loop, use [`get`].
pub fn (r &RecordView) get_view(index usize) -> ?string {
	return r.values.get(index)
}

// as_array returns an array of strings that contains all the fields of a given record.
//
// The returned array is always valid even after the next call to [`Reader.read_record`]
// or next iteration of [`ReaderViewIterator`].
pub fn (r &RecordView) as_array() -> []string {
	return r.values.copy()
}

// Reader reads records from a CSV-encoded file.
//
// As returned by [`Reader.new`], a [`Reader`] expects input conforming to RFC 4180.
// The public fields can be changed to customize the details before the
// first call to [`Reader.read_record`] or [`Reader.read_all`].
//
// The [`Reader`] converts all `\r\n` sequences in its input to plain `\n`,
// including in multiline field values, so that the returned data does
// not depend on which line-ending convention an input file uses.
//
// Example:
// ```
// import encoding.csv
//
// fn main() {
//     mut r := csv.Reader.from_string("  name;  age\n1;2")
//     r.comma = b`;`
//     r.trim_leading_space = true
//     record := r.read_record().unwrap()
//     assert record.as_array() == ["name", "age"]
// }
// ```
pub struct Reader {
	// comma is the field delimiter.
	// It is set to comma (`,`) by default.
	//
	// [`comma`] must not be `\r` or `\n`.
	comma u8 = b`,`

	// comment, if not 0, is the comment character.
	//
	// Lines beginning with the [`comment`] character without preceding whitespace
	// are ignored.
	// With leading whitespace the [`comment`] character becomes part of the
	// field, even if [`trim_leading_space`] is true.
	//
	// Comment must must not be `\r`, `\n`, or be equal to [`comma`].
	comment u8

	// fields_per_record is the number of expected fields per record.
	//
	// If [`fields_per_record`] is positive, [`read_record`] requires each record to
	// have the given number of fields. If [`fields_per_record`] is 0, [`read_record`]
	// sets it to the number of fields in the first record, so that future records must
	// have the same field count. If [`fields_per_record`] is negative, no check is
	// made and records may have a variable number of fields.
	fields_per_record i32

	// trim_leading_space when trie, leading white space in a field is ignored.
	// This is done even if the field delimiter, [`comma`], is white space.
	trim_leading_space bool

	// check_quotes_in_field controls whether [`read_record`] will check each field for
	// quotes within the value.
	//
	// If you are sure your data is correct, set the value to false.
	//
	// Setting this flag to false can give a speedup of about 30%.
	check_quotes_in_field bool = false

	// r is base reader
	r &mut bufio.Reader

	// num_line is the current line being read in the CSV file.
	num_line i32

	// raw_buffer is a line buffer only used by the read_line method to
	// handle lines with length greater than reader capacity.
	raw_buffer []u8

	// record_buffer holds the unescaped fields, one after another.
	//
	// The fields can be accessed by using the indexes in [`field_indexes`].
	//
	// For example:
	// For the row `a,"b","c""d",e`, [`record_buffer`] will contain `abc"de`
	// and [`field_indexes`] will contain the indexes `[1, 2, 5, 6]`.
	record_buffer []u8

	// field_indexes is an index of fields inside [`record_buffer`].
	// The `i`'th field ends at offset [`field_indexes`]`[i]` in [`record_buffer`].
	field_indexes []usize

	// field_positions is an index of field positions for the
	// last record returned by [`read_all`].
	field_positions []Position

	// last_record is a record cache only used when [`reuse_record`] is true.
	last_record Record
}

// new returns a new [`Reader`] that expects input conforming to RFC 4180.
//
// By default, [`Reader`] will use a comma (`,`) as the field separator.
// To change this, set the [`Reader.comma`] field before calling any read functions.
//
// To read from string, use [`Reader.from_string`] method.
//
// Example:
// ```
// import encoding.csv
// import strings
//
// fn main() {
//     reader := strings.Reader.new("name;age\n1;2")
//     mut r := csv.Reader.new(reader)
//     r.comma = b`;`
//     record := r.read_record().unwrap()
//     assert record.as_array() == ["name", "age"]
// }
// ```
pub fn Reader.new(r io.Reader) -> Reader {
	return Reader{ r: bufio.Reader.new(r) }
}

// new_sized returns a new [`Reader`] that expects input conforming to RFC 4180
// with passed capacity.
//
// By default, files are read in 4kb chunks, setting this value to 64kb, for example,
// can give a slight speedup (~5%).
//
// By default, [`Reader`] will use a comma (`,`) as the field separator.
// To change this, set the [`Reader.comma`] field before calling any read functions.
//
// To read from string, use [`Reader.from_string`] method.
//
// Example:
// ```
// import fs
// import encoding.csv
//
// fn main() {
//     file := fs.open_file("huge_file.csv", 'r').unwrap()
//     mut r := csv.Reader.new_sized(file, 64 * 1024)
//     record := r.read_record().unwrap()
//     println(record)
// }
// ```
pub fn Reader.new_sized(r io.Reader, size i32) -> Reader {
	return Reader{ r: bufio.Reader.new_sized(r, size) }
}

// from_string returns a new [`Reader`] that expects input conforming to RFC 4180
// and read input from string.
//
// By default, [`Reader`] will use a comma (`,`) as the field separator.
// To change this, set the [`Reader.comma`] field before calling any read functions.
//
// To read from any [`io.Reader`], use [`Reader.new`] method.
//
// Example:
// ```
// import encoding.csv
//
// fn main() {
//     mut r := csv.Reader.from_string("  name;  age\n1;2")
//     r.comma = b`;`
//     r.trim_leading_space = true
//     record := r.read_record().unwrap()
//     assert record.as_array() == ["name", "age"]
// }
// ```
pub fn Reader.from_string(s string) -> Reader {
	r := strings.Reader.new(s)
	return Reader{ r: bufio.Reader.new(r) }
}

// read_all reads all the remaining records from [`r`].
// Each record is array of strings.
//
// If all records are read successfully, an array of arrays
// containing one record per outer array element is returned.
//
// If any record is invalid, [`read_all`] returns an error as
// described in [`read_record`].
//
// This function will never return [`io.Eof`] since this error
// is considered as the end of records to read.
//
// Example:
// ```
// import encoding.csv
//
// fn main() {
//     mut r := csv.Reader.from_string("name,age\n1,2")
//     assert r.read_all().unwrap().map(|el| el.as_array()) == [["name", "age"], ["1", "2"]]
// }
// ```
pub fn (r &mut Reader) read_all() -> ![[]Record, Error] {
	mut records := []Record{}
	for {
		record := r.read_record() or {
			if err is io.Eof {
				break
			}
			return error(err)
		}

		records.push(record)
	}
	return records
}

// read_record reads one record as array of string from [`r`].
//
// If the record has an unexpected number of fields, [`read_record`] returns
// [`ParseError`] with [`CountFieldsError`], the read records can be retrieved
// via the [`ParseError.record`] field.
//
// If the record contains a field that cannot be parsed,
// [`read_record`] returns [`ParseError`] with [`ParseError.record`] containing
// a partial record. The partial record contains all fields read before the error.
//
// If there is no data left to be read, [`read_record`] returns [`io.EOF`] error.
//
// Example:
// ```
// import io
// import encoding.csv
//
// fn main() {
//     mut r := csv.Reader.from_string("name,age\n1,2")
//     assert r.read_record().unwrap().as_array() == ["name", "age"]
//     assert r.read_record().unwrap().as_array() == ["1", "2"]
//     assert r.read_record().unwrap_err() is io.Eof
// }
// ```
pub fn (r &mut Reader) read_record() -> ![Record, Error] {
	return r.read_record_impl(false)
}

fn (r &mut Reader) read_record_impl(as_view bool) -> ![Record, Error] {
	if r.comma == r.comment || !valid_delim(r.comma) || (r.comment != 0 && !valid_delim(r.comment)) {
		return error(INVALID_DELIM)
	}

	mut line := []u8{}

	for {
		line = r.read_line()!
		if r.comment != 0 && line.len > 0 && line[0] == r.comment {
			// skip comment lines
			line = []
			continue
		}
		if line.len == length_nl(line) {
			// skip empty lines
			continue
		}
		break
	}

	rec_line := r.num_line

	r.record_buffer.clear()
	r.field_indexes.clear()
	r.field_positions.clear()

	mut err := none as ?ParseError
	mut pos := Position{ line: rec_line, col: 1 }

	parse_field: for {
		if r.trim_leading_space {
			ident := string.view_from_bytes(line).ident_width()
			if ident > 0 {
				line = line[ident..]
				pos.col += ident
			}
		}

		if line.len == 0 || line.fast_get(0) != b`"` {
			// non-quoted string field
			i := line.index(r.comma)
			mut field := line
			if i != none {
				field = line[0..i]
			} else {
				field = field[0..field.len - length_nl(field)]
			}

			if r.check_quotes_in_field {
				// check to make sure a quote does not appear in field
				if j := line.index(b`"`) {
					err = ParseError{
						start_line: rec_line
						line: r.num_line
						col: pos.col + j
						err: BareQuoteError{}
					}
					break parse_field
				}
			}

			r.record_buffer.push_many(field)
			r.field_indexes.push(r.record_buffer.len)
			r.field_positions.push(pos)

			if i != none {
				line = line[i + 1..line.len]
				pos.col = pos.col + i + 1
				continue
			}

			break
		}

		// found entry with quotes
		field_pos := pos
		line = line[1..line.len]
		pos.col = pos.col + 1

		for {
			if i := line.index(b`"`) {
				r.record_buffer.push_many(line[0..i])
				line = line[i + 1..line.len]
				pos.col = pos.col + i + 1
				ch := line.fast_get(0)
				match {
					ch == b`"` => {
						// two quotes in row `""`, append quote
						r.record_buffer.push(b`"`)
						line = line[1..line.len]
						pos.col = pos.col + 1
					}
					ch == r.comma => {
						// `",` sequence, end of field
						line = line[1..]
						pos.col = pos.col + 1
						r.field_indexes.push(r.record_buffer.len)
						r.field_positions.push(field_pos)
						continue parse_field
					}
					length_nl(line) == line.len => {
						// `"\n` sequence, end of line
						r.field_indexes.push(r.record_buffer.len)
						r.field_positions.push(field_pos)
						break parse_field
					}
					else => {
						// " followed by other characters, invalid non escaped quote
						err = ParseError{
							start_line: rec_line
							line: r.num_line
							col: pos.col - 1
							err: QuoteError{}
						}
						break parse_field
					}
				}
			} else if line.len > 0 {
				// hit end of line, copy all data so far
				r.record_buffer.push_many(line)
				pos.col = pos.col + line.len as i32
				line = r.read_line() or {
					break parse_field
				}
				if line.len > 0 {
					pos.line++
					pos.col = 1
				}
			} else {
				r.field_indexes.push(r.record_buffer.len)
				r.field_positions.push(field_pos)
				break parse_field
			}
		}
	}

	mut dst := r.last_record.values
	if dst.cap < r.field_indexes.len {
		dst.ensure_cap(r.field_indexes.len)
	}
	dst.len = r.field_indexes.len
	dst = dst[..r.field_indexes.len]

	mut prev_idx := 0 as usize

	for i, idx in r.field_indexes {
		dst[i] = string.view_from_bytes(r.record_buffer[prev_idx..idx])
		if !as_view {
			dst[i] = dst[i].clone()
		}
		prev_idx = idx
	}

	if r.fields_per_record > 0 {
		if dst.len != r.fields_per_record {
			err = ParseError{
				start_line: rec_line
				line: rec_line
				col: 1
				err: CountFieldsError{ expected: r.fields_per_record, actual: dst.len as i32 }
			}
		}
	} else if r.fields_per_record == 0 {
		r.fields_per_record = dst.len as i32
	}

	if err != none {
		err.record = dst
		return error(err)
	}

	return Record{ values: dst }
}

// iter returns an iterator that yields all records.
//
// Note that this iterator makes extra copies to ensure that all data is valid
// even after the next iteration, this imposes some overhead that may be excessive
// in some tasks.
//
// See [`iter_view`] for an iterator that does not make additional copies and can
// work up to 2x faster on huge files.
//
// Example:
// ```
// import io
// import encoding.csv
//
// fn main() {
//     mut r := csv.Reader.from_string("name,age\n1,2")
//     for record in r.iter() {
//         println(record)
//     }
// }
// ```
pub fn (r &mut Reader) iter() -> ReaderIterator {
	return ReaderIterator{ r: r }
}

// ReaderIterator is iterator over all records in [`Reader`].
//
// Example:
// ```
// import io
// import encoding.csv
//
// fn main() {
//     mut r := csv.Reader.from_string("name,age\n1,2")
//     for record in r.iter() {
//         println(record)
//     }
// }
// ```
pub struct ReaderIterator {
	r &mut Reader
}

// next returns the next record from the [`Reader`], or none if
// there are no more records.
pub fn (r &mut ReaderIterator) next() -> ?Record {
	return r.r.read_record_impl(false) or { return none }
}

// iter_view returns an iterator that yields all record views.
//
// Note that this iterator does not return values, but only views, which means
// that after the next iteration, the data will be changed to new ones. In essence,
// this means that the values obtained from this iterator should not be saved outside
// the iteration loop.
//
// By following this simple rule, using this iterator can give a speedup of 2x on huge files.
//
// Example:
// ```
// import io
// import encoding.csv
//
// fn main() {
//     mut r := csv.Reader.from_string("name,age\n1,2")
//     for record in r.iter_view() {
//         println(record)
//     }
// }
// ```
//
// Example of what not to do:
// ```
// import io
// import encoding.csv
//
// fn main() {
//     mut r := csv.Reader.from_string("name,age\n1,2")
//     mut last_record := csv.Record{}
//     for record in r.iter_view() {
//         // DON"T DO THIS
//         last_record = record
//     }
// }
// ```
//
// If you want to save the data from this record, call the [`Record.as_array`] method,
// which will return a new array that can be safely assigned to a variable outside the
// loop.
//
// ```
// import io
// import encoding.csv
//
// fn main() {
//     mut r := csv.Reader.from_string("name,age\n1,2")
//     mut last_record := []string{}
//     for record in r.iter_view() {
//         last_record = record.as_array() // ok
//     }
// }
// ```
//
// See [`Record.get`] and [`Record.get_view`] for more information.
pub fn (r &mut Reader) iter_view() -> ReaderViewIterator {
	return ReaderViewIterator{ r: r }
}

// ReaderViewIterator is iterator over all views of records in [`Reader`].
//
// Example:
// ```
// import io
// import encoding.csv
//
// fn main() {
//     mut r := csv.Reader.from_string("name,age\n1,2")
//     for record in r.iter_view() {
//         println(record)
//     }
// }
// ```
pub struct ReaderViewIterator {
	r &mut Reader
}

// next returns the next view to record from the [`Reader`], or none if
// there are no more records.
pub fn (r &mut ReaderViewIterator) next() -> ?RecordView {
	rec := r.r.read_record_impl(true) or { return none }
	r.r.last_record = rec
	return RecordView{ values: rec.values }
}

fn (r &mut Reader) read_line() -> ![]u8 {
	mut line := r.r.read_slice(b`\n`) or {
		if err is bufio.BufferEofError {
			// read all data, return readed
			err.line
		} else if err is bufio.BufferFullError {
			// line is too long to read it all, so read it in parts
			r.read_line_parts(err.line)!
		} else {
			// unexpected error
			return error(err)
		}
	}

	if line.len == 0 {
		return error(io.EOF)
	}

	r.num_line++

	len := line.len
	if len > 2 && line[len - 2] == b`\r` && line[len - 1] == b`\n` {
		line[len - 2] = b`\n`
		line = line[..len - 1]
	}

	return line
}

// read_line_parts reads the entire line into an internal buffer in parts,
// since the line is too large to read it all into the buffered reader.
//
// This code is essentially the same as [`bufio.collect_fragments`], but is
// extracted here to reuse internal reader buffer of this reader.
fn (r &mut Reader) read_line_parts(first_line []u8) -> ![]u8 {
	r.raw_buffer.clear()
	r.raw_buffer.push_many(first_line)
	for {
		frag := r.r.read_slice(b`\n`) or {
			if err !is bufio.BufferFullError && err !is bufio.BufferEofError {
				// unexpected error
				return error(err)
			}

			line := if err is bufio.BufferEofError { err.line } else if err is bufio.BufferFullError { err.line } else { []u8{} }

			r.raw_buffer.push_many(line)
			// continue to read next fragment
			continue
		}

		// got final fragment
		r.raw_buffer.push_many(frag)
		break
	}

	return r.raw_buffer
}

fn valid_delim(d u8) -> bool {
	return d != 0 && d != `"` && d != `\r` && d != `\n`
}

fn length_nl(b []u8) -> usize {
	if b.len > 0 && b.last() == b`\n` {
		return 1
	}
	return 0
}

struct Position {
	line usize
	col  usize
}

// ParseError is returned for parsing errors.
// Line and column numbers are 1-indexed.
pub struct ParseError {
	// start_line is a line where the record starts
	start_line i32
	// line is a line where the error occurred
	line i32
	// col is a column (1-based byte index) where the error occurred
	col usize
	// record are all fields read before this error
	record []string
	// err is actual error
	err ParseErrorInner
}

// msg return message for this parse error.
pub fn (p ParseError) msg() -> string {
	if p.err is CountFieldsError {
		return "record on line ${p.line}: ${p.err.msg()}"
	}

	if p.start_line != p.line {
		return "record on line ${p.start_line}, parse error on line ${p.line}, column ${p.col}: ${p.err.msg()}"
	}

	return "record on line ${p.start_line}, column ${p.col}: ${p.err.msg()}"
}

// ParseErrorInner represents all possible variants of parse error.
pub union ParseErrorInner = QuoteError | BareQuoteError | CountFieldsError

// msg returns message for this error.
pub fn (p ParseErrorInner) msg() -> string {
	return match p {
		QuoteError => p.msg()
		BareQuoteError => p.msg()
		CountFieldsError => p.msg()
	}
}

// QuoteError returns when there is extraneous or missing " in quoted-field.
pub struct QuoteError {}

// msg returns message for this error.
pub fn (_ QuoteError) msg() -> string {
	return 'extraneous or missing " in quoted-field'
}

// BareQuoteError returns when there is bare " in non-quoted-field.
pub struct BareQuoteError {}

// msg returns message for this error.
pub fn (_ BareQuoteError) msg() -> string {
	return 'bare " in non-quoted-field'
}

// CountFieldsError returns when there is wrong number of fields in record.
pub struct CountFieldsError {
	expected i32
	actual   i32
}

// msg returns message for this error.
pub fn (e CountFieldsError) msg() -> string {
	return 'wrong number of fields, expected ${e.expected}, actual: ${e.actual}'
}
