module urllib

import strings

pub struct URL {
	scheme       string
	opaque       string    // encoded opaque data
	user         ?UserInfo // username and password information
	host         string    // host or host:port
	path         string    // path (relative paths may omit leading slash)
	raw_path     string    // encoded path hint (see `escaped_path` method)
	omit_host    bool      // do not emit empty host (authority)
	force_query  bool      // append a query ('?') even if `raw_query` is empty
	raw_query    string    // encoded query values, without '?'
	fragment     string    // fragment for references, without '#'
	raw_fragment string    // encoded fragment hint (see `EscapedFragment` method)
}

pub fn (u &URL) clone() -> URL {
	return URL{
		scheme: u.scheme
		opaque: u.opaque
		user: u.user
		host: u.host
		path: u.path
		raw_path: u.raw_path
		omit_host: u.omit_host
		force_query: u.force_query
		raw_query: u.raw_query
		fragment: u.fragment
		raw_fragment: u.raw_fragment
	}
}

pub fn (u &mut URL) str() -> string {
	mut buf := strings.new_builder(100)
	if u.scheme != '' {
		buf.write_str(u.scheme)
		buf.write_str(':')
	}
	if u.opaque != '' {
		buf.write_str(u.opaque)
	} else {
		if u.scheme != '' || u.host != '' || u.user != none {
			if u.host != '' || u.path != '' || u.user != none {
				buf.write_str('//')
			}
			if user := u.user {
				buf.write_str(user.str())
				buf.write_str('@')
			}
			if u.host != '' {
				buf.write_str(escape(u.host, .host))
			}
		}

		path := u.escaped_path()
		if path != '' && path[0] != `/` && u.host != '' {
			buf.write_str('/')
		}

		if buf.len == 0 {
			// RFC 3986 §4.2
			// A path segment that contains a colon character (e.g., 'this:that')
			// cannot be used as the first segment of a relative-path reference, as
			// it would be mistaken for a scheme name. Such a segment must be
			// preceded by a dot-segment (e.g., './this:that') to make a relative-
			// path reference.
			i := path.index_u8(b`:`)
			if i > -1 && path[..i].index_u8(b`/`) == -1 {
				buf.write_str('./')
			}
		}

		buf.write_str(path)
	}

	if u.force_query || u.raw_query != '' {
		buf.write_str('?')
		buf.write_str(u.raw_query)
	}
	if u.fragment != '' {
		buf.write_str('#')
		buf.write_str(escape(u.fragment, .fragment))
	}
	return buf.str_view()
}

pub fn (u &mut URL) set_fragment(f string) -> ! {
	frag := unescape(f, .fragment)!
	u.fragment = frag
	escf := escape(frag, .fragment)
	if f == escf {
		// Default encoding is fine.
		u.raw_fragment = ""
	} else {
		u.raw_fragment = f
	}
}

pub fn (u &mut URL) set_path(p string) -> ! {
	path := unescape(p, .path)!
	u.path = path
	escp := escape(path, .path)
	if p == escp {
		// Default encoding is fine.
		u.raw_path = ""
	} else {
		u.raw_path = p
	}
}

pub fn (u &mut URL) set_query_params(params map[string]string) {
	mut values := Values.new()

	for key, value in params {
		values.add(key, value)
	}

	encoded := values.encode()
	u.raw_query = encoded
}

pub fn (u &mut URL) escaped_path() -> string {
	if u.raw_path.len > 0 && valid_encoded(u.raw_path, .path) {
		if unescaped := unescape(u.raw_path, .path) {
			if unescaped == u.path {
				return u.raw_path
			}
		}
	}
	if u.path == "*" {
		return u.path
	}
	return escape(u.path, .path)
}

pub fn (u &mut URL) request_uri() -> string {
	mut result := u.opaque
	if result.len == 0 {
		result = u.escaped_path()
		if result.len == 0 {
			result = "/"
		}
	} else if result.starts_with("//") {
		result = u.scheme + ":" + result
	}

	if u.force_query || u.raw_query.len > 0 {
		result = result + "?" + u.raw_query
	}

	return result
}

pub fn (u &URL) hostname() -> string {
	host, _ := split_host_port(u.host)
	return host
}

pub fn (u &URL) port() -> string {
	_, port := split_host_port(u.host)
	return port
}

fn split_host_port(hostport string) -> (string, string) {
	i := hostport.last_index_u8(b`:`)
	if i != -1 && valid_optional_port(hostport[i..]) {
		return hostport[..i], hostport[i + 1..]
	}

	if hostport.starts_with('[') && hostport.ends_with(']') {
		return hostport[1..-1], ""
	}
	return hostport, ""
}

pub fn parse(raw string) -> !URL {
	u, frag := split_by_first(raw, b`#`)
	mut u2 := parse_impl(u, false)!
	if frag.len == 0 {
		return u2
	}

	u2.set_fragment(frag)!
	return u2
}

fn split_by_first(s string, delim u8) -> (string, string) {
	idx := s.index_u8(delim)
	if idx == -1 {
		return s, ''
	}
	return s[..idx], s[idx + 1..]
}

pub fn parse_request_uri(raw string) -> !URL {
	return parse_impl(raw, true)!
}

