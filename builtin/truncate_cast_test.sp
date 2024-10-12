module main

test "u16 truncate_cast_to_u8 returns 0 for 0 input" {
	number := 0 as u16
	t.assert_eq(number.truncate_cast_to_u8(), 0, "Truncating 0 u16 to u8 must return 0")
}

test "u16 truncate_cast_to_u8 returns 0x1 for 0x1 input" {
	number := 0x1 as u16
	t.assert_eq(number.truncate_cast_to_u8(), 0x1, "Truncating 0x1 u16 to u8 must return 0x1")
}

test "u16 truncate_cast_to_u8 returns MAX_U8 for MAX_U8 input" {
	number := MAX_U8 as u16
	t.assert_eq(number.truncate_cast_to_u8(), MAX_U8, "Truncating MAX_U8 u16 to u8 must return MAX_U8")
}

test "u16 truncate_cast_to_u8 returns MAX_U8 for 0x1FF input" {
	number := 0x1FF as u16
	t.assert_eq(number.truncate_cast_to_u8(), MAX_U8, "Truncating 0x1FF u16 to u8 must return MAX_U8")
}

test "u16 truncate_cast_to_u8 returns 0 for 0x100 input" {
	number := 0x100 as u16
	t.assert_eq(number.truncate_cast_to_u8(), 0, "Truncating 0x100 u16 to u8 must return 0")
}

test "u16 truncate_cast_to_u8 returns MAX_U8 for MAX_U16 input" {
	number := MAX_U16
	t.assert_eq(number.truncate_cast_to_u8(), MAX_U8, "Truncating MAX_U16 u16 to u8 must return MAX_U8")
}

test "u16 truncate_cast_to_u8 returns 0x11 for 0x11 input" {
	number := 0x11 as u16
	t.assert_eq(number.truncate_cast_to_u8(), 0x11, "Truncating 0x11 u16 to u8 must return 0x11")
}

test "u32 truncate_cast_to_u8 returns 0 for 0 input" {
	number := 0 as u32
	t.assert_eq(number.truncate_cast_to_u8(), 0, "Truncating 0 u32 to u8 must return 0")
}

test "u32 truncate_cast_to_u8 returns 0x1 for 0x1 input" {
	number := 0x1 as u32
	t.assert_eq(number.truncate_cast_to_u8(), 0x1, "Truncating 0x1 u32 to u8 must return 0x1")
}

test "u32 truncate_cast_to_u8 returns MAX_U8 for MAX_U8 input" {
	number := MAX_U8 as u32
	t.assert_eq(number.truncate_cast_to_u8(), MAX_U8, "Truncating MAX_U8 u32 to u8 must return MAX_U8")
}

test "u32 truncate_cast_to_u8 returns MAX_U8 for 0x1FF input" {
	number := 0x1FF as u32
	t.assert_eq(number.truncate_cast_to_u8(), MAX_U8, "Truncating 0x1FF u32 to u8 must return MAX_U8")
}

test "u32 truncate_cast_to_u8 returns 0 for 0x100 input" {
	number := 0x100 as u32
	t.assert_eq(number.truncate_cast_to_u8(), 0, "Truncating 0x100 u32 to u8 must return 0")
}

test "u32 truncate_cast_to_u8 returns MAX_U8 for MAX_U32 input" {
	number := MAX_U32
	t.assert_eq(number.truncate_cast_to_u8(), MAX_U8, "Truncating MAX_U32 u32 to u8 must return MAX_U8")
}

test "u32 truncate_cast_to_u8 returns 0x11 for 0x11 input" {
	number := 0x11 as u32
	t.assert_eq(number.truncate_cast_to_u8(), 0x11, "Truncating 0x11 u32 to u8 must return 0x11")
}

test "u32 truncate_cast_to_u16 returns 0 for 0 input" {
	number := 0 as u32
	t.assert_eq(number.truncate_cast_to_u16(), 0, "Truncating 0 u32 to u16 must return 0")
}

test "u32 truncate_cast_to_u16 returns 0x1 for 0x1 input" {
	number := 0x1 as u32
	t.assert_eq(number.truncate_cast_to_u16(), 0x1, "Truncating 0x1 u32 to u16 must return 0x1")
}

test "u32 truncate_cast_to_u16 returns MAX_U16 for MAX_U16 input" {
	number := MAX_U16 as u32
	t.assert_eq(number.truncate_cast_to_u16(), MAX_U16, "Truncating MAX_U16 u32 to u16 must return MAX_U16")
}

test "u32 truncate_cast_to_u16 returns 0xFFF6 for 0x9FFF6 input" {
	number := 0x9FFF6 as u32
	t.assert_eq(number.truncate_cast_to_u16(), 0xFFF6, "Truncating 0x9FFF6 u32 to u16 must return 0xFFF6")
}

