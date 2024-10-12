module libc

#[include_if(!windows, "<sys/un.h>")]

#[include_if(darwin || freebsd, "<sys/types.h>")]
#[include_if(darwin || freebsd, "<sys/socket.h>")]
#[include_if(darwin || freebsd, "<netinet/in.h>")]
#[include_if(darwin || freebsd || linux, "<netdb.h>")]

#[include_if(unix, "<netinet/tcp.h>")]
#[include_if(unix, "<fcntl.h>")]
#[include_if(linux, "<sys/resource.h>")]

extern {
	pub const (
		FIONBIO      = 0
		F_GETFL      = 0
		F_SETFL      = 0
		O_NONBLOCK   = 0
		SOL_SOCKET   = 0
		SO_REUSEADDR = 0
		SO_RCVTIMEO  = 0
		SO_SNDTIMEO  = 0
	)

	pub const (
		SOCK_DGRAM     = 0
		SOCK_STREAM    = 0
		SOCK_SEQPACKET = 0

		AF_UNIX   = 0
		AF_INET   = 0
		AF_INET6  = 0
		AF_UNSPEC = 0

		AI_PASSIVE = 0
	)

	#[typedef]
	pub struct sockaddr {}

	pub fn htonl(host u32) -> u32
	pub fn htons(host u16) -> u16

	pub fn ntohl(net u32) -> u32
	pub fn ntohs(net u16) -> u16

	pub fn getaddrinfo(node *u8, service *u8, hints *addrinfo, res *mut *mut addrinfo) -> i32
	pub fn freeaddrinfo(info *mut addrinfo)
	pub fn bind(fd i32, addr *sockaddr, addrlen u32) -> i32
	pub fn shutdown(fd i32, how i32) -> i32
	pub fn listen(fd i32, backlog i32) -> i32
	pub fn send(fd i32, buf *void, len usize, flags i32) -> i32
	pub fn connect(fd i32, addr *sockaddr, addrlen u32) -> i32
	pub fn recv(fd i32, buf *void, len usize, flags i32) -> i32
	pub fn accept(fd i32, addr *sockaddr, addrlen *u32) -> i32
	pub fn ioctlsocket(s i32, cmd i32, argp *u32) -> i32
	pub fn fcntl(fd i32, cmd i32, arg ...any) -> i32
	pub fn inet_ntop(af i32, src *void, dst *mut u8, dst_size i32) -> *u8
	pub fn gai_strerror(err i32) -> *u8
	pub fn getpeername(sockfd i32, addr *mut sockaddr, addlen *u32) -> i32
	pub fn socket(domain i32, typ i32, protocol i32) -> i32
	pub fn setsockopt(sockfd i32, level i32, optname i32, optval *void, optlen u32) -> i32
}
