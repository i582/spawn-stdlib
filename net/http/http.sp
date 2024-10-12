module http

// get sends a GET HTTP request to the given [`url`].
//
// If the response is one of the following redirect codes,
// [`get`] follows the redirect, up to a maximum of 16 redirects:
// - 301 (Moved Permanently)
// - 302 (Found)
// - 303 (See Other)
// - 307 (Temporary Redirect)
// - 308 (Permanent Redirect)
//
// An error is returned if there were too many redirects or if there
// was an HTTP protocol error. A non-2xx response doesn't cause an
// error.
pub fn get(url string) -> !Response {
	return fetch(FetchParams{
		url: url
		method: .get
	})
}

pub fn fetch(params FetchParams) -> !Response {
	if params.url.len == 0 {
		return error("http.fetch: url is empty")
	}

	mut req := Request{
		url: params.build_url() or { return error('http.fetch: invalid url "${params.url}": ${err.msg()}') }
		method: params.method
		headers: params.headers
		user_agent: params.user_agent
		ConnConfig: params.ConnConfig
	}
	return req.do()
}
