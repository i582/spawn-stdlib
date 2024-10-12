module main

import time
import net.http

#[slow]
test "simple http request" {
	res := http.get('http://example.com') or {
		t.fail("failed to get http://example.com: ${err.msg()}")
		return
	}

	t.assert_eq(res.status_code, 200, "status code must be 200")
}

#[slow]
test "get request to httpbin by http" {
	res := http.get('http://httpbin.org/get') or {
		t.fail("failed to get http://httpbin.org/get: ${err.msg()}")
		return
	}
	t.assert_eq(res.status_code, 200, "status code must be 200")

	date := res.headers.get("Date", false).expect('no Date header')
	parsed := time.parse(time.RFC1123, date).expect('Date value is invalid')
	now := time.now()
	t.assert_eq(parsed.month, now.month, 'month from header should be equal to nowday month: date: ${date}')

	content_type := res.headers.get("Content-Type", false).expect('no Content-Type header')
	t.assert_eq(content_type, 'application/json', 'unexpected content type')
}

#[slow]
test "get request to httpbin by https" {
	res := http.get('https://httpbin.org/get') or {
		t.fail("failed to get https://httpbin.org/get: ${err.msg()}")
		return
	}
	t.assert_eq(res.status_code, 200, "status code must be 200")

	date := res.headers.get("Date", false).expect('no Date header')
	parsed := time.parse(time.RFC1123, date).expect('Date value is invalid')
	now := time.now()
	t.assert_eq(parsed.month, now.month, 'month from header should be equal to nowday month: date: ${date}')

	content_type := res.headers.get("Content-Type", false).expect('no Content-Type header')
	t.assert_eq(content_type, 'application/json', 'unexpected content type')
}

#[slow]
test "get request to httpbin by http with very low read timeout" {
	mut req := http.Request.get('http://httpbin.org/get', none).unwrap()
	req.read_timeout = 100 * time.MICROSECOND

	res := req.do() or {
		t.assert_true(err.msg().contains('timeout'), 'error should be timeout')
		return
	}

	t.fail("request should fail with timeout")
}

#[slow]
test "get request to httpbin by https with very low read timeout" {
	mut req := http.Request.get('https://httpbin.org/get', none).unwrap()
	req.read_timeout = 100 * time.MICROSECOND

	res := req.do() or {
		t.assert_true(err.msg().contains('timeout'), 'error should be timeout')
		return
	}

	t.fail("request should fail with timeout")
}

#[slow]
test "http request to non-existing host" {
	http.get('http://non-existing-host') or {
		return
	}

	t.fail("request to non-existing host should fail")
}

#[slow]
test "simple https request" {
	res := http.get('https://example.com') or {
		t.fail("failed to get https://example.com: ${err.msg()}")
		return
	}

	t.assert_eq(res.status_code, 200, "status code must be 200")
}

#[slow]
test "https request to non-existing host" {
	http.get('https://non-existing-host') or {
		return
	}

	t.fail("request to non-existing host should fail")
}

#[slow]
test "https request with redirect" {
	res := http.get('https://google.com') or {
		t.fail("failed to get https://google.com: ${err.msg()}")
		return
	}

	t.assert_eq(res.status_code, 200, "status code must be 200")
}
