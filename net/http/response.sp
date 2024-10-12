module http

import bufio
import strings

pub struct Response {
	version     Version = .v1_1
	headers     Headers
	status_code Status  = .ok
	status_msg  string  = "OK"
	data        []u8

	body ?&mut bufio.Reader

	// content_length records the length of the associated content. The
	// value -1 indicates that the length is unknown. Unless HEAD method,
	// values >= 0 indicate that the given number of bytes may be read from [`body`].
	content_length i64 = -1
}

pub fn (r &Response) bytes() -> []u8 {
	mut buf := strings.new_builder(100)
	buf.write_str("HTTP/")
	buf.write_str(r.version.str())
	buf.write_u8(b` `)
	buf.write_str(r.status_code.str())
	buf.write_u8(b` `)
	buf.write_str(r.status_msg)
	buf.write_str("\r\n")
	r.headers.render_to(&mut buf)
	buf.write_str("\r\n")
	buf.write(r.data) or {}
	return buf.as_array()
}

// read_body reads the body of the response and returns it as a byte array.
// It returns empty byte array if the response has no body or `Content-Length` is 0
// or missing.
pub fn (r &mut Response) read_body() -> ![]u8 {
	if r.content_length == 0 {
		return []
	}
	if r.content_length < 0 {
		return msg_err("invalid Content-Length: ${r.content_length}")
	}

	req_body := r.body or { return [] } // TODO: error here?

	mut body := []u8{len: r.content_length}
	mut remaining := r.content_length
	for remaining > 0 {
		nread := req_body.read(&mut body[r.content_length - remaining..])!
		remaining -= nread
	}
	return body
}

pub fn parse_response(reader &mut bufio.Reader) -> !Response {
	line, _ := reader.read_line()!
	version, status_code, status_msg := parse_status_line(string.view_from_bytes(line))!
	headers := parse_headers_from_reader(reader)!

	return Response{
		version: version
		status_code: status_code
		status_msg: status_msg
		headers: headers
		body: reader
		content_length: headers.get("Content-Length", false).unwrap_or("-1").parse_int() or { -1 }
	}
}

// parse_status_line parses the first line of an HTTP response.
//
// Example:
// ```
// line := 'HTTP/1.1 200 OK'
// version, status_code, status_msg := parse_status_line(line)
// version == 'HTTP/1.1'
// status_code == 200
// status_msg == 'OK'
// ```
pub fn parse_status_line(line string) -> !(Version, Status, string) {
	if line.len < 5 || !line[..5].equal_ignore_case("http/") {
		return msg_err[(Version, Status, string)]('response does not start with HTTP/')
	}

	space1 := line.index_u8(b` `)
	space2 := line.index_after(space1 + 1, ' ')
	if space1 == -1 || space2 == -1 {
		return msg_err[(Version, Status, string)]("malformed response line")
	}

	version_str := line[..space1]
	status_code_str := line[space1 + 1..space2]
	status_msg := line[space2 + 1..]

	version := Version.from_str(version_str)
	if version == .unknown {
		return msg_err[(Version, Status, string)]("unsupported version ${version_str}")
	}

	return version, Status.from(status_code_str.i32()), status_msg
}