test "u32 truncate_cast_to_u16 returns 0 for 0x10000 input" {
	number := 0x10000 as u32
	t.assert_eq(number.truncate_cast_to_u16(), 0, "Truncating 0x10000 u32 to u16 must return 0")
}

test "u32 truncate_cast_to_u16 returns MAX_U16 for MAX_U32 input" {
	number := MAX_U32
	t.assert_eq(number.truncate_cast_to_u16(), MAX_U16, "Truncating MAX_U32 u32 to u16 must return MAX_U16")
}

test "u32 truncate_cast_to_u16 returns 0x11 for 0x11 input" {
	number := 0x11 as u32
	t.assert_eq(number.truncate_cast_to_u16(), 0x11, "Truncating 0x11 u32 to u16 must return 0x11")
}

test "u64 truncate_cast_to_u8 returns 0 for 0 input" {
	number := 0 as u64
	t.assert_eq(number.truncate_cast_to_u8(), 0, "Truncating 0 u64 to u8 must return 0")
}

test "u64 truncate_cast_to_u8 returns 0x1 for 0x1 input" {
	number := 0x1 as u64
	t.assert_eq(number.truncate_cast_to_u8(), 0x1, "Truncating 0x1 u64 to u8 must return 0x1")
}

test "u64 truncate_cast_to_u8 returns MAX_U8 for MAX_U8 input" {
	number := MAX_U8 as u64
	t.assert_eq(number.truncate_cast_to_u8(), MAX_U8, "Truncating MAX_U8 u64 to u8 must return MAX_U8")
}

test "u64 truncate_cast_to_u8 returns MAX_U8 for 0x1FF input" {
	number := 0x1FF as u64
	t.assert_eq(number.truncate_cast_to_u8(), MAX_U8, "Truncating 0x1FF u64 to u8 must return MAX_U8")
}

test "u64 truncate_cast_to_u8 returns 0 for 0x100 input" {
	number := 0x100 as u64
	t.assert_eq(number.truncate_cast_to_u8(), 0, "Truncating 0x100 u64 to u8 must return 0")
}

test "u64 truncate_cast_to_u8 returns MAX_U8 for MAX_U64 input" {
	number := MAX_U64
	t.assert_eq(number.truncate_cast_to_u8(), MAX_U8, "Truncating MAX_U64 u64 to u8 must return MAX_U8")
}

test "u64 truncate_cast_to_u8 returns 0x11 for 0x11 input" {
	number := 0x11 as u64
	t.assert_eq(number.truncate_cast_to_u8(), 0x11, "Truncating 0x11 u64 to u8 must return 0x11")
}

test "u64 truncate_cast_to_u16 returns 0 for 0 input" {
	number := 0 as u64
	t.assert_eq(number.truncate_cast_to_u16(), 0, "Truncating 0 u64 to u16 must return 0")
}

test "u64 truncate_cast_to_u16 returns 0x1 for 0x1 input" {
	number := 0x1 as u64
	t.assert_eq(number.truncate_cast_to_u16(), 0x1, "Truncating 0x1 u64 to u16 must return 0x1")
}

test "u64 truncate_cast_to_u16 returns MAX_U16 for MAX_U16 input" {
	number := MAX_U16 as u64
	t.assert_eq(number.truncate_cast_to_u16(), MAX_U16, "Truncating MAX_U16 u64 to u16 must return MAX_U16")
}

test "u64 truncate_cast_to_u16 returns 0xFFF6 for 0x9FFF6 input" {
	number := 0x9FFF6 as u64
	t.assert_eq(number.truncate_cast_to_u16(), 0xFFF6, "Truncating 0x9FFF6 u64 to u16 must return 0xFFF6")
}

test "u64 truncate_cast_to_u16 returns 0 for 0x10000 input" {
	number := 0x10000 as u64
	t.assert_eq(number.truncate_cast_to_u16(), 0, "Truncating 0x10000 u64 to u16 must return 0")
}

test "u64 truncate_cast_to_u16 returns MAX_U16 for MAX_U64 input" {
	number := MAX_U64
	t.assert_eq(number.truncate_cast_to_u16(), MAX_U16, "Truncating MAX_U64 u64 to u16 must return MAX_U16")
}

test "u64 truncate_cast_to_u16 returns 0x11 for 0x11 input" {
	number := 0x11 as u64
	t.assert_eq(number.truncate_cast_to_u16(), 0x11, "Truncating 0x11 u64 to u16 must return 0x11")
}

test "u64 truncate_cast_to_u32 returns 0 for 0 input" {
	number := 0 as u64
	t.assert_eq(number.truncate_cast_to_u32(), 0, "Truncating 0 u64 to u32 must return 0")
}

