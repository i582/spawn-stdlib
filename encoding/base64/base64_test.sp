module main

import encoding.base64

const CASES = [
	// RFC 3548 examples
	("\x14\xfb\x9c\x03\xd9\x7e", "FPucA9l+"),
	("\x14\xfb\x9c\x03\xd9", "FPucA9k="),
	("\x14\xfb\x9c\x03", "FPucAw=="),
	// RFC 4648 examples
	("", ""),
	("f", "Zg=="),
	("fo", "Zm8="),
	("foo", "Zm9v"),
	("foob", "Zm9vYg=="),
	("fooba", "Zm9vYmE="),
	("foobar", "Zm9vYmFy"),
	// Wikipedia examples
	("sure.", "c3VyZS4="),
	("sure", "c3VyZQ=="),
	("sur", "c3Vy"),
	("su", "c3U="),
	("leasure.", "bGVhc3VyZS4="),
	("easure.", "ZWFzdXJlLg=="),
	("asure.", "YXN1cmUu"),
	("sure.", "c3VyZS4="),
]

test "base64 encode string" {
	for case in CASES {
		data, encoded := case
		t.assert_eq(base64.encode_str(data), encoded, "actual should be equal to expected")
	}
}

test "base64 encoded len" {
	cases := [
		(base64.std_encoding, 0, 0),
		(base64.std_encoding, 1, 4),
		(base64.std_encoding, 2, 4),
		(base64.std_encoding, 3, 4),
		(base64.std_encoding, 4, 8),
		(base64.std_encoding, 7, 12),
	]

	for case in cases {
		enc, len, encoded_len := case
		t.assert_eq(enc.encoded_len(len), encoded_len, "actual should be equal to expected")
	}
}

test "base64 decode string" {
	for case in CASES {
		decoded, encoded := case
		t.assert_eq(base64.decode_str(encoded).unwrap(), decoded, "actual should be equal to expected")
	}
}

test "base64 decoded len" {
	cases := [
		(base64.std_encoding, 0, 0),
		(base64.std_encoding, 4, 3),
		(base64.std_encoding, 8, 6),
	]

	for case in cases {
		enc, len, encoded_len := case
		t.assert_eq(enc.decoded_len(len), encoded_len, "actual should be equal to expected")
	}
}

test "big input" {
	alpha := "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	n := (3 * 1000 + 1) as usize
	mut raw := []u8{len: n}
	for i in 0 .. n {
		raw[i] = alpha[i % alpha.len]
	}

	res := base64.encode(raw)
	decoded := base64.decode(res).unwrap()

	t.assert_eq(raw.ascii_str().str(), decoded.ascii_str().str(), "actual should be equal to expected")
}
