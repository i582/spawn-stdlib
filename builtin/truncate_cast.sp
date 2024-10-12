module builtin

// truncate_cast_to_u8 casts `u16` `number` to `u8` by truncating higher 8 bits.
//
// Examples:
// ```
// number := 0x11 as u16
// println(number.truncate_cast_to_u8().hex_prefixed()) // prints 0x11
// ```
//
// When `number` is larger than `MAX_U8`, `truncate_cast_to_u8` returns the value of the least significant 8 bits of `number`.
// ```
// number := 0x200 as u16
// println(number.truncate_cast_to_u8().hex_prefixed()) // prints 0xFF
// ```
//
// with one exception - when `number` is equal 0x100, `truncate_cast_to_u8` returns 0, since only the lower 8 bits are kept.
// ```
// number := 0x100 as u16
// println(number.truncate_cast_to_u8().hex_prefixed()) // prints 0
// ```
pub fn (number u16) truncate_cast_to_u8() -> u8 {
	return (number & MAX_U8) as u8
}

// truncate_cast_to_u8 casts `u32` `number` to `u8` by truncating higher 24 bits.
//
// Examples:
// ```
// number := 0x11 as u32
// println(number.truncate_cast_to_u8().hex_prefixed()) // prints 0x11
// ```
//
// When `number` is larger than `MAX_U8`, `truncate_cast_to_u8` returns the value of the least significant 8 bits of `number`.
// ```
// number := 0x200 as u32
// println(number.truncate_cast_to_u8().hex_prefixed()) // prints 0xFF
// ```
//
// with one exception - when `number` is equal 0x100, `truncate_cast_to_u8` returns 0, since only the lower 8 bits are kept.
// ```
// number := 0x100 as u32
// println(number.truncate_cast_to_u8().hex_prefixed()) // prints 0
// ```
pub fn (number u32) truncate_cast_to_u8() -> u8 {
	return (number & MAX_U8) as u8
}

// truncate_cast_to_u16 casts `u32` `number` to `u16` by truncating higher 16 bits.
//
// Examples:
// ```
// number := 0x11 as u32
// println(number.truncate_cast_to_u16().hex_prefixed()) // prints 0x11
// ```
//
// When `number` is larger than `MAX_U16`, `truncate_cast_to_u16` returns the value of the least significant 16 bits of `number`.
// ```
// number := 0x9FFF6 as u32
// println(number.truncate_cast_to_u16().hex_prefixed()) // prints 0xFFF6
// ```
//
// with one exception - when `number` is equal 0x10000, `truncate_cast_to_u16` returns 0, since only the lower 16 bits are kept.
// ```
// number := 0x10000 as u32
// println(number.truncate_cast_to_u16().hex_prefixed()) // prints 0
// ```
pub fn (number u32) truncate_cast_to_u16() -> u16 {
	return (number & MAX_U16) as u16
}

// truncate_cast_to_u8 casts `u64` `number` to `u8` by truncating higher 56 bits.
//
// Examples:
// ```
// number := 0x11 as u64
// println(number.truncate_cast_to_u8().hex_prefixed()) // prints 0x11
// ```
//
// When `number` is larger than `MAX_U8`, `truncate_cast_to_u8` returns the value of the least significant 8 bits of `number`.
// ```
// number := 0x200 as u64
// println(number.truncate_cast_to_u8().hex_prefixed()) // prints 0xFF
// ```
//
// with one exception - when `number` is equal 0x100, `truncate_cast_to_u8` returns 0, since only the lower 8 bits are kept.
// ```
// number := 0x100 as u64
// println(number.truncate_cast_to_u8().hex_prefixed()) // prints 0
// ```
pub fn (number u64) truncate_cast_to_u8() -> u8 {
	return (number & MAX_U8) as u8
}

// truncate_cast_to_u16 casts `u64` `number` to `u16` by truncating higher 48 bits.
//
// Examples:
// ```
// number := 0x11 as u64
// println(number.truncate_cast_to_u16().hex_prefixed()) // prints 0x11
// ```
//
// When `number` is larger than `MAX_U16`, `truncate_cast_to_u16` returns the value of the least significant 16 bits of `number`.
// ```
// number := 0x9FFF6 as u64
// println(number.truncate_cast_to_u16().hex_prefixed()) // prints 0xFFF6
// ```
//
// with one exception - when `number` is equal 0x10000, `truncate_cast_to_u16` returns 0, since only the lower 16 bits are kept.
// ```
// number := 0x10000 as u64
// println(number.truncate_cast_to_u16().hex_prefixed()) // prints 0
// ```
pub fn (number u64) truncate_cast_to_u16() -> u16 {
	return (number & MAX_U16) as u16
}

// truncate_cast_to_u32 casts `u64` `number` to `u32` by truncating higher 32 bits.
//
// Examples:
// ```
// number := 0x11 as u64
// println(number.truncate_cast_to_u32().hex_prefixed()) // prints 0x11
// ```
//
// When `number` is larger than `MAX_U32`, `truncate_cast_to_u32` returns the value of the least significant 32 bits of `number`.
// ```
// number := 0x9FFFFFFF6 as u64
// println(number.truncate_cast_to_u32().hex_prefixed()) // prints 0xFFFFFFF6
// ```
//
// with one exception - when `number` is equal 0x100000000, `truncate_cast_to_u32` returns 0, since only the lower 32 bits are kept.
// ```
// number := 0x100000000 as u64
// println(number.truncate_cast_to_u32().hex_prefixed()) // prints 0
// ```
pub fn (number u64) truncate_cast_to_u32() -> u32 {
	return (number & MAX_U32) as u32
}

