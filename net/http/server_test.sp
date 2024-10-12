module main

import net.http
import time

struct SimpleHandler {}

fn (s &mut SimpleHandler) serve_http(rw http.ResponseWriter, r &http.Request) -> !http.Response {
	match r.url.path {
		'/' => {
			rw.headers().set("Content-Type", "text/plain")
			rw.write_string("Hello, World!")!
		}
		'users' => {
			rw.headers().set("Content-Type", "text/json")
			rw.write_string('{"name": "John Doe"}')!
		}
	}

	return http.Response{}
}

#[skip]
test "simple http server" {
	h := spawn fn () {
		http.listen_and_serve('localhost:8756', SimpleHandler{}).unwrap()
	}()

	// wait for the server to start
	time.sleep(2000 * time.MILLISECOND)

	// test the server
	mut res := http.get('http://localhost:8756/') or {
		t.fail("failed to get response from root")
		return
	}

	t.assert_eq(res.status_code, 200, "status code should be 200")
	body := res.read_body() or {
		t.fail("failed to read response body")
		return
	}
	t.assert_eq(body.ascii_str(), "Hello, World!", "response body should be 'Hello, World!'")

	// stop the server
	h.cancel()
}