fn parse_impl(raw string, via_request bool) -> !URL {
	if string_contains_ctl_byte(raw) {
		return msg_err("net/url: invalid control character in URL")
	}

	if raw.len == 0 && via_request {
		return msg_err("net/url: empty url")
	}

	mut url := URL{}
	if raw == "*" {
		url.path = "*"
		return url
	}

	scheme, mut rest := get_scheme(raw)!
	url.scheme = scheme.to_lower()

	if rest.starts_with('?') && rest.count_u8(b`?`) == 1 {
		url.force_query = true
		rest = rest[1..]
	} else {
		rest, url.raw_query = split_by_first(rest, b`?`)
	}

	if !rest.starts_with('/') {
		if url.scheme.len > 0 {
			// We consider rootless paths per RFC 3986 as opaque.
			url.opaque = rest
			return url
		}
		if via_request {
			return msg_err("invalid URI for request")
		}

		// Avoid confusion with malformed schemes, like cache_object:foo/bar.
		// See golang.org/issue/16822.
		//
		// RFC 3986, §3.3:
		// In addition, a URI reference (Section 4.1) may be a relative-path reference,
		// in which case the first path segment cannot contain a colon (":") character.
		segment, _ := split_by_first(rest, b`/`)
		if segment.contains(':') {
			// First path segment has colon. Not allowed in relative URL.
			return msg_err("first path segment in URL cannot contain colon")
		}
	}

	if url.scheme.len > 0 || (!via_request && !rest.starts_with('///') && rest.starts_with('//')) {
		mut authority := ""
		authority, rest = rest[2..], ""
		if i := authority.index_u8_opt(b`/`) {
			authority, rest = authority[..i], authority[i..]
		}
		// url.user, url.host = parse_authority(authority)!
		us, host := parse_authority(authority)!
		url.user = us
		url.host = host
	} else if url.scheme.len != 0 && rest.starts_with('/') {
		// omit_host is set to true when rawURL has an empty host (authority).
		// See golang.org/issue/46059.
		url.omit_host = true
	}

	// Set Path and, optionally, RawPath.
	// RawPath is a hint of the encoding of Path. We don't want to set it if
	// the default escaping of Path is equivalent, to help make sure that people
	// don't rely on it in general.
	url.set_path(rest)!
	return url
}

fn parse_authority(authority string) -> !(?UserInfo, string) {
	mut host := ""
	i := authority.last_index_u8(b`@`)
	if i < 0 {
		host = parse_host(authority)!
	} else {
		host = parse_host(authority[i + 1..])!
	}
	if i < 0 {
		return none, host
	}

	// TODO:
	return none, host
}

fn parse_host(host string) -> !string {
	if host.starts_with('[') {
		// Parse an IP-Literal in RFC 3986 and RFC 6874.
		// E.g., "[fe80::1]", "[fe80::1%25en0]", "[fe80::1]:80".
		i := host.last_index_u8(b`]`)
		if i == -1 {
			return msg_err("missing ']' in host")
		}
		colon_part := host[i + 1..]
		if !valid_optional_port(colon_part) {
			return msg_err("invalid port ${colon_part} after host")
		}

		// RFC 6874 defines that %25 (%-encoded percent) introduces
		// the zone identifier, and the zone identifier can use basically
		// any %-encoding it likes. That's different from the host, which
		// can only %-encode non-ASCII bytes.
		// We do impose some restrictions on the zone, to avoid stupidity
		// like newlines.
		zone := host[..i].index('%25')
		if zone >= 0 {
			host1 := unescape(host[..zone], .host)!
			host2 := unescape(host[zone..i], .zone)!
			host3 := unescape(host[i..], .host)!
			return host1 + host2 + host3
		}
	}

	if i := host.index_u8_opt(b`:`) {
		colon_part := host[i..]
		if !valid_optional_port(colon_part) {
			return msg_err("invalid port ${colon_part} after host")
		}
	}

	return unescape(host, .host)
}

fn valid_optional_port(port string) -> bool {
	if port.len == 0 {
		return true
	}
	if port[0] != b`:` {
		return false
	}
	for i in port[1..] {
		if i < b`0` || i > b`9` {
			return false
		}
	}
	return true
}

fn get_scheme(raw string) -> !(string, string) {
	for i, ch in raw {
		if (b`a` <= ch && ch <= b`z`) || (b`A` <= ch && ch <= b`Z`) {
			// ok, continue
		} else if (b`0` <= ch && ch <= b`9`) || ch == b`+` || ch == b`-` || ch == b`.` {
			if i == 0 {
				return "", raw
			}
		} else if ch == b`:` {
			if i == 0 {
				return msg_err("missing protocol scheme")
			}
			return raw[..i], raw[i + 1..]
		} else {
			// we have encountered an invalid character,
			// so there is no valid scheme
			return "", raw
		}
	}
	return "", raw
}

pub fn user(name string) -> UserInfo {
	return UserInfo{ username: name }
}

pub fn user_password(name string, password string) -> UserInfo {
	return UserInfo{ username: name, password: password, password_set: true }
}

pub struct UserInfo {
	username     string
	password     string
	password_set bool
}

pub fn (u &UserInfo) username() -> string {
	return u.username
}

pub fn (u &UserInfo) password() -> string {
	return u.password
}

pub fn (u &UserInfo) str() -> string {
	return "" // TODO
}

fn string_contains_ctl_byte(s string) -> bool {
	for c in s {
		if c < b` ` || c == 0x7f {
			return true
		}
	}
	return false
}