test "u64 truncate_cast_to_u32 returns 0x1 for 0x1 input" {
	number := 0x1 as u64
	t.assert_eq(number.truncate_cast_to_u32(), 0x1, "Truncating 0x1 u64 to u32 must return 0x1")
}

test "u64 truncate_cast_to_u32 returns MAX_U32 for MAX_U32 input" {
	number := MAX_U32 as u64
	t.assert_eq(number.truncate_cast_to_u32(), MAX_U32, "Truncating MAX_U32 u64 to u32 must return MAX_U32")
}

test "u64 truncate_cast_to_u32 returns 0xFFFFFFF6 for 0x9FFFFFFF6 input" {
	number := 0x9FFFFFFF6 as u64
	t.assert_eq(number.truncate_cast_to_u32(), 0xFFFFFFF6 as u32, "Truncating 0x9FFFFFFF6 u64 to u32 must return 0xFFFFFFF6")
}

test "u64 truncate_cast_to_u32 returns 0 for 0x100000000 input" {
	number := 0x100000000 as u64
	t.assert_eq(number.truncate_cast_to_u32(), 0, "Truncating 0x100000000 u64 to u32 must return 0")
}

test "u64 truncate_cast_to_u32 returns MAX_U32 for MAX_U64 input" {
	number := MAX_U64
	t.assert_eq(number.truncate_cast_to_u32(), MAX_U32, "Truncating MAX_U64 u64 to u32 must return MAX_U32")
}

test "u64 truncate_cast_to_u32 returns 0x11 for 0x11 input" {
	number := 0x11 as u64
	t.assert_eq(number.truncate_cast_to_u32(), 0x11, "Truncating 0x11 u64 to u32 must return 0x11")
}

test "u128 truncate_cast_to_u8 returns 0 for 0 input" {
	number := 0 as u128
	t.assert_eq(number.truncate_cast_to_u8(), 0, "Truncating 0 u128 to u8 must return 0")
}

test "u128 truncate_cast_to_u8 returns 0x1 for 0x1 input" {
	number := 0x1 as u128
	t.assert_eq(number.truncate_cast_to_u8(), 0x1, "Truncating 0x1 u128 to u8 must return 0x1")
}

test "u128 truncate_cast_to_u8 returns MAX_U8 for MAX_U8 input" {
	number := MAX_U8 as u128
	t.assert_eq(number.truncate_cast_to_u8(), MAX_U8, "Truncating MAX_U8 u128 to u8 must return MAX_U8")
}

test "u128 truncate_cast_to_u8 returns MAX_U8 for 0x1FF input" {
	number := 0x1FF as u128
	t.assert_eq(number.truncate_cast_to_u8(), MAX_U8, "Truncating 0x1FF u128 to u8 must return MAX_U8")
}

test "u128 truncate_cast_to_u8 returns 0 for 0x100 input" {
	number := 0x100 as u128
	t.assert_eq(number.truncate_cast_to_u8(), 0, "Truncating 0x100 u128 to u8 must return 0")
}

test "u128 truncate_cast_to_u8 returns MAX_U8 for MAX_U128 input" {
	number := MAX_U128
	t.assert_eq(number.truncate_cast_to_u8(), MAX_U8, "Truncating MAX_U128 u128 to u8 must return MAX_U8")
}

test "u128 truncate_cast_to_u8 returns 0x11 for 0x11 input" {
	number := 0x11 as u128
	t.assert_eq(number.truncate_cast_to_u8(), 0x11, "Truncating 0x11 u128 to u8 must return 0x11")
}

test "u128 truncate_cast_to_u16 returns 0 for 0 input" {
	number := 0 as u128
	t.assert_eq(number.truncate_cast_to_u16(), 0, "Truncating 0 u128 to u16 must return 0")
}

test "u128 truncate_cast_to_u16 returns 0x1 for 0x1 input" {
	number := 0x1 as u128
	t.assert_eq(number.truncate_cast_to_u16(), 0x1, "Truncating 0x1 u128 to u16 must return 0x1")
}

test "u128 truncate_cast_to_u16 returns MAX_U16 for MAX_U16 input" {
	number := MAX_U16 as u128
	t.assert_eq(number.truncate_cast_to_u16(), MAX_U16, "Truncating MAX_U16 u128 to u16 must return MAX_U16")
}

test "u128 truncate_cast_to_u16 returns 0xFFF6 for 0x9FFF6 input" {
	number := 0x9FFF6 as u128
	t.assert_eq(number.truncate_cast_to_u16(), 0xFFF6, "Truncating 0x9FFF6 u128 to u16 must return 0xFFF6")
}

test "u128 truncate_cast_to_u16 returns 0 for 0x10000 input" {
	number := 0x10000 as u128
	t.assert_eq(number.truncate_cast_to_u16(), 0, "Truncating 0x10000 u128 to u16 must return 0")
}

