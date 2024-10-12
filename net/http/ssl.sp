module http

import bufio
import net.openssl

pub fn (r &mut Request) ssl_do(method Method, host string, port i32, path string) -> !Response {
	mut client := openssl.Conn.new(r.ConnConfig)!

	mut retries := 0
	for {
		client.dial(host, port) or {
			retries++
			if retries > 3 {
				return error(err)
			}
			continue
		}
		break
	}

	client.set_read_timeout(r.read_timeout)!
	client.set_write_timeout(r.write_timeout)!

	headers := r.build_headers(method, host, path)
	client.write(headers)!

	reader := bufio.reader(client)
	return parse_response(reader)
}
