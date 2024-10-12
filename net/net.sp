module net

pub fn join_host_port(host string, port string) -> string {
	if host.contains(':') {
		return '[${host}]:${port}'
	}
	return '${host}:${port}'
}