// truncate_cast_to_u8 casts `usize` `number` to `u8` by truncating higher 56 bits.
//
// Examples:
// ```
// number := 0x11 as usize
// println(number.truncate_cast_to_u8().hex_prefixed()) // prints 0x11
// ```
//
// When `number` is larger than `MAX_U8`, `truncate_cast_to_u8` returns the value of the least significant 8 bits of `number`.
// ```
// number := 0x200 as usize
// println(number.truncate_cast_to_u8().hex_prefixed()) // prints 0xFF
// ```
//
// with one exception - when `number` is equal 0x100, `truncate_cast_to_u8` returns 0, since only the lower 8 bits are kept.
// ```
// number := 0x100 as usize
// println(number.truncate_cast_to_u8().hex_prefixed()) // prints 0
// ```
pub fn (number usize) truncate_cast_to_u8() -> u8 {
	return (number & MAX_U8) as u8
}

// truncate_cast_to_u8 casts `u128` `number` to `u8` by truncating higher 120 bits.
//
// Examples:
// ```
// number := 0x11 as u128
// println(number.truncate_cast_to_u8().hex_prefixed()) // prints 0x11
// ```
//
// When `number` is larger than `MAX_U8`, `truncate_cast_to_u8` returns the value of the least significant 8 bits of `number`.
// ```
// number := 0x200 as u128
// println(number.truncate_cast_to_u8().hex_prefixed()) // prints 0xFF
// ```
//
// with one exception - when `number` is equal 0x100, `truncate_cast_to_u8` returns 0, since only the lower 8 bits are kept.
// ```
// number := 0x100 as u128
// println(number.truncate_cast_to_u8().hex_prefixed()) // prints 0
// ```
pub fn (number u128) truncate_cast_to_u8() -> u8 {
	return (number & MAX_U8) as u8
}

// truncate_cast_to_u16 casts `u128` `number` to `u16` by truncating higher 112 bits.
//
// Examples:
// ```
// number := 0x11 as u128
// println(number.truncate_cast_to_u16().hex_prefixed()) // prints 0x11
// ```
//
// When `number` is larger than `MAX_U16`, `truncate_cast_to_u16` returns the value of the least significant 16 bits of `number`.
// ```
// number := 0x9FFF6 as u128
// println(number.truncate_cast_to_u16().hex_prefixed()) // prints 0xFFF6
// ```
//
// with one exception - when `number` is equal 0x10000, `truncate_cast_to_u16` returns 0, since only the lower 16 bits are kept.
// ```
// number := 0x10000 as u128
// println(number.truncate_cast_to_u16().hex_prefixed()) // prints 0
// ```
pub fn (number u128) truncate_cast_to_u16() -> u16 {
	return (number & MAX_U16) as u16
}

// truncate_cast_to_u32 casts `u128` `number` to `u32` by truncating higher 96 bits.
//
// Examples:
// ```
// number := 0x11 as u128
// println(number.truncate_cast_to_u32().hex_prefixed()) // prints 0x11
// ```
//
// When `number` is larger than `MAX_U32`, `truncate_cast_to_u32` returns the value of the least significant 32 bits of `number`.
// ```
// number := 0x9FFFFFFF6 as u128
// println(number.truncate_cast_to_u32().hex_prefixed()) // prints 0xFFFFFFF6
// ```
//
// with one exception - when `number` is equal 0x100000000, `truncate_cast_to_u32` returns 0, since only the lower 32 bits are kept.
// ```
// number := 0x100000000 as u128
// println(number.truncate_cast_to_u32().hex_prefixed()) // prints 0
// ```
pub fn (number u128) truncate_cast_to_u32() -> u32 {
	return (number & MAX_U32) as u32
}

// truncate_cast_to_u64 casts `u128` `number` to `u64` by truncating higher 64 bits.
//
// Examples:
// ```
// number := 0x11 as u128
// println(number.truncate_cast_to_u64().hex_prefixed()) // prints 0x11
// ```
//
// When `number` is larger than `MAX_U64`, `truncate_cast_to_u64` returns the value of the least significant 64 bits of `number`.
// ```
// number := 0x9FFFFFFFFFFFFFFF6 as u128
// println(number.truncate_cast_to_u64().hex_prefixed()) // prints 0xFFFFFFFFFFFFFFF6
// ```
//
// with one exception - when `number` is equal 0x10000000000000000, `truncate_cast_to_u64` returns 0, since only the lower 64 bits are kept.
// ```
// number := 0x10000000000000000 as u128
// println(number.truncate_cast_to_u64().hex_prefixed()) // prints 0
// ```
pub fn (number u128) truncate_cast_to_u64() -> u64 {
	return (number & MAX_U64) as u64
}
