module bufio

import io
import mem
import utf8

// DEFAULT_BUFFER_SIZE is default capacity of [`Reader`] created with
// [`reader`] or [`Reader.new`] functions.
const DEFAULT_BUFFER_SIZE = 4096

const (
	MIN_READ_BUFFER_SIZE        = 16
	MAX_CONSECUTIVE_EMPTY_READS = 100
)

// BufferFullError represents an error when the buffer is too small
// to hold all the required data.
//
// [`line`] field contains whole buffer.
pub struct BufferFullError {
	line []u8
}

// msg returns stub error message.
fn (_ BufferFullError) msg() -> string {
	return "bufio: buffer full"
}

// BufferEofError represents an error when unrlying [`Reader`] returns [`io.Eof`].
// We need this wrapper to return to the user all the data read up to that point,
// to properly handle [`Reader.read_slice`] with `\n` for lines without trailing
// line breaks.
pub struct BufferEofError {
	line []u8
}

// msg returns stub error message.
fn (_ BufferEofError) msg() -> string {
	return "bufio: end of file"
}

// Reader struct adds buffering to any reader.
//
// It can be excessively inefficient to work directly with a [`io.Reader`] instance.
// For example, every call to [`net.TcpConn.read`] results in a system call.
// [`Reader`] performs large, infrequent reads on the underlying [`Reader`] and maintains
//  an in-memory buffer of the results.
//
// [`Reader`] can improve the speed of programs that make *small* and
// *repeated* read calls to the same file or network socket. It does not
// help when reading very large amounts at once, or reading just one or a few
// times.
//
// Example:
// ```
// import fs
// import bufio
//
// fn main() {
//     file := fs.open_file('main.sp', 'r').unwrap()
//     reader := bufio.reader(file)
//     line, is_prefix := reader.read_line().unwrap()
//     println('Length of first line is ${line.len}, is_prefix: ${is_prefix}')
// }
// ```
pub struct Reader {
	rd  io.Reader
	buf []u8
	r   i32
	w   i32
}

// new creates a new [`Reader`] with a default buffer capacity.
// The default is currently 4 KiB, but may change in the future.
//
// Example:
// ```
// import fs
// import bufio
//
// fn main() {
//     file := fs.open_file('main.sp', 'r').unwrap()
//     reader := bufio.Reader.new(file)
// }
// ```
pub fn Reader.new(rd io.Reader) -> &mut Reader {
	return Reader.new_sized(rd, DEFAULT_BUFFER_SIZE)
}

// new_sized creates a new [`Reader`] with the specified buffer capacity.
//
// Example:
// ```
// import fs
// import bufio
//
// fn main() {
//     file := fs.open_file('main.sp', 'r').unwrap()
//     reader := bufio.Reader.new_sized(file, 100)
// }
// ```
pub fn Reader.new_sized(rd io.Reader, size i32) -> &mut Reader {
	if rd is Reader && rd.buf.len > size {
		// rd is already `bufio.Reader` with a large buffer, so use it directly
		return rd
	}

	return &mut Reader{
		buf: []u8{len: size.max(MIN_READ_BUFFER_SIZE)}
		rd: rd
	}
}

// reader_sized creates a new [`Reader`] with the specified buffer capacity.
//
// Example:
// ```
// import fs
// import bufio
//
// fn main() {
//     file := fs.open_file('main.sp', 'r').unwrap()
//     reader := bufio.reader_sized(file, 100)
// }
// ```
pub fn reader_sized(rd io.Reader, size i32) -> &mut Reader {
	return Reader.new_sized(rd, size)
}

// reader creates a new [`Reader`] with a default buffer capacity.
// The default is currently 4 KiB, but may change in the future.
//
// Example:
// ```
// import fs
// import bufio
//
// fn main() {
//     file := fs.open_file('main.sp', 'r').unwrap()
//     reader := bufio.reader(file)
// }
// ```
pub fn reader(rd io.Reader) -> &mut Reader {
	return Reader.new_sized(rd, DEFAULT_BUFFER_SIZE)
}

