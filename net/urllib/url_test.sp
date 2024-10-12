module main

import net.urllib

test "simple url parsing" {
	url := "http://www.google.com"
	parsed := urllib.parse(url) or {
		t.fail("failed to parse url: ${err.msg()}")
		return
	}

	t.assert_eq(parsed.scheme, "http", "scheme must be http")
	t.assert_eq(parsed.host, "www.google.com", "host must be www.google.com")
	t.assert_eq(parsed.path, "", "path must be empty")
}
