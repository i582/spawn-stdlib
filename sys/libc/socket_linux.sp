module libc

#[include("<arpa/inet.h>")]
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

	pub struct sockaddr_in {
		sin_family u16
		sin_port   u16
		sin_addr   u32
	}

	pub struct sockaddr_in6 {
		sin6_family u16
		sin6_port   u16
		sin6_addr   [4]u32
	}

	pub struct sockaddr_un {
		sun_family u16
		sun_path   [108]u8
	}
}
