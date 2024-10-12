module net

import time
import errno
import sys.libc
import intrinsics

pub enum SocketType {
	udp       = libc.SOCK_DGRAM
	tcp       = libc.SOCK_STREAM
	seqpacket = libc.SOCK_SEQPACKET
}

pub enum AddrFamily {
	unix   = libc.AF_UNIX
	ip     = libc.AF_INET
	ip6    = libc.AF_INET6
	unspec = libc.AF_UNSPEC
}

const (
	DEFAULT_TCP_READ_TIMEOUT  = 30 as i64 * time.SECOND
	DEFAULT_TCP_WRITE_TIMEOUT = 30 as i64 * time.SECOND
)

pub struct TcpConn {
	sock   TcpSocket
	handle i32

	read_timeout  time.Duration = DEFAULT_TCP_READ_TIMEOUT
	write_timeout time.Duration = DEFAULT_TCP_WRITE_TIMEOUT

	is_blocking bool = true
}

pub fn dial_tcp(mut address string) -> !&mut TcpConn {
	comptime if windows {
		// resolving 0.0.0.0 to localhost, works on Linux and macOS,
		// but not on Windows, so try to emulate it:
		address = address.
			replace_prefix(':::', 'localhost').
			replace_prefix('0.0.0.0:', 'localhost')
	}

	addrs := resolve_address(address, .unspec, .tcp) or {
		return error('net: could not resolve address: ${address}: ${err.msg()}')
	}

	for addr in addrs {
		mut s := TcpSocket.new(addr.family()) or {
			return error('net: could not create socket: ${err.msg()}')
		}
		s.connect(addr) or {
			s.close()!
			continue
		}
		s.s.set_read_timeout(DEFAULT_TCP_READ_TIMEOUT)!
		s.s.set_write_timeout(DEFAULT_TCP_WRITE_TIMEOUT)!
		return &mut TcpConn{ sock: s, handle: s.s.handle }
	}

	return error('net: could not connect to address: ${address}')
}

pub fn (c &mut TcpConn) write(b []u8) -> !i32 {
	return c.write_ptr(b.raw(), b.len)
}

pub fn (c &mut TcpConn) write_ptr(b *u8, len usize) -> !i32 {
	return socket_error(libc.send(c.handle, b, len, MSG_NOSIGNAL))
}

pub fn (c &mut TcpConn) write_string(s string) -> !i32 {
	return c.write_ptr(s.c_str(), s.len)
}

pub fn (c &mut TcpConn) read_ptr(buf *u8, len usize) -> !i32 {
	res := socket_error(libc.recv(c.handle, buf, len, 0))!
	if res == 0 {
		return error('net: connection closed')
	}

	return res
}

pub fn (c &mut TcpConn) read(buf &mut []u8) -> !i32 {
	return c.read_ptr(buf.raw(), buf.len) or {
		return error('net: could not read from socket with fd ${c.sock.s.handle}: ${err.msg()}')
	}
}

pub fn (c &mut TcpConn) close() -> !i32 {
	return c.sock.close()
}

pub fn (c &mut TcpConn) set_read_timeout(t time.Duration) -> ! {
	c.sock.s.set_read_timeout(t)!
	c.read_timeout = t
}

pub fn (c &mut TcpConn) set_write_timeout(t time.Duration) -> ! {
	c.sock.s.set_write_timeout(t)!
	c.write_timeout = t
}

pub struct TcpListener {
	sock TcpSocket
}

pub fn listen_tcp(family AddrFamily, address string) -> !&mut TcpListener {
	mut s := TcpSocket.new(family) or {
		return error('net: could not create socket: ${err.msg()}')
	}

	addrs := resolve_address(address, family, .tcp) or {
		return BaseError.new('net: could not resolve address: ${address}: ${err.msg()}')
	}

	addr := addrs.first()

	socket_error(libc.bind(s.s.handle, &addr as *libc.sockaddr, addr.len() as u32))!
	socket_error(libc.listen(s.s.handle, 128))!

	return &mut TcpListener{ sock: s }
}

pub fn (l &mut TcpListener) accept() -> !&mut TcpConn {
	res := l.accept_only()!
	res.set_sock()!
	return res
}

pub fn (l &mut TcpListener) accept_only() -> !&mut TcpConn {
	handle := libc.accept(l.sock.s.handle, nil, nil)
	if handle <= 0 {
		return error('net: could not accept connection: ${errno.last().desc()}')
	}
	return &mut TcpConn{ handle: handle }
}

pub fn (l &mut TcpListener) close() -> !i32 {
	return l.sock.close()
}

pub fn (c &mut TcpConn) set_sock() -> ! {
	c.sock = TcpSocket.from_handle(c.handle)!
}

pub fn (c &mut TcpConn) set_blocking(state bool) -> ! {
	if c.is_blocking == state {
		return
	}
	c.is_blocking = state
	set_blocking(c.sock.s.handle, state)!
}

pub fn (con &mut TcpConn) reuse_address() -> ! {
	set_reuse(con.sock.s.handle)!
}

pub fn (c &TcpConn) peer_addr() -> !Addr {
	return peer_addr_from_socket_handle(c.sock.s.handle)
}

pub fn (c &TcpConn) peer_ip() -> !string {
	return c.peer_addr()!.str()
}

pub struct TcpSocket {
	s Socket
}

pub fn TcpSocket.new(family AddrFamily) -> !TcpSocket {
	handle := socket_error(libc.socket(family, SocketType.tcp, 0))!
	return TcpSocket{ s: Socket{ handle: handle } }
}

fn TcpSocket.from_handle(fd i32) -> !TcpSocket {
	return TcpSocket{ s: Socket{ handle: fd } }
}

pub fn (s TcpSocket) bind(addr string) -> !i32 {
	addrs := resolve_address(addr, .ip, .tcp)!

	first := addrs.first()
	addr_len := first.len()

	return socket_error(libc.bind(s.s.handle, &first as *libc.sockaddr, addr_len as u32))
}

pub fn (s TcpSocket) close() -> !i32 {
	libc.shutdown(s.s.handle, 2)
	return close_or_error(s.s.handle)
}

pub fn (s TcpSocket) connect(a Addr) -> ! {
	c := libc.connect(s.s.handle, &a as *libc.sockaddr, a.len() as u32)
	socket_error(c)!
}

fn close_or_error(handle i32) -> !i32 {
	return socket_error(libc.close(handle))
}

#[track_caller]
fn socket_error(code i32) -> !i32 {
	if code >= 0 {
		return code
	}

	comptime if windows {
		err_win := wsa_last_error()
		return error('net: socket error: (${err_win as i32}) ${err_win.desc()} at ${intrinsics.caller_location()}')
	}

	err_num := errno.last()
	if err_num == .EAGAIN {
		// since we are currently using blocking sockets,
		// we can assume that we have reached a timeout
		return error(TimeoutError{})
	}

	return error('net: socket error: (${err_num as i32}) ${err_num.desc()} at ${intrinsics.caller_location()}')
}

pub struct TimeoutError {
	no errno.Errno
}

pub fn (t TimeoutError) msg() -> string {
	return "timeout"
}
