module main

import encoding.leb128

test "encode and decode i64" {
	cases := [
		(-1234567890123456789 as i64, [0xeb as u8, 0xfd, 0xd9, 0x90, 0xb8, 0xe1, 0xfb, 0xee, 0x6e], 9),
		(0 as i64, [0x00 as u8], 1),
		(123456789 as i64, [0x95 as u8, 0x9a, 0xef, 0x3a], 4),
		(624485 as i64, [0xe5 as u8, 0x8e, 0x26], 3),
		(-1 as i64, [0x7f as u8], 1),
		(-9223372036854775808 as i64, [0x80 as u8, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x7f], 10),
		(0x3fffffffffffffff as i64, [0xff as u8, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x3f], 9),
		(0x7fffffffffffffff as i64, [0xff as u8, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x0], 10),
	]

	for case in cases {
		value, encoded, size := case
		mut buffer := []u8{len: 20}
		encoded_size := leb128.encode_i64(value, &mut buffer)
		t.assert_eq(buffer[..encoded_size].str(), encoded.str(), "encoding failed for i64 value ${value}")

		decoded, bytes_read := leb128.decode_i64(buffer[..encoded_size])
		t.assert_eq(decoded, value, "decoding failed for i64 value ${value}")
		t.assert_eq(bytes_read, size, "incorrect number of bytes read for i64 value ${value}")
	}
}

test "encode and decode u64" {
	cases := [
		(1234567890123456789 as u64, [0x95 as u8, 0x82, 0xa6, 0xef, 0xc7, 0x9e, 0x84, 0x91, 0x11], 9),
		(0 as u64, [0x00 as u8], 1),
		(987654321 as u64, [0xb1 as u8, 0xd1, 0xf9, 0xd6, 0x3], 5),
		(624485 as u64, [0xe5 as u8, 0x8e, 0x26], 3),
		(0x01 as u64, [0x01 as u8], 1),
		(0x7f as u64, [0x7f as u8], 1),
		(0x80 as u64, [0x80 as u8, 0x01 as u8], 2),
		(0x3fffffffffffffff as u64, [0xff as u8, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x3f], 9),
		(0xffffffffffffffff as u64, [0xff as u8, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x1], 10),
	]

	for case in cases {
		value, encoded, size := case
		mut buffer := []u8{len: 20}
		encoded_size := leb128.encode_u64(value, &mut buffer)
		t.assert_eq(buffer[..encoded_size].str(), encoded.str(), "encoding failed for u64 value ${value}")

		decoded, bytes_read := leb128.decode_u64(buffer[..encoded_size])
		t.assert_eq(decoded, value, "decoding failed for u64 value ${value}")
		t.assert_eq(bytes_read, size, "incorrect number of bytes read for u64 value ${value}")
	}
}
