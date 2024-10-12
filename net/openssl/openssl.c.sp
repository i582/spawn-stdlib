module openssl

#[include_path_if(linux, '/usr/local/include/openssl')]
#[library_path_if(linux, '/usr/local/lib')]

#[include_path_if(freebsd, '/usr/local/include')]
#[library_path_if(freebsd, '/usr/local/lib')]

#[library_if(windows, 'libssl')]
#[library_if(windows, 'libcrypto')]

#[library_if(!windows, 'ssl')]
#[library_if(!windows, 'crypto')]

// MacPorts
#[include_path_if(darwin, '/opt/local/include')]
#[library_path_if(darwin, '/opt/local/lib')]

// Brew
#[include_path_if(darwin, '/usr/local/opt/openssl/include')]
#[library_path_if(darwin, '/usr/local/opt/openssl/lib')]

// brew on macos-12 (ci runner)
#[include_path_if(darwin, '/usr/local/opt/openssl@3/include')]
#[library_path_if(darwin, '/usr/local/opt/openssl@3/lib')]

// Brew arm64
#[include_path_if(darwin, '/opt/homebrew/opt/openssl/include')]
#[library_path_if(darwin, '/opt/homebrew/opt/openssl/lib')]

// Procursus
#[include_path_if(darwin, '/opt/procursus/include')]
#[library_path_if(darwin, '/opt/procursus/lib')]

#[include("<openssl/ssl.h>")]
#[include("<openssl/err.h>")]
#[include("<openssl/rand.h>")]

extern {
	const (
		SSL_ERROR_NONE             = 0
		SSL_ERROR_SSL              = 0
		SSL_ERROR_WANT_READ        = 0
		SSL_ERROR_WANT_WRITE       = 0
		SSL_ERROR_WANT_X509_LOOKUP = 0
		SSL_ERROR_SYSCALL          = 0
		SSL_ERROR_ZERO_RETURN      = 0
		SSL_ERROR_WANT_CONNECT     = 0
		SSL_ERROR_WANT_ACCEPT      = 0
		SSL_ERROR_WANT_ASYNC       = 0
		SSL_ERROR_WANT_ASYNC_JOB   = 0
	)

	const (
		SSL_OP_NO_SSLv2       = 0
		SSL_OP_NO_SSLv3       = 0
		SSL_OP_NO_COMPRESSION = 0
	)

	const (
		X509_V_OK = 0
	)

	const (
		SSL_FILETYPE_PEM = 0
	)

	struct SSL {}
	struct BIO {}
	struct SSL_METHOD {}
	struct X509 {}
	struct SSL_CTX {}
	struct OPENSSL_INIT_SETTINGS {}

	fn BIO_new_ssl_connect(ctx *SSL_CTX) -> *BIO
	fn BIO_set_conn_hostname(b *BIO, name *u8) -> i32
	fn BIO_get_ssl(bp *BIO, vargs ...*void)
	fn BIO_do_connect(b *BIO) -> i32
	fn BIO_do_handshake(b *BIO) -> i32
	fn BIO_puts(b *BIO, buf *u8)
	fn BIO_read(b *BIO, buf *void, len i32) -> i32
	fn BIO_free_all(a *BIO)

	fn SSL_CTX_new(method *SSL_METHOD) -> *mut SSL_CTX
	fn SSL_CTX_set_options(ctx *SSL_CTX, options i32)
	fn SSL_CTX_set_verify_depth(s *SSL_CTX, depth i32)
	fn SSL_CTX_load_verify_locations(ctx *SSL_CTX, const_file *u8, ca_path *u8) -> i32
	fn SSL_CTX_free(ctx *SSL_CTX)
	fn SSL_CTX_use_certificate_file(ctx *SSL_CTX, const_file *u8, file_type i32) -> i32
	fn SSL_CTX_use_PrivateKey_file(ctx *SSL_CTX, const_file *u8, file_type i32) -> i32
	fn SSL_new(ctx *SSL_CTX) -> *mut SSL
	fn SSL_set_fd(ssl *SSL, fd i32) -> i32
	fn SSL_connect(ssl *SSL) -> i32
	fn SSL_do_handshake(ssl *SSL) -> i32
	fn SSL_set_cipher_list(ctx *SSL, str *u8) -> i32
	fn SSL_get_peer_certificate(ssl *SSL) -> *X509
	fn SSL_get_error(ssl *SSL, ret i32) -> i32
	fn SSL_get_verify_result(ssl *SSL) -> i32
	fn SSL_set_tlsext_host_name(s *SSL, name *u8) -> i32
	fn SSL_shutdown(ssl *SSL) -> i32
	fn SSL_free(ssl *SSL)
	fn SSL_write(ssl *SSL, buf *void, buflen i32) -> i32
	fn SSL_read(ssl *SSL, buf *mut void, buflen i32) -> i32
	fn SSL_load_error_strings()
	fn SSL_library_init() -> i32
	fn SSLv23_client_method() -> *SSL_METHOD

	fn TLS_method() -> *void
	fn TLSv1_2_method() -> *void
	fn OPENSSL_init_ssl(opts u64, settings *OPENSSL_INIT_SETTINGS) -> i32
	fn X509_free(const_cert *X509)

	fn ERR_get_error() -> u64
	fn ERR_clear_error()
	fn ERR_error_string_n(err u64, buf *mut u8, len usize) -> *u8
}
