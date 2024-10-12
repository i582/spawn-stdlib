module openssl

pub struct SslError {
	label string
	code  i32
	ret   i32
	msg   string
}

fn SslError.new(msg string) -> SslError {
	return SslError{ code: -1, ret: -1, msg: msg }
}

fn (s &SslError) msg() -> string {
	if s.label != "" {
		return '${s.label}: ${s.msg}'
	}
	return s.msg
}

fn (s &SslError) with_label(label string) -> SslError {
	return SslError{
		label: label
		code: s.code
		ret: s.ret
		msg: s.msg
	}
}

fn last_stack_error() -> SslError {
	err := ERR_get_error()
	mut buf := [512]u8{}
	ERR_error_string_n(err, buf.mut_raw(), 512)
	err_str := string.view_from_c_str(buf.raw())
	return SslError{ code: -1, ret: -1, msg: 'ssl error: ${err_str}' }
}

fn last_ssl_error(ssl *SSL, ret i32) -> SslError {
	last := SSL_get_error(ssl, ret)
	err := ERR_get_error()

	mut buf := [512]u8{}
	ERR_error_string_n(err, buf.mut_raw(), 512)
	err_str := string.view_from_c_str(buf.raw())

	if last == SSL_ERROR_SYSCALL {
		return SslError{ code: last, ret: ret, msg: 'unrecoverable syscall error (ret: ${ret}, err: ${err}): ${err_str}' }
	}

	if last == SSL_ERROR_SSL {
		return SslError{ code: last, ret: ret, msg: 'unrecoverable ssl protocol error (ret: ${ret}, err: ${err}): ${err_str}' }
	}

	return SslError{ code: last, ret: ret, msg: 'ssl error (ret: ${ret}, err: ${err}): ${err_str}' }
}