// size returns the size of the underlying buffer in bytes.
//
// Example:
// ```
// import fs
// import bufio
//
// fn main() {
//     file := fs.open_file('main.sp', 'r').unwrap()
//     reader := bufio.reader(file)
//     assert reader.size() == 4096 // default alue
//
//     reader2 := bufio.reader_sized(file, 100)
//     assert reader2.size() == 100
// }
// ```
pub fn (b &Reader) size() -> usize {
	return b.buf.len
}

// buffered returns the number of bytes that can be read from the current buffer.
pub fn (b &Reader) buffered() -> usize {
	return b.w - b.r
}

// reset discards any buffered data, resets all state, and switches
// the buffered reader to read from [`rd`].
//
// Calling [`reset`] on the zero value of [`Reader`] initializes the
// internal buffer to the default size.
pub fn (b &mut Reader) reset(rd io.Reader) {
	if b.buf.len == 0 {
		b.buf = []u8{len: DEFAULT_BUFFER_SIZE}
	}
	b.reset_impl(b.buf, rd)
}

// fill reads a new chunk into the buffer.
fn (b &mut Reader) fill() -> ! {
	// Slide existing data to beginning.
	if b.r > 0 {
		copy(&mut b.buf, b.buf[b.r..b.w])
		b.w -= b.r
		b.r = 0
	}

	if b.w as usize >= b.buf.len {
		return error("bufio: tried to fill full buffer")
	}

	// Read new data: try a limited number of times.
	for i in 0 .. MAX_CONSECUTIVE_EMPTY_READS {
		mut slice := b.buf[b.w..]
		n := b.rd.read(&mut slice)!
		if n < 0 {
			return error("bufio: reader returned negative count from read")
		}
		b.w += n
		if n > 0 {
			return
		}
	}

	return error(io.ErrNoProgress{})
}

// read reads data into [`buf`] and returns the number of bytes read.
//
// The bytes are taken from at most one [`read`] on the underlying [`io.Reader`],
// hence number of bytes may be less than `buf.len`.
//
// If the underlying [`Reader`] can return a non-zero count with [`io.EOF`],
// then this [`read`] method can do so as well.
//
// Example:
// ```
// import fs
// import bufio
//
// fn main() {
//     file := fs.open_file('main.sp', 'r').unwrap()
//     reader := bufio.reader(file)
//
//     mut buf := []u8{len: 5}
//     read := reader.read(&mut buf).unwrap()
//     println(buf[..read].ascii_str())
// }
// ```
pub fn (b &mut Reader) read(buf &mut []u8) -> !i32 {
	if buf.len == 0 {
		return 0
	}

	if b.r == b.w {
		if buf.len >= b.buf.len {
			// Large read, empty buffer.
			// Read directly into buf to avoid copy.
			n := b.rd.read(buf)!
			if n < 0 {
				return error("bufio: reader returned negative count from read")
			}
			return n
		}

		// One read.
		// Do not use b.fill, which will loop.
		b.r = 0
		b.w = 0
		n := b.rd.read(&mut b.buf)!
		if n < 0 {
			return error("bufio: reader returned negative count from read")
		}
		if n == 0 {
			return 0
		}
		b.w += n
	}

	// copy as much as we can
	copied := copy(buf, b.buf[b.r..b.w])
	b.r += copied
	return copied
}

// read_byte reads and returns a single byte or an error if the byte
// cannot be read.
//
// Example:
// ```
// import fs
// import bufio
//
// fn main() {
//     file := fs.open_file('main.sp', 'r').unwrap()
//     reader := bufio.reader(file)
//
//     b := reader.read_byte().unwrap()
//     println(b.ascii_str())
// }
// ```
pub fn (b &mut Reader) read_byte() -> !u8 {
	for b.r == b.w {
		b.fill()! // buffer is empty
	}
	c := b.buf.fast_get(b.r)
	b.r++
	return c
}