test "u128 truncate_cast_to_u16 returns MAX_U16 for MAX_U128 input" {
	number := MAX_U128
	t.assert_eq(number.truncate_cast_to_u16(), MAX_U16, "Truncating MAX_U128 u128 to u16 must return MAX_U16")
}

test "u128 truncate_cast_to_u16 returns 0x11 for 0x11 input" {
	number := 0x11 as u128
	t.assert_eq(number.truncate_cast_to_u16(), 0x11, "Truncating 0x11 u128 to u16 must return 0x11")
}

test "u128 truncate_cast_to_u32 returns 0 for 0 input" {
	number := 0 as u128
	t.assert_eq(number.truncate_cast_to_u32(), 0, "Truncating 0 u128 to u32 must return 0")
}

test "u128 truncate_cast_to_u32 returns 0x1 for 0x1 input" {
	number := 0x1 as u128
	t.assert_eq(number.truncate_cast_to_u32(), 0x1, "Truncating 0x1 u128 to u32 must return 0x1")
}

test "u128 truncate_cast_to_u32 returns MAX_U32 for MAX_U32 input" {
	number := MAX_U32 as u128
	t.assert_eq(number.truncate_cast_to_u32(), MAX_U32, "Truncating MAX_U32 u128 to u32 must return MAX_U32")
}

test "u128 truncate_cast_to_u32 returns 0xFFFFFFF6 for 0x9FFFFFFF6 input" {
	number := 0x9FFFFFFF6 as u128
	t.assert_eq(number.truncate_cast_to_u32(), 0xFFFFFFF6 as u32, "Truncating 0x9FFFFFFF6 u128 to u32 must return 0xFFFFFFF6")
}

test "u128 truncate_cast_to_u32 returns 0 for 0x100000000 input" {
	number := 0x100000000 as u128
	t.assert_eq(number.truncate_cast_to_u32(), 0, "Truncating 0x100000000 u128 to u32 must return 0")
}

test "u128 truncate_cast_to_u32 returns MAX_U32 for MAX_U128 input" {
	number := MAX_U128
	t.assert_eq(number.truncate_cast_to_u32(), MAX_U32, "Truncating MAX_U128 u128 to u32 must return MAX_U32")
}

test "u128 truncate_cast_to_u32 returns 0x11 for 0x11 input" {
	number := 0x11 as u128
	t.assert_eq(number.truncate_cast_to_u32(), 0x11, "Truncating 0x11 u128 to u32 must return 0x11")
}

test "u128 truncate_cast_to_u64 returns 0 for 0 input" {
	number := 0 as u128
	t.assert_eq(number.truncate_cast_to_u64(), 0, "Truncating 0 u128 to u64 must return 0")
}

test "u128 truncate_cast_to_u64 returns 0x1 for 0x1 input" {
	number := 0x1 as u128
	t.assert_eq(number.truncate_cast_to_u64(), 0x1, "Truncating 0x1 u128 to u64 must return 0x1")
}

test "u128 truncate_cast_to_u64 returns MAX_U64 for MAX_U64 input" {
	number := MAX_U64 as u128
	t.assert_eq(number.truncate_cast_to_u64(), MAX_U64, "Truncating MAX_U64 u128 to u64 must return MAX_U64")
}

test "u128 truncate_cast_to_u64 returns 0xFFFFFFFFFFFFFFF6 for 0x9FFFFFFFFFFFFFFF6 input" {
	// TODO: for some reason very big hex numbers can't be casted to u128
	// number := 0x9FFFFFFFFFFFFFFF6 as u128
	number := 184467440737095516150 as u128
	t.assert_eq(number.truncate_cast_to_u64(), 0xFFFFFFFFFFFFFFF6 as u64, "Truncating 0x9FFFFFFFFFFFFFFF6 u128 to u64 must return 0xFFFFFFFFFFFFFFF6")
}

test "u128 truncate_cast_to_u64 returns 0 for 0x10000000000000000 input" {
	// HACK: this is needed to trick C compiler to create a correct u128 number
	number := (0xFFFFFFFFFFFFFFFF as u64 + 0x1) as u128

	t.assert_eq(number.truncate_cast_to_u64(), 0, "Truncating 0x10000000000000000 u128 to u64 must return 0")
}

test "u128 truncate_cast_to_u64 returns MAX_U64 for MAX_U128 input" {
	number := MAX_U128
	t.assert_eq(number.truncate_cast_to_u64(), MAX_U64, "Truncating MAX_U128 u128 to u64 must return MAX_U64")
}

test "u128 truncate_cast_to_u64 returns 0x11 for 0x11 input" {
	number := 0x11 as u128
	t.assert_eq(number.truncate_cast_to_u64(), 0x11, "Truncating 0x11 u128 to u64 must return 0x11")
}
