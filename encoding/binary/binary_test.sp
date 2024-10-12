module main

import encoding.binary

test "little endian u16" {
	cases := [
		([0 as u8, 0], 0 as u16),
		([5 as u8, 4], 0x0405 as u16),
		([0x35 as u8, 0x57], 0x5735 as u16),
	]

	for case in cases {
		buf, expected := case
		t.assert_eq(binary.LittleEndian.u16(buf), expected, "actual should be equal to expected")
	}
}

test "little endian u16 at" {
	cases := [
		([1 as u8, 0, 0, 1], 1, 0 as u16),
		([5 as u8, 4, 9, 1], 1, 0x0904 as u16),
		([0xf8 as u8, 0xa2, 0x9e, 0x21], 1, 0x9ea2 as u16),
	]

	for case in cases {
		buf, at, expected := case
		t.assert_eq(binary.LittleEndian.u16_at(buf, at), expected, "actual should be equal to expected")
	}
}

test "little endian u16 end" {
	cases := [
		([1 as u8, 0, 0, 1], 0x0100 as u16),
		([5 as u8, 4, 9, 1], 0x0109 as u16),
		([0xf8 as u8, 0xa2, 0x9e, 0x21], 0x219e as u16),
	]

	for case in cases {
		buf, expected := case
		t.assert_eq(binary.LittleEndian.u16_end(buf), expected, "actual should be equal to expected")
	}
}

test "little endian put u16" {
	mut buf := []u8{len: 2}
	binary.LittleEndian.put_u16(&mut buf, 0x8725)
	t.assert_eq(buf.str(), [0x25, 0x87].str(), "actual should be equal to expected")
	binary.LittleEndian.put_u16(&mut buf, 0)
	t.assert_eq(buf.str(), [0, 0].str(), "actual should be equal to expected")
	binary.LittleEndian.put_u16(&mut buf, 0xfdff)
	t.assert_eq(buf.str(), [0xff, 0xfd].str(), "actual should be equal to expected")
}

test "little endian put u16 at" {
	mut buf := []u8{len: 4}
	binary.LittleEndian.put_u16_at(&mut buf, 0x8725, 1)
	t.assert_eq(buf.str(), [0, 0x25, 0x87, 0].str(), "actual should be equal to expected")

	buf = []u8{len: 4}
	binary.LittleEndian.put_u16_at(&mut buf, 1, 1)
	t.assert_eq(buf.str(), [0, 1, 0, 0].str(), "actual should be equal to expected")

	buf = []u8{len: 4}
	binary.LittleEndian.put_u16_at(&mut buf, 0xfdff, 1)
	t.assert_eq(buf.str(), [0, 0xff, 0xfd, 0].str(), "actual should be equal to expected")
}

test "little endian put u16 end" {
	mut buf := []u8{len: 4}
	binary.LittleEndian.put_u16_end(&mut buf, 0x8725)
	t.assert_eq(buf.str(), [0, 0, 0x25, 0x87].str(), "actual should be equal to expected")

	buf = []u8{len: 4}
	binary.LittleEndian.put_u16_end(&mut buf, 1)
	t.assert_eq(buf.str(), [0, 0, 1, 0].str(), "actual should be equal to expected")

	buf = []u8{len: 4}
	binary.LittleEndian.put_u16_end(&mut buf, 0xfdff)
	t.assert_eq(buf.str(), [0, 0, 0xff, 0xfd].str(), "actual should be equal to expected")
}

test "little endian u32" {
	cases := [
		([0 as u8, 0, 0, 0], 0 as u32),
		([5 as u8, 4, 9, 1], 0x01090405 as u32),
		([0xf8 as u8, 0xa2, 0x9e, 0x21], 0x219ea2f8 as u32),
	]

	for case in cases {
		buf, expected := case
		t.assert_eq(binary.LittleEndian.u32(buf), expected, "actual should be equal to expected")
	}
}

