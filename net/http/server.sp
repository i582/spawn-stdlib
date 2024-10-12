module http

import net
import bufio
import strings
import sync.atomic

pub struct Server {
	addr    string
	handler Handler

	in_shutdown atomic.Bool
}

pub fn Server.new(addr string, handler Handler) -> Server {
	return Server{ addr: addr, handler: handler }
}

pub fn (s &Server) listen_and_serve() -> ! {
	listener := net.listen_tcp(.ip, s.addr)!
	s.serve(listener)!
	listener.close()!
}

pub fn (s &mut Server) close() -> ! {
	s.in_shutdown.store(true, .seq_cst)
}

pub fn (s &Server) serve(l &mut net.TcpListener) -> ! {
	for {
		if s.in_shutdown.load(.seq_cst) {
			break
		}
		rw := l.accept()!
		handle_connection(rw, s.handler)!
	}
}

fn handle_connection(conn &mut net.TcpConn, handler Handler) -> ! {
	mut reader := bufio.reader(conn)
	mut req := parse_request(reader)!

	mut body_builder := strings.new_builder(100)

	rw := DefaultResponseWriter{
		body_builder: &mut body_builder
		headers: &mut req.headers
	}

	mut resp := handler.serve_http(rw, &req)!

	resp.data = *rw.body_builder as []u8
	resp.headers = *rw.headers

	remote_ip := conn.peer_ip() or { "0.0.0.0" }
	resp.headers.set("Remote-Addr", remote_ip)

	if resp.version == .unknown {
		resp.version = req.version
	}

	if "Content-Length" !in resp.headers {
		resp.headers.set("Content-Length", resp.data.len.str())
	}

	conn.write(resp.bytes())!
	conn.close()!
}

pub fn send_error(rw ResponseWriter, error string, code Status) -> ! {
	rw.headers().set("Content-Type", "text/plain; charset=utf-8")
	rw.headers().set("X-Content-Type-Options", "nosniff")
	rw.write_header(code)
	rw.write_string(error)!
}

pub interface ResponseWriter {
	fn headers(&mut self) -> &mut Headers
	fn write(&mut self, buf []u8) -> !i32
	fn write_header(&mut self, code Status)
	fn write_string(&mut self, data string) -> !i32
}

pub interface Handler {
	fn serve_http(&mut self, rw ResponseWriter, r &Request) -> !Response
}

struct DefaultHandler {}

pub fn (h &mut DefaultHandler) serve_http(rw ResponseWriter, r &Request) -> !Response {
	rw.write_string("Hello, World!")!
	return Response{}
}

struct DefaultResponseWriter {
	body_builder &mut strings.Builder
	headers      &mut Headers
}

pub fn (rw &mut DefaultResponseWriter) headers() -> &mut Headers {
	return rw.headers
}

pub fn (rw &mut DefaultResponseWriter) write(data []u8) -> !i32 {
	// TODO: if remove `!` then the C compiler crashes
	return rw.body_builder.write(data)!
}

pub fn (rw &mut DefaultResponseWriter) write_string(data string) -> !i32 {
	rw.body_builder.write_str(data)
	return 0
}

pub fn (rw &mut DefaultResponseWriter) write_header(code Status) {
	if code >= 100 && code <= 199 {
		write_status_line(rw.body_builder, true, code, [])
	}
}

fn write_status_line(bw &mut strings.Builder, is11 bool, code Status, scratch []u8) {
	if is11 {
		bw.write_str("HTTP/1.1 ")
	} else {
		bw.write_str("HTTP/1.0 ")
	}

	text := code.str()
	if text != "" {
		bw.write_str(code.str())
		bw.write_u8(b` `)
		bw.write_str(text)
		bw.write_str("\r\n")
	} else {
		// don't worry about performance
		bw.write_str(code.str())
		bw.write_str(" status code ")
		bw.write_str(code.str())
		bw.write_str("\r\n")
	}
}

pub fn listen_and_serve(addr string, handler Handler) -> ! {
	mut server := Server.new(addr, handler)
	server.listen_and_serve()!
}
