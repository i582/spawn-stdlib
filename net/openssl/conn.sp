module openssl

import net
import time
import io
import errno

const (
	DEFAULT_TCP_READ_TIMEOUT  = 30 as i64 * time.SECOND
	DEFAULT_TCP_WRITE_TIMEOUT = 30 as i64 * time.SECOND
)

pub struct ConnConfig {
	// verify is the path to a `rootca.pem` file, containing
	// trusted CA certificate(s)
	verify string

	// cert is the path to a cert.pem file, containing client
	// certificate(s) for the request
	cert string

	// cert_key is the path to a key.pem file, containing private
	// keys for the client certificate(s)
	cert_key string

	// validate is a flag to enable/disable certificate validation
	// Set this field to true, if you want to stop requests, when
	// their certificates are found to be invalid
	validate bool

	// in_memory_verification is a flag to enable/disable in-memory
	// verification.
	// if true, verify, cert, and cert_key are read from memory, not from a file
	in_memory_verification bool
}

pub struct Conn {
	ctx *mut SSL_CTX
	ssl *mut SSL

	owns_sock bool
	sock      net.Socket

	read_timeout  time.Duration = DEFAULT_TCP_READ_TIMEOUT
	write_timeout time.Duration = DEFAULT_TCP_WRITE_TIMEOUT

	cfg ConnConfig
}

pub fn Conn.new(cfg ConnConfig) -> !Conn {
	ctx := SSL_CTX_new(SSLv23_client_method())
	if ctx == nil {
		return error(last_stack_error())
	}

	if cfg.validate {
		SSL_CTX_set_verify_depth(ctx, 4)
		SSL_CTX_set_options(ctx, SSL_OP_NO_SSLv2 | SSL_OP_NO_SSLv3 | SSL_OP_NO_COMPRESSION)
	}

	ssl := SSL_new(ctx)
	if ssl == nil {
		return error(last_stack_error())
	}

	if cfg.validate {
		if cfg.verify != '' {
			ret := SSL_CTX_load_verify_locations(ctx, cfg.verify.c_str(), nil)
			validate_ret(ssl, ret, 'openssl: SSL_CTX_load_verify_locations failed')!
		}

		if cfg.cert != '' {
			ret := SSL_CTX_use_certificate_file(ctx, cfg.cert.c_str(), SSL_FILETYPE_PEM)
			validate_ret(ssl, ret, 'openssl: SSL_CTX_use_certificate_file failed')!
		}

		if cfg.cert_key != '' {
			ret := SSL_CTX_use_PrivateKey_file(ctx, cfg.cert_key.c_str(), SSL_FILETYPE_PEM)
			validate_ret(ssl, ret, 'openssl: SSL_CTX_use_PrivateKey_file failed')!
		}

		preferred_ciphers := 'HIGH:!aNULL:!kRSA:!PSK:!SRP:!MD5:!RC4'
		ret := SSL_set_cipher_list(ssl, preferred_ciphers.c_str())
		validate_ret(ssl, ret, 'openssl: SSL_set_cipher_list failed')!
	}

	return Conn{
		ctx: ctx
		ssl: ssl
		cfg: cfg
	}
}

pub fn (c &mut Conn) dial(hostname string, port i32) -> ! {
	c.owns_sock = true
	mut tcp_conn := net.dial_tcp('${hostname}:${port}')!
	c.connect(tcp_conn, hostname)!
}