// read_rune reads a single UTF-8 encoded Unicode character and
// returns the rune and its size in bytes.
// If the encoded rune is invalid, it consumes one byte
// and returns unicode ReplacementChar (U+FFFD) with a size of 1.
//
// Example:
// ```
// import fs
// import bufio
//
// fn main() {
//     file := fs.open_file('main.sp', 'r').unwrap()
//     reader := bufio.reader(file)
//
//     r, size := reader.read_rune().unwrap()
//     println(r.str(), size)
// }
// ```
pub fn (b &mut Reader) read_rune() -> !(rune, usize) {
	for b.r + utf8.UTF8_MAX > b.w && !utf8.full_rune(b.buf[b.r..b.w]) && b.w - b.r < b.buf.len {
		b.fill()! // b.w-b.r < len(buf) => buffer is not full
	}
	if b.r == b.w {
		return error(io.EOF)
	}

	mut r := b.buf[b.r] as rune
	mut size := 1
	if r >= utf8.RUNE_SELF {
		r, size = utf8.decode_first_rune(b.buf[b.r..b.w])
	}
	b.r += size
	return r, size as usize
}

// read_slice reads until the first occurrence of [`delim`] in the input,
// returning a slice pointing at the bytes in the buffer.
//
// Note: After the next [`read`] this buffer will become invalid. You likely
// should use [`read_line`].
//
// If [`read_slice`] encounters an error before finding a delimiter, it returns
// error itself. If the delimiter is not found and the end of the file is found,
// then [`BufferEofError`] is returned with a buffer that contains the bytes read
// to the end of the file.
//
// [`read_slice`] fails with error [`BufferFullError`] if the buffer fills without a delim.
//
// [`read_slice`] returns error if and only if line does not end in delim.
//
// Example:
// ```
// import fs
// import bufio
//
// fn main() {
//     file := fs.open_file('main.sp', 'r').unwrap()
//     reader := bufio.reader(file)
//
//     slice := reader.read_slice(b`\n`).unwrap()
//     println(slice)
// }
// ```
pub fn (b &mut Reader) read_slice(delim u8) -> ![]u8 {
	mut s := 0

	for {
		mut index := -1
		for i, ch in b.buf[b.r + s..b.w] {
			if ch == delim {
				index = i
				break
			}
		}
		if index >= 0 {
			index += s
			line := b.buf[b.r..b.r + index + 1]
			b.r += index + 1
			return line
		}

		if b.buffered() >= b.buf.len {
			b.r = b.w
			return error(BufferFullError{ line: b.buf })
		}

		s = b.w - b.r // do not rescan area we scanned before
		b.fill() or {
			b.r = b.w

			if err is io.Eof && b.w != 0 {
				// wrap Eof with BufferEof to return all readed buffer at this point
				return error(BufferEofError{ line: b.buf[..b.w] })
			}
			return error(err)
		}
	}
}

// read_line is a low-level line-reading primitive. Most callers should use
// [`read_bytes`]`(b\`\n\`)` or [`read_string`]`(b\`\n\`)` instead.
//
// [`read_line`] tries to return a single line, not including the end-of-line bytes.
// If the line was too long for the buffer then second return value is set and the
// beginning of the line is returned.
// The rest of the line will be returned from future calls. Second return value will
// be false when returning the last fragment of the line.
//
// Note: After the next [`read`] this buffer will become invalid.
//
// The text returned from [`read_line`] does not include the line end (`\r\n` or `\n`).
// No indication or error is given if the input ends without a final line end.
//
// Example:
// ```
// import fs
// import bufio
//
// fn main() {
//     file := fs.open_file('main.sp', 'r').unwrap()
//     reader := bufio.reader(file)
//
//     slice, is_prefix := reader.read_line().unwrap()
//     println(slice, is_prefix)
// }
// ```
pub fn (b &mut Reader) read_line() -> !([]u8, bool) {
	line := b.read_slice(b`\n`) or {
		if err is BufferEofError || err is BufferFullError {
			mut line := if err is BufferEofError { err.line } else if err is BufferFullError { err.line } else { []u8{} }

			// Handle the case where "\r\n" straddles the buffer.
			if line.len > 0 && line[line.len - 1] == `\r` {
				// Put the '\r' back on buf and drop it from line.
				// Let the next call to ReadLine check for "\r\n".
				if b.r == 0 {
					// should be unreachable
					return error("bufio: tried to rewind past start of buffer")
				}
				b.r--
				line = line[..line.len - 1]
			}
			// if we encounter Eof, then we read the full line
			is_prefix := err is BufferFullError
			return line, is_prefix
		}

		return error(err)
	}

	if line.len == 0 {
		return error(io.EOF)
	}

	if line.last() == b`\n` {
		mut drop := 1
		if line.len > 1 && line[line.len - 2] == b`\r` {
			drop = 2
		}
		return line[..line.len - drop], false
	}

	return line, false
}

