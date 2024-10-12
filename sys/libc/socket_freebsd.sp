module libc

#[include("arpa/inet.h")]
#[include("<sys/socket.h>")]
#[include("<netinet/in.h>")]
#[include("<netdb.h>")]

extern {
	pub struct addrinfo {
		ai_family    i32
		ai_socktype  i32
		ai_flags     i32
		ai_protocol  i32
		ai_addrlen   i32
		ai_addr      *void
		ai_canonname *void
		ai_next      *mut addrinfo
	}

	pub struct sockaddr_in6 {
		// 1 + 1 + 2 + 4 + 16 + 4 = 28;
		sin6_len      u8     // 1
		sin6_family   u8     // 1
		sin6_port     u16    // 2
		sin6_flowinfo u32    // 4
		sin6_addr     [16]u8 // 16
		sin6_scope_id u32    // 4
	}

	pub struct sockaddr_in {
		sin_len    u8
		sin_family u8
		sin_port   u16
		sin_addr   u32
		sin_zero   [8]u8
	}

	pub struct sockaddr_un {
		sun_len    u8
		sun_family u8
		sun_path   [MAX_UNIX_PATH]u8
	}
}