pub fn (c &mut Conn) connect(tcp_conn &mut net.TcpConn, hostname string) -> ! {
	c.sock = tcp_conn.sock.s

	ret := SSL_set_tlsext_host_name(c.ssl, hostname.c_str())
	validate_ret(c.ssl, ret, 'openssl: cannot set hostname')!

	ret2 := SSL_set_fd(c.ssl, c.sock.handle)
	validate_ret(c.ssl, ret2, 'openssl: cannot assign socket to SSL')!

	// TODO: real deadline handling
	_ = time.now().add(5 * time.SECOND)

	for {
		ret3 := SSL_connect(c.ssl)
		if ret3 == 1 {
			break
		}

		if ret3 == -1 {
			raw_err := SSL_get_error(c.ssl, ret3)
			if raw_err in [SSL_ERROR_WANT_READ, SSL_ERROR_WANT_WRITE] {
				panic("don't support non-blocking sockets yet")
			}

			return error(last_ssl_error(c.ssl, ret3).with_label('openssl: could not connect using SSL'))
		}
	}

	if c.cfg.validate {
		ret4 := SSL_do_handshake(c.ssl)

		if ret4 == -1 {
			raw_err := SSL_get_error(c.ssl, ret4)
			if raw_err in [SSL_ERROR_WANT_READ, SSL_ERROR_WANT_WRITE] {
				panic("don't support non-blocking sockets yet")
			}

			return error(last_ssl_error(c.ssl, ret4).with_label('openssl: could not handshake using SSL'))
		}

		pcert := SSL_get_peer_certificate(c.ssl)
		defer fn () {
			if pcert != nil {
				X509_free(pcert)
			}
		}()

		res := SSL_get_verify_result(c.ssl)
		if res != X509_V_OK {
			return error(SslError.new('openssl: certificate verification failed'))
		}
	}
}

pub fn (c &mut Conn) read(buf &mut []u8) -> !i32 {
	return c.read_into_ptr(buf.mut_raw(), buf.len)
}

pub fn (c &mut Conn) read_into_ptr(buf *mut u8, len usize) -> !i32 {
	ret := SSL_read(c.ssl, buf, len as i32)
	if ret > 0 {
		return ret
	}

	if ret == 0 {
		return error(io.Eof{})
	}

	last_errno := errno.last()
	if last_errno == .EAGAIN {
		// since we are currently using blocking sockets,
		// we can assume that we have reached a timeout
		return error(net.TimeoutError{})
	}

	raw_err := SSL_get_error(c.ssl, ret)
	if raw_err in [SSL_ERROR_WANT_READ, SSL_ERROR_WANT_WRITE] {
		panic("don't support non-blocking sockets yet")
	}

	if raw_err == SSL_ERROR_ZERO_RETURN {
		return 0
	}

	return error(last_ssl_error(c.ssl, ret).with_label('openssl: could not read from SSL'))
}

pub fn (c &mut Conn) write_ptr(buf *u8, len usize) -> !i32 {
	mut total_sent := 0

	for total_sent < len {
		cursor := unsafe { buf + total_sent }
		remaining := len as i32 - total_sent
		sent := SSL_write(c.ssl, cursor, remaining)
		if sent <= 0 {
			raw_err := SSL_get_error(c.ssl, sent)
			if raw_err in [SSL_ERROR_WANT_READ, SSL_ERROR_WANT_WRITE] {
				panic("don't support non-blocking sockets yet")
			}

			return error(last_ssl_error(c.ssl, sent).with_label('openssl: could not write to SSL'))
		}

		total_sent += sent
	}

	return total_sent
}

pub fn (c &mut Conn) write(buf []u8) -> !i32 {
	return c.write_ptr(buf.raw(), buf.len)
}

pub fn (c &mut Conn) write_string(s string) -> !i32 {
	return c.write_ptr(s.c_str(), s.len)
}

pub fn (c &mut Conn) close() -> ! {
	if c.ssl != nil {
		SSL_shutdown(c.ssl)
		SSL_free(c.ssl)
	}

	if c.ctx != nil {
		SSL_CTX_free(c.ctx)
	}

	if c.owns_sock {
		// TODO: close sock
	}
}

pub fn (c &mut Conn) set_read_timeout(t time.Duration) -> ! {
	c.sock.set_read_timeout(t)!
	c.read_timeout = t
}

pub fn (c &mut Conn) set_write_timeout(t time.Duration) -> ! {
	c.sock.set_write_timeout(t)!
	c.write_timeout = t
}

fn validate_ret(ssl *SSL, ret i32, label string) -> ![unit, SslError] {
	if ret == 1 {
		return ()
	}

	return error(last_ssl_error(ssl, ret).with_label(label))
}