// collect_fragments reads until the first occurrence of delim in the input.
// It returns (slice of full buffers, remaining bytes before delim, total number
// of bytes in the combined first two elements) or an error.
//
// The result is structured in this way to allow callers to minimize allocations and copies.
fn (b &mut Reader) collect_fragments(delim u8) -> !([][]u8, []u8, i32) {
	mut full_buffers := [][]u8{}
	mut total_len := 0

	for {
		// Use read_slice to look for delim, accumulating full buffers.
		frag := b.read_slice(delim) or {
			if err !is BufferFullError && err !is BufferEofError {
				// unexpected error
				return error(err)
			}

			line := if err is BufferEofError { err.line } else if err is BufferFullError { err.line } else { []u8{} }

			buf := line.copy()
			full_buffers.push(buf)
			total_len += buf.len as i32

			// continue to read next fragment
			continue
		}

		// got final fragment
		total_len += frag.len as i32
		return full_buffers, frag, total_len
	}
}

// read_bytes reads until the first occurrence of delim in the input,
// returning a slice containing the data up to and including the delimiter.
//
// If [`read_bytes`] encounters an error before finding a delimiter, it
// returns an error without data (often io.EOF).
// [`read_bytes`] returns error if and only if the returned data does not
// end in delim.
//
// Example:
// ```
// import fs
// import bufio
//
// fn main() {
//     file := fs.open_file('main.sp', 'r').unwrap()
//     reader := bufio.reader(file)
//
//     arr := reader.read_bytes(b`\n`).unwrap()
//     println(arr)
// }
// ```
pub fn (b &mut Reader) read_bytes(delim u8) -> ![]u8 {
	full, frag, n := b.collect_fragments(delim)!
	mut res := []u8{cap: n}
	for el in full {
		res.push_many(el)
	}
	res.push_many(frag)
	return res
}

// read_string reads until the first occurrence of delim in the input,
// returning a string containing the data up to and including the delimiter.
//
// If [`read_string`] encounters an error before finding a delimiter, it
// returns an error without data (often io.EOF).
// [`read_string`] returns error if and only if the returned data does not
// end in delim.
//
// Example:
// ```
// import fs
// import bufio
//
// fn main() {
//     file := fs.open_file('main.sp', 'r').unwrap()
//     reader := bufio.reader(file)
//
//     str := reader.read_string(b`\n`).unwrap()
//     println(str)
// }
// ```
pub fn (b &mut Reader) read_string(delim u8) -> !string {
	return b.read_bytes(delim)!.ascii_str()
}

fn (b &mut Reader) reset_impl(buf []u8, rd io.Reader) {
	*b = Reader{
		buf: buf
		rd: rd
	}
}

pub fn copy(dst &mut []u8, src []u8) -> i32 {
	min := if dst.len < src.len { dst.len } else { src.len }
	if min > 0 {
		mem.copy(dst.mut_raw(), src.raw(), min)
	}
	return min as i32
}
