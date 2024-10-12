module io

// ErrNoProgress is returned by some clients of a [`Reader`] when
// many calls to [`Reader.read`] have failed to return any data or error,
// usually the sign of a broken [`Reader`] implementation.
pub struct ErrNoProgress {}

// msg returns the string representation of the error.
pub fn (_ ErrNoProgress) msg() -> string {
	return "multiple read calls return no data or error"
}

// Eof is empty struct that implements the error interface to represent the
// end of file. See [`EOF`] for the singleton value that should be used.
pub struct Eof {}

// msg returns the string representation of the error.
pub fn (_ Eof) msg() -> string {
	return "end of file"
}

// ErrShortWrite means that a write accepted fewer bytes than requested
// but failed to return an explicit error.
pub struct ErrShortWrite {}

// msg returns the string representation of the error.
pub fn (_ ErrShortWrite) msg() -> string {
	return "short write"
}

// ErrInvalidWrite means that a write returned an impossible count.
pub struct ErrInvalidWrite {}

// msg returns the string representation of the error.
pub fn (_ ErrInvalidWrite) msg() -> string {
	return "invalid write"
}

// EOF is the error returned by [`Reader.read`] when no more input is available.
pub const EOF = &Eof{}

// Reader is the interface that wraps the basic Read method.
//
// Read reads up to `p.len` bytes into `buf`. It returns the number of bytes
// read (0 <= n <= p.len) or an error, if any.
//
// Implementations must not retain `buf`.
pub interface Reader {
	fn read(&mut self, buf &mut []u8) -> !i32
}

// Writer is the interface that wraps the basic [`write`] method.
pub interface Writer {
	// write writes `buf.len` bytes from `buf` to the underlying data stream.
	// It returns the number of bytes written from `buf` (0 <= n <= buf.len)
	// or error encountered that caused the write to stop early.
	//
	// Implementation must not modify the slice data, even temporarily and
	// should not retain the slice data after the call returns.
	fn write(&mut self, buf []u8) -> !i32

	// write_string writes the contents of [`str`] to the underlying data stream.
	// Returns the number of bytes written from [`str`] (0 <= n <= [`str`].len)
	fn write_string(&mut self, str string) -> !i32 {
		return self.write(unsafe { str.bytes_no_copy() })
	}
}

// Closer is the interface that wraps the basic [`close`] method.
//
// The behavior of [`close`] after the first call is undefined.
// Specific implementations may document their own behavior.
pub interface Closer {
	fn close(&mut self) -> !
}

// ReadWriteCloser is the interface that groups the basic [`read`], [`write`] and [`close`] methods.
pub interface ReadWriteCloser {
	Reader
	Writer
	Closer
}

// ReadWriter is the interface that groups the basic [`read`] and [`write`] methods.
pub interface ReadWriter {
	Reader
	Writer
}

pub fn copy(dst Writer, src Reader) -> !i32 {
	return copy_buffer(dst, src, none)
}

fn copy_buffer(dst Writer, src Reader, buf ?[]u8) -> !i32 {
	mut tmp_buf := buf or { []u8{len: 32 * 1024} }

	mut written := 0
	for {
		nr := src.read(&mut tmp_buf) or {
			if err is Eof {
				break
			}
			return error(err)
		}
		if nr > 0 {
			nw := dst.write(tmp_buf[..nr]) or {
				return error(err)
			}

			if nw < 0 || nr < nw {
				return error(ErrInvalidWrite{})
			}

			if nw != nr {
				return error(ErrShortWrite{})
			}
		}
	}

	return written
}

pub struct MultiWriter {
	writers []Writer
}

// new creates a new writer that duplicates its writes to all the
// provided writers, similar to the Unix tee(1) command.
//
// Each write is written to each listed writer, one at a time.
// If a listed writer returns an error, that overall write operation
// stops and returns the error; it does not continue down the list.
pub fn MultiWriter.new(writers ...Writer) -> MultiWriter {
	mut all_writers := []Writer{}
	for w in writers {
		if w is MultiWriter {
			all_writers.push_many(w.writers)
		} else {
			all_writers.push(w)
		}
	}
	return MultiWriter{ writers: all_writers }
}

fn (m &mut MultiWriter) write(buf []u8) -> ![i32, Error] {
	for w in m.writers {
		nw := w.write(buf) or {
			return error(err)
		}
		if nw < 0 {
			return error(ErrShortWrite{})
		}
	}

	return buf.len as i32
}

// Discard is a [`Writer`] on which all [`Writer.write`] calls succeed
// without doing anything.
pub struct Discard {}

fn (d &mut Discard) write(buf []u8) -> !i32 {
	return buf.len as i32
}

// read_all reads from [`r`] until an error or [`EOF`] and returns the data it read.
// [`EOF`] error is not reported.
pub fn read_all(r Reader) -> ![]u8 {
	mut b := []u8{len: 512}

	mut read := 0
	for {
		n := r.read(&mut b[read..]) or {
			if err is Eof {
				break
			}
			return error(err)
		}
		if n == 0 {
			break
		}

		read += n

		if b.len == read {
			b.ensure_cap(b.len + 1)
		}
	}

	return b[..read]
}