test "little endian u32 at" {
	cases := [
		([1 as u8, 0, 0, 0, 0, 0, 0, 0], 1, 0 as u32),
		([5 as u8, 4, 9, 1, 7, 3, 6, 8], 1, 0x07010904 as u32),
		([0xf8 as u8, 0xa2, 0x9e, 0x21, 0x7f, 0x9f, 0x8e, 0x8f], 1, 0x7f219ea2 as u32),
	]

	for case in cases {
		buf, at, expected := case
		t.assert_eq(binary.LittleEndian.u32_at(buf, at), expected, "actual should be equal to expected")
	}
}

test "little endian u32 end" {
	cases := [
		([1 as u8, 0, 0, 0, 0, 0, 0, 0], 0 as u32),
		([5 as u8, 4, 9, 1, 7, 3, 6, 8], 0x08060307 as u32),
		([0xf8 as u8, 0xa2, 0x9e, 0x21, 0x7f, 0x9f, 0x8e, 0x8f], 0x8f8e9f7f as u32),
	]

	for case in cases {
		buf, expected := case
		t.assert_eq(binary.LittleEndian.u32_end(buf), expected, "actual should be equal to expected")
	}
}

test "little endian put u32" {
	mut buf := []u8{len: 4}
	binary.LittleEndian.put_u32(&mut buf, 0x872fea95 as u32)
	t.assert_eq(buf.str(), [0x95, 0xea, 0x2f, 0x87].str(), "actual should be equal to expected")
	binary.LittleEndian.put_u32(&mut buf, 0)
	t.assert_eq(buf.str(), [0, 0, 0, 0].str(), "actual should be equal to expected")
	binary.LittleEndian.put_u32(&mut buf, 0xfdf2e68f as u32)
	t.assert_eq(buf.str(), [0x8f, 0xe6, 0xf2, 0xfd].str(), "actual should be equal to expected")
}

test "little endian put u32 at" {
	mut buf := []u8{len: 8}
	binary.LittleEndian.put_u32_at(&mut buf, 0x8725, 2)
	t.assert_eq(buf.str(), [0, 0, 0x25, 0x87, 0, 0, 0, 0].str(), "actual should be equal to expected")

	buf = []u8{len: 8}
	binary.LittleEndian.put_u32_at(&mut buf, 0x12345678 as u32, 0)
	t.assert_eq(buf.str(), [0x78, 0x56, 0x34, 0x12, 0, 0, 0, 0].str(), "actual should be equal to expected")

	buf = []u8{len: 8}
	binary.LittleEndian.put_u32_at(&mut buf, 0xffffffff as u32, 4)
	t.assert_eq(buf.str(), [0, 0, 0, 0, 0xff, 0xff, 0xff, 0xff].str(), "actual should be equal to expected")
}

test "little endian put u32 end" {
	mut buf := []u8{len: 8}
	binary.LittleEndian.put_u32_end(&mut buf, 0x8725)
	t.assert_eq(buf.str(), [0, 0, 0, 0, 0x25, 0x87, 0, 0].str(), "actual should be equal to expected")

	buf = []u8{len: 8}
	binary.LittleEndian.put_u32_end(&mut buf, 0x12345678 as u32)
	t.assert_eq(buf.str(), [0, 0, 0, 0, 0x78, 0x56, 0x34, 0x12].str(), "actual should be equal to expected")

	buf = []u8{len: 8}
	binary.LittleEndian.put_u32_end(&mut buf, 0xffffffff as u32)
	t.assert_eq(buf.str(), [0, 0, 0, 0, 0xff, 0xff, 0xff, 0xff].str(), "actual should be equal to expected")
}

test "little endian u64" {
	cases := [
		([0 as u8, 0, 0, 0, 0, 0, 0, 0], 0 as u64),
		([5 as u8, 4, 9, 1, 7, 3, 6, 8], 0x0806030701090405 as u64),
		([0xf8 as u8, 0xa2, 0x9e, 0x21, 0x7f, 0x9f, 0x8e, 0x8f], 0x8f8e9f7f219ea2f8 as u64),
	]

	for case in cases {
		buf, expected := case
		t.assert_eq(binary.LittleEndian.u64(buf), expected, "actual should be equal to expected")
	}
}

