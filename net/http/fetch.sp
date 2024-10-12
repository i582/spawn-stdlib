module http

import net.openssl
import net.urllib

pub struct FetchParams {
	url        string
	method     Method            = .get
	headers    Headers
	data       string
	params     map[string]string
	cookies    map[string]string
	user_agent string            = 'spawn.http'

	openssl.ConnConfig
}

pub fn (f &FetchParams) build_url() -> !urllib.URL {
	mut parsed := urllib.parse(f.url)!

	if f.params.len == 0 {
		return parsed
	}

	parsed.set_query_params(f.params)
	return parsed
}
