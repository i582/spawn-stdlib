module http

import net
import time
import bufio
import strings
import net.urllib
import net.openssl

// MAX_REDIRECTS is the maximum number of redirects that the client will follow.
// If the server sends more than this number of redirects, the client will return an error.
//
// 16 is the maximum number of redirects that most browsers will follow.
const MAX_REDIRECTS = 16

pub struct Request {
	version    Version    = .v1_1
	method     Method     = .get
	headers    Headers
	host       string
	url        urllib.URL
	user_agent string     = 'spawn.http'
	data       []u8

	// allow_redirect specifies whether the client should follow HTTP redirects.
	// If false, the client will return the first response it receives, even if it is a redirect.
	allow_redirect bool = true

	read_timeout  time.Duration = 30 as i64 * time.SECOND
	write_timeout time.Duration = 30 as i64 * time.SECOND

	// validate sets whether the client should validate the server's certificate chain and host name.
	// When true, certificate failures will stop further processing.
	validate bool
	openssl.ConnConfig

	body ?&mut bufio.Reader
}

// new creates a new [`Request`] with the given method, URL, get data, and post data.
//
// To create post or get requests, use the [`Request.post`] and [`Request.get`] methods.
//
// If url is invalid, this function returns an error.
pub fn Request.new(method Method, url string, get_data ?urllib.Values, post_data ?[]u8) -> !Request {
	final_url := if get_data != none && method == .get {
		'${url}?${get_data.encode()}'
	} else {
		url
	}

	return Request{
		method: method
		headers: Headers{}
		url: urllib.parse(final_url)!
		data: post_data or { [] }
	}
}

pub fn Request.post(url string, data []u8) -> !Request {
	return Request.new(.post, url, none, data)
}

pub fn Request.get(url string, data ?urllib.Values) -> !Request {
	return Request.new(.get, url, data, none)
}

pub fn (r &mut Request) do() -> !Response {
	mut url := r.url

	mut response := Response{}
	mut redirects := 0

	for {
		if redirects > MAX_REDIRECTS {
			return error("http.request.do: maximum number of redirects reached: ${MAX_REDIRECTS}")
		}

		response = r.do_with_url(url)!

		if response.status_code !in [.moved_permanently, .found, .see_other, .temporary_redirect, .permanent_redirect] {
			break
		}

		if !r.allow_redirect {
			break
		}

		mut redirect_url := response.headers.get("Location", false) or { '' }
		if redirect_url == '' {
			break
		}

		if redirect_url[0] == b`/` {
			mut cloned := url.clone()
			cloned.set_path(redirect_url) or {
				return error("http.request.do: invalid path in redirect: ${redirect_url}: ${err.msg()}")
			}
			redirect_url = cloned.str()
		}

		redirect_parsed := urllib.parse(redirect_url.clone()) or {
			return error("http.request.do: invalid redirect URL: ${redirect_url}: ${err.msg()}")
		}

		url = redirect_parsed
		redirects++
	}

	return response
}

pub fn (r &mut Request) do_with_url(mut url urllib.URL) -> !Response {
	scheme := url.scheme
	path := url.request_uri()

	if scheme == "http" {
		host := canonical_addr(&url)
		return r.http_do(r.method, host, path)
	}

	if scheme == "https" {
		host := url.hostname()
		port := url.port().i32_or(443)
		return r.ssl_do(r.method, host, port, path)
	}

	if scheme == "" {
		return error('empty scheme')
	}

	return error('unsupported scheme "${scheme}"')
}

fn canonical_addr(url &urllib.URL) -> string {
	host := url.hostname()
	mut port := url.port()
	if port.len == 0 {
		port = match url.scheme {
			"http" => "80"
			"https" => "443"
			"socks5" => "1080"
			else => ""
		}
	}
	return net.join_host_port(host, port)
}

pub fn (r &mut Request) http_do(method Method, host string, path string) -> !Response {
	headers := r.build_headers(method, host, path)
	mut client := net.dial_tcp(host)!
	client.set_read_timeout(r.read_timeout)!
	client.set_write_timeout(r.write_timeout)!
	client.write(headers)!

	reader := bufio.reader(client)
	return parse_response(reader)
}

pub fn (r &mut Request) build_headers(method Method, host_name string, path string) -> []u8 {
	mut sb := strings.new_builder(100)

	sb.write_str(method.str())
	sb.write_u8(b` `)
	sb.write_str(path)
	sb.write_u8(b` `)
	sb.write_str(if r.version == .unknown { "HTTP/1.1" } else { r.version.str() })
	sb.write_u8(b`\r`)
	sb.write_u8(b`\n`)

	if 'Host' !in r.headers {
		r.headers.set('Host', host_name)
	}
	if 'User-Agent' !in r.headers {
		r.headers.set('User-Agent', r.user_agent)
	}

	if r.data.len > 0 && 'Content-Length' !in r.headers {
		r.headers.set('Content-Length', r.data.len.str())
	}
	r.headers.set('Connection', 'close')

	r.headers.render_to(&mut sb)
	r.headers.clear()

	sb.write_str("\r\n\r\n")
	sb.write(r.data) or {}

	return sb.as_array()
}

pub fn (r &mut Request) read_body() -> ![]u8 {
	content_length_str := r.headers.get("Content-Length", false) or { return [] }

	len := content_length_str.i32()
	if len == 0 {
		return []
	}
	if len < 0 {
		return error("invalid Content-Length")
	}

	req_body := r.body or { return [] } // TODO: error here?

	mut body := []u8{len: len}
	req_body.read(&mut body)!
	return body
}

pub fn (r &Request) query() -> urllib.Values {
	return urllib.parse_query(r.url.raw_query) or { urllib.Values{} }
}

pub fn parse_request(reader &mut bufio.Reader) -> !Request {
	mut request := parse_request_head(reader)!
	request.body = reader
	return request
}

pub fn parse_request_head(reader &mut bufio.Reader) -> !Request {
	line, _ := reader.read_line()!
	method, url, version := parse_request_line(string.view_from_bytes(line))!

	headers := parse_headers_from_reader(reader)!

	return Request{
		version: version
		method: method
		headers: headers
		host: headers.get("Host", false) or { '' }
		url: urllib.parse(url)!
	}
}

pub fn parse_request_line(data string) -> !(Method, string, Version) {
	space1 := data.index_u8(b` `)
	space2 := data.index_after(space1 + 1, ' ')
	if space1 == -1 || space2 == -1 {
		return error("malformed request line")
	}
	method_str := data[0..space1]
	path_str := data[space1 + 1..space2]
	version_str := data[space2 + 1..]

	version := Version.from_str(version_str)
	if version == .unknown {
		return error("unsupported version ${version_str}")
	}

	return Method.from_str(method_str), path_str, version
}