test "little endian u64 at" {
	cases := [
		([0 as u8, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1], 0, 0 as u64),
		([5 as u8, 4, 9, 1, 7, 3, 6, 8, 0, 0, 0, 0, 0, 0, 0], 0, 0x0806030701090405 as u64),
		([0xf8 as u8, 0xa2, 0x9e, 0x21, 0x7f, 0x9f, 0x8e, 0x8f, 0, 0, 0, 0, 0, 0, 0], 0, 0x8f8e9f7f219ea2f8 as u64),
	]

	for case in cases {
		buf, at, expected := case
		t.assert_eq(binary.LittleEndian.u64_at(buf, at), expected, "actual should be equal to expected")
	}
}

test "little endian u64 end" {
	cases := [
		([0 as u8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 0 as u64),
		([0 as u8, 0, 0, 0, 0, 0, 0, 0, 5, 4, 9, 1, 7, 3, 6, 8], 0x0806030701090405 as u64),
		([0 as u8, 0, 0, 0, 0, 0, 0, 0, 0xf8, 0xa2, 0x9e, 0x21, 0x7f, 0x9f, 0x8e, 0x8f], 0x8f8e9f7f219ea2f8 as u64),
	]

	for case in cases {
		buf, expected := case
		t.assert_eq(binary.LittleEndian.u64_end(buf), expected, "actual should be equal to expected")
	}
}

test "little endian put u64" {
	mut buf := []u8{len: 8}
	binary.LittleEndian.put_u64(&mut buf, 0x872fea95fdf2e68f as u64)
	t.assert_eq(buf.str(), [0x8f, 0xe6, 0xf2, 0xfd, 0x95, 0xea, 0x2f, 0x87].str(), "actual should be equal to expected")
	binary.LittleEndian.put_u64(&mut buf, 0)
	t.assert_eq(buf.str(), [0, 0, 0, 0, 0, 0, 0, 0].str(), "actual should be equal to expected")
	binary.LittleEndian.put_u64(&mut buf, 0xfdf2e68f8e9f7f21 as u64)
	t.assert_eq(buf.str(), [0x21, 0x7f, 0x9f, 0x8e, 0x8f, 0xe6, 0xf2, 0xfd].str(), "actual should be equal to expected")
}

test "little endian put u64 at" {
	mut buf := []u8{len: 16}
	binary.LittleEndian.put_u64_at(&mut buf, 0x872fea95fdf2e68f as u64, 1)
	t.assert_eq(buf.str(), [0, 0x8f, 0xe6, 0xf2, 0xfd, 0x95, 0xea, 0x2f, 0x87, 0, 0, 0, 0, 0, 0, 0].str(), "actual should be equal to expected")

	buf = []u8{len: 16}
	binary.LittleEndian.put_u64_at(&mut buf, 1, 1)
	t.assert_eq(buf.str(), [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0].str(), "actual should be equal to expected")

	buf = []u8{len: 16}
	binary.LittleEndian.put_u64_at(&mut buf, 0xfdf2e68f8e9f7f21 as u64, 1)
	t.assert_eq(buf.str(), [0, 0x21, 0x7f, 0x9f, 0x8e, 0x8f, 0xe6, 0xf2, 0xfd, 0, 0, 0, 0, 0, 0, 0].str(), "actual should be equal to expected")
}

test "little endian put u64 end" {
	mut buf := []u8{len: 16}
	binary.LittleEndian.put_u64_end(&mut buf, 0x872fea95fdf2e68f as u64)
	t.assert_eq(buf.str(), [0, 0, 0, 0, 0, 0, 0, 0, 0x8f, 0xe6, 0xf2, 0xfd, 0x95, 0xea, 0x2f, 0x87].str(), "actual should be equal to expected")

	buf = []u8{len: 16}
	binary.LittleEndian.put_u64_end(&mut buf, 1)
	t.assert_eq(buf.str(), [0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0].str(), "actual should be equal to expected")

	buf = []u8{len: 16}
	binary.LittleEndian.put_u64_end(&mut buf, 0xfdf2e68f8e9f7f21 as u64)
	t.assert_eq(buf.str(), [0, 0, 0, 0, 0, 0, 0, 0, 0x21, 0x7f, 0x9f, 0x8e, 0x8f, 0xe6, 0xf2, 0xfd].str(), "actual should be equal to expected")
}

test "big endian u16" {
	cases := [
		([0 as u8, 0], 0 as u16),
		([4 as u8, 5], 0x0405 as u16),
		([0x57 as u8, 0x35], 0x5735 as u16),
	]

	for case in cases {
		buf, expected := case
		t.assert_eq(binary.BigEndian.u16(buf), expected, "actual should be equal to expected")
	}
}

test "big endian u16 at" {
	cases := [
		([1 as u8, 0, 0, 1], 1, 0 as u16),
		([5 as u8, 4, 9, 1], 1, 0x409 as u16),
		([0xf8 as u8, 0xa2, 0x9e, 0x21], 1, 0xa29e as u16),
	]

	for case in cases {
		buf, at, expected := case
		t.assert_eq(binary.BigEndian.u16_at(buf, at).hex_prefixed(), expected.hex_prefixed(), "actual should be equal to expected")
	}
}

test "big endian u16 end" {
	cases := [
		([1 as u8, 0, 0, 1], 0x1 as u16),
		([5 as u8, 4, 9, 1], 0x901 as u16),
		([0xf8 as u8, 0xa2, 0x9e, 0x21], 0x9e21 as u16),
	]

	for case in cases {
		buf, expected := case
		t.assert_eq(binary.BigEndian.u16_end(buf).hex_prefixed(), expected.hex_prefixed(), "actual should be equal to expected")
	}
}

test "big endian put u16" {
	mut buf := []u8{len: 2}
	binary.BigEndian.put_u16(&mut buf, 0x8725)
	t.assert_eq(buf.str(), [0x87, 0x25].str(), "actual should be equal to expected")
	binary.BigEndian.put_u16(&mut buf, 0)
	t.assert_eq(buf.str(), [0, 0].str(), "actual should be equal to expected")
	binary.BigEndian.put_u16(&mut buf, 0xfdff)
	t.assert_eq(buf.str(), [0xfd, 0xff].str(), "actual should be equal to expected")
}

test "big endian put u16 at" {
	mut buf := []u8{len: 4}
	binary.BigEndian.put_u16_at(&mut buf, 0x8725, 1)
	t.assert_eq(buf.str(), [0, 0x87, 0x25, 0].str(), "actual should be equal to expected")

	buf = []u8{len: 4}
	binary.BigEndian.put_u16_at(&mut buf, 1, 1)
	t.assert_eq(buf.str(), [0, 0, 1, 0].str(), "actual should be equal to expected")

	buf = []u8{len: 4}
	binary.BigEndian.put_u16_at(&mut buf, 0xfdff, 1)
	t.assert_eq(buf.str(), [0, 0xfd, 0xff, 0].str(), "actual should be equal to expected")
}

test "big endian put u16 end" {
	mut buf := []u8{len: 4}
	binary.BigEndian.put_u16_end(&mut buf, 0x8725)
	t.assert_eq(buf.str(), [0, 0, 0x87, 0x25].str(), "actual should be equal to expected")

	buf = []u8{len: 4}
	binary.BigEndian.put_u16_end(&mut buf, 1)
	t.assert_eq(buf.str(), [0, 0, 0, 1].str(), "actual should be equal to expected")

	buf = []u8{len: 4}
	binary.BigEndian.put_u16_end(&mut buf, 0xfdff)
	t.assert_eq(buf.str(), [0, 0, 0xfd, 0xff].str(), "actual should be equal to expected")
}

test "big endian u32" {
	cases := [
		([0 as u8, 0, 0, 0], 0 as u32),
		([1 as u8, 9, 4, 5], 0x01090405 as u32),
		([0x21 as u8, 0x9e, 0xa2, 0xf8], 0x219ea2f8 as u32),
	]

	for case in cases {
		buf, expected := case
		t.assert_eq(binary.BigEndian.u32(buf), expected, "actual should be equal to expected")
	}
}

test "big endian u32 at" {
	cases := [
		([0 as u8, 0, 0, 0, 0, 0, 0, 0], 0, 0 as u32),
		([1 as u8, 9, 4, 5, 0, 0, 0, 0], 0, 0x01090405 as u32),
		([0x21 as u8, 0x9e, 0xa2, 0xf8, 0, 0, 0, 0], 0, 0x219ea2f8 as u32),
	]

	for case in cases {
		buf, at, expected := case
		t.assert_eq(binary.BigEndian.u32_at(buf, at), expected, "actual should be equal to expected")
	}
}

test "big endian u32 end" {
	cases := [
		([0 as u8, 0, 0, 0, 0, 0, 0, 0], 0 as u32),
		([0 as u8, 0, 0, 0, 1, 9, 4, 5], 0x01090405 as u32),
		([0 as u8, 0, 0, 0, 0x21, 0x9e, 0xa2, 0xf8], 0x219ea2f8 as u32),
	]

	for case in cases {
		buf, expected := case
		t.assert_eq(binary.BigEndian.u32_end(buf), expected, "actual should be equal to expected")
	}
}

test "big endian put u32" {
	mut buf := []u8{len: 4}
	binary.BigEndian.put_u32(&mut buf, 0x872fea95 as u32)
	t.assert_eq(buf.str(), [0x87, 0x2f, 0xea, 0x95].str(), "actual should be equal to expected")
	binary.BigEndian.put_u32(&mut buf, 0)
	t.assert_eq(buf.str(), [0, 0, 0, 0].str(), "actual should be equal to expected")
	binary.BigEndian.put_u32(&mut buf, 0xfdf2e68f as u32)
	t.assert_eq(buf.str(), [0xfd, 0xf2, 0xe6, 0x8f].str(), "actual should be equal to expected")
}

test "big endian put u32 at" {
	mut buf := []u8{len: 8}
	binary.BigEndian.put_u32_at(&mut buf, 0x8725, 2)
	t.assert_eq(buf.str(), [0, 0, 0, 0, 0x87, 0x25, 0, 0].str(), "actual should be equal to expected")

	buf = []u8{len: 8}
	binary.BigEndian.put_u32_at(&mut buf, 0x12345678 as u32, 0)
	t.assert_eq(buf.str(), [0x12, 0x34, 0x56, 0x78, 0, 0, 0, 0].str(), "actual should be equal to expected")

	buf = []u8{len: 8}
	binary.BigEndian.put_u32_at(&mut buf, 0xffffffff as u32, 4)
	t.assert_eq(buf.str(), [0, 0, 0, 0, 0xff, 0xff, 0xff, 0xff].str(), "actual should be equal to expected")
}

test "big endian put u32 end" {
	mut buf := []u8{len: 8}
	binary.BigEndian.put_u32_end(&mut buf, 0x8725)
	t.assert_eq(buf.str(), [0, 0, 0, 0, 0, 0, 0x87, 0x25].str(), "actual should be equal to expected")

	buf = []u8{len: 8}
	binary.BigEndian.put_u32_end(&mut buf, 0x12345678 as u32)
	t.assert_eq(buf.str(), [0, 0, 0, 0, 0x12, 0x34, 0x56, 0x78].str(), "actual should be equal to expected")

	buf = []u8{len: 8}
	binary.BigEndian.put_u32_end(&mut buf, 0xffffffff as u32)
	t.assert_eq(buf.str(), [0, 0, 0, 0, 0xff, 0xff, 0xff, 0xff].str(), "actual should be equal to expected")
}

test "big endian u64" {
	cases := [
		([0 as u8, 0, 0, 0, 0, 0, 0, 0], 0 as u64),
		([0x01 as u8, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08], 0x0102030405060708 as u64),
		([0xff as u8, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff], 0xffffffffffffffff as u64),
	]

	for case in cases {
		buf, expected := case
		t.assert_eq(binary.BigEndian.u64(buf), expected, "actual should be equal to expected")
	}
}

test "big endian u64 at" {
	cases := [
		([0 as u8, 0, 0, 0, 0, 0, 0, 0, 0, 0], 0, 0 as u64),
		([0x01 as u8, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0, 0], 0, 0x0102030405060708 as u64),
		([0xff as u8, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0, 0], 0, 0xffffffffffffffff as u64),
	]

	for case in cases {
		buf, at, expected := case
		t.assert_eq(binary.BigEndian.u64_at(buf, at), expected, "actual should be equal to expected")
	}
}

test "big endian u64 end" {
	cases := [
		([0 as u8, 0, 0, 0, 0, 0, 0, 0, 0, 0], 0 as u64),
		([0x01 as u8, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08], 0x0102030405060708 as u64),
		([0xff as u8, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff], 0xffffffffffffffff as u64),
	]

	for case in cases {
		buf, expected := case
		t.assert_eq(binary.BigEndian.u64_end(buf).hex_prefixed(), expected.hex_prefixed(), "actual should be equal to expected")
	}
}

test "big endian put u64" {
	mut buf := []u8{len: 8}
	binary.BigEndian.put_u64(&mut buf, 0x872fea9512345678 as u64)
	t.assert_eq(buf.str(), [0x87, 0x2f, 0xea, 0x95, 0x12, 0x34, 0x56, 0x78].str(), "actual should be equal to expected")
	binary.BigEndian.put_u64(&mut buf, 0)
	t.assert_eq(buf.str(), [0, 0, 0, 0, 0, 0, 0, 0].str(), "actual should be equal to expected")
	binary.BigEndian.put_u64(&mut buf, 0xfdf2e68ffedcba98 as u64)
	t.assert_eq(buf.str(), [0xfd, 0xf2, 0xe6, 0x8f, 0xfe, 0xdc, 0xba, 0x98].str(), "actual should be equal to expected")
}

test "big endian put u64 at" {
	mut buf := []u8{len: 16}
	binary.BigEndian.put_u64_at(&mut buf, 0x872fea9512345678 as u64, 8)
	t.assert_eq(buf.str(), [0, 0, 0, 0, 0, 0, 0, 0, 0x87, 0x2f, 0xea, 0x95, 0x12, 0x34, 0x56, 0x78].str(), "actual should be equal to expected")

	buf = []u8{len: 16}
	binary.BigEndian.put_u64_at(&mut buf, 0x1234567890abcdef as u64, 0)
	t.assert_eq(buf.str(), [0x12, 0x34, 0x56, 0x78, 0x90, 0xab, 0xcd, 0xef, 0, 0, 0, 0, 0, 0, 0, 0].str(), "actual should be equal to expected")

	buf = []u8{len: 16}
	binary.BigEndian.put_u64_at(&mut buf, 0xffffffffffffffff as u64, 0)
	t.assert_eq(buf.str(), [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0, 0, 0, 0, 0, 0, 0, 0].str(), "actual should be equal to expected")
}

test "big endian put u64 end" {
	mut buf := []u8{len: 16}
	binary.BigEndian.put_u64_end(&mut buf, 0x872fea9512345678 as u64)
	t.assert_eq(buf.str(), [0, 0, 0, 0, 0, 0, 0, 0, 0x87, 0x2f, 0xea, 0x95, 0x12, 0x34, 0x56, 0x78].str(), "actual should be equal to expected")

	buf = []u8{len: 16}
	binary.BigEndian.put_u64_end(&mut buf, 0x1234567890abcdef as u64)
	t.assert_eq(buf.str(), [0, 0, 0, 0, 0, 0, 0, 0, 0x12, 0x34, 0x56, 0x78, 0x90, 0xab, 0xcd, 0xef].str(), "actual should be equal to expected")

	buf = []u8{len: 16}
	binary.BigEndian.put_u64_end(&mut buf, 0xffffffffffffffff as u64)
	t.assert_eq(buf.str(), [0, 0, 0, 0, 0, 0, 0, 0, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff].str(), "actual should be equal to expected")
}
