module net

import mem
import intrinsics
import net.conv
import sys.libc

const (
	MAX_IP_ADDRESS_LEN  = 24
	MAX_IP6_ADDRESS_LEN = 46
)

#[c_union]
struct AddrData {
	Unix
	Ip
	Ip6
}

fn resolve_address(addr string, family AddrFamily, typ SocketType) -> ![]Addr {
	return match family {
		.ip, .ip6, .unspec => resolve_ip_address(addr, family, typ)
		else => msg_err("unsupported address family `${family}`")
	}
}

fn resolve_ip_address(addr string, family AddrFamily, typ SocketType) -> ![]Addr {
	addr_parts := split_address(addr)
	address := addr_parts[0]
	port := addr_parts[1]

	if addr.len > 0 && addr[0] == b`:` {
		// match family {
		//     .ip6 -> {
		//         return []
		//     }
		// }
	}

	mut addr_info := libc.addrinfo{}
	mem.zero(&mut addr_info as *mut u8, mem.size_of[libc.addrinfo]())

	addr_info.ai_family = family as i32
	addr_info.ai_socktype = typ as i32
	addr_info.ai_flags = libc.AI_PASSIVE

	port_str := port.str()

	mut results := nil as *mut libc.addrinfo
	res := libc.getaddrinfo(address.c_str(), port_str.c_str(), &mut addr_info, &mut results)
	if res != 0 {
		return msg_err("failed to resolve address: ${get_address_info_last_error(res)}")
	}

	mut addresses := []Addr{}

	mut cursor := results
	for {
		next := unsafe { *cursor }
		match next.ai_family as AddrFamily {
			.ip => {
				mut new_addr := Addr{
					addr: AddrData{
						Ip: Ip{}
					}
				}

				mem.copy((&mut new_addr) as *mut u8, unsafe { next.ai_addr as *u8 }, next.ai_addrlen)
				addresses.push(new_addr)
			}
			.ip6 => {
				mut new_addr := Addr{
					addr: AddrData{
						Ip6: Ip6{}
					}
				}

				mem.copy((&mut new_addr) as *mut u8, unsafe { next.ai_addr as *u8 }, next.ai_addrlen)
				addresses.push(new_addr)
			}
			else => return error("Unexpected address family ${next.ai_family}")
		}

		if next.ai_next == nil {
			break
		}

		cursor = unsafe { cursor.ai_next }
	}

	libc.freeaddrinfo(results)
	return addresses
}

fn get_address_info_last_error(num i32) -> string {
	return string.view_from_c_str(libc.gai_strerror(num))
}

fn split_address(addr string) -> (string, i32) {
	res := addr.split_by_last(':')
	address := res[0]
	port := res[1].i32()
	return address, port
}

pub fn new_ip6(port u16, addr [16]u8) -> Addr {
	mut a := Addr{
		f: AddrFamily.ip6 as u8
		addr: AddrData{
			Ip6: Ip6{
				port: conv.hton16(port)
			}
		}
	}

	unsafe {
		for i in 0 .. 16 {
			a.addr.Ip6.addr[i] = addr[i]
		}
	}

	return a
}

pub fn new_ip(port u16, addr [4]u8) -> Addr {
	mut a := Addr{
		f: AddrFamily.ip as u8
		addr: AddrData{
			Ip: Ip{
				port: conv.hton16(port)
			}
		}
	}

	unsafe {
		for i in 0 .. 4 {
			a.addr.Ip.addr[i] = addr[i]
		}
	}

	return a
}

pub fn (a Ip) str() -> string {
	mut buf := [MAX_IP_ADDRESS_LEN]u8{}
	res := libc.inet_ntop(AddrFamily.ip, &a.addr, &mut buf[0], buf.len() as i32)
	if res == nil {
		return "<unknown>"
	}

	str := string.view_from_c_str(res)
	port := conv.hton16(a.port)
	return '${str}:${port}'
}

pub fn (a Ip6) str() -> string {
	mut buf := [MAX_IP6_ADDRESS_LEN]u8{}
	res := libc.inet_ntop(AddrFamily.ip6, &a.addr, &mut buf[0], buf.len() as i32)
	if res == nil {
		return "<unknown>"
	}

	str := string.view_from_c_str(res)
	port := conv.hton16(a.port)
	return '${str}:${port}'
}

pub fn (a Addr) family() -> AddrFamily {
	return a.f as AddrFamily
}

const ADDR_OFFSET = intrinsics.offset_of[Addr]('addr')

pub fn (a Addr) len() -> usize {
	return match a.family() {
		.ip => mem.size_of[Ip]() + ADDR_OFFSET
		.ip6 => mem.size_of[Ip6]() + ADDR_OFFSET
		.unix => mem.size_of[Unix]() + ADDR_OFFSET
		else => panic("unknown address family")
	}
}

pub fn (a Addr) str() -> string {
	return unsafe {
		match a.family() {
			.ip => a.addr.Ip.str()
			.ip6 => a.addr.Ip6.str()
			else => "<unknown>"
		}
	}
}

pub fn peer_addr_from_socket_handle(handle i32) -> !Addr {
	mut addr := Addr{
		addr: AddrData{
			Ip6: Ip6{}
		}
	}
	mut size := mem.size_of[Addr]() as u32
	socket_error(libc.getpeername(handle, &mut addr as *libc.sockaddr, &size))!
	return addr
}
