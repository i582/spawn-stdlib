module binary

pub struct LittleEndian {}

// u16 creates a u16 from the first two bytes in the
// array [`b`] in little endian order.
pub fn LittleEndian.u16(b []u8) -> u16 {
	return b[0] as u16 | (b[1] as u16 << 8)
}

// u16_at creates a u16 from two bytes in the array [`b`]
// at the specified offset in little endian order.
pub fn LittleEndian.u16_at(b []u8, o usize) -> u16 {
	return b[o] as u16 | (b[o + 1] as u16 << 8)
}

// u16_end creates a u16 from the last two bytes of
// the array [`b`] in little endian order.
pub fn LittleEndian.u16_end(b []u8) -> u16 {
	return LittleEndian.u16_at(b, b.len - 2)
}

// put_u16 writes a u16 to the first two bytes in the
// array [`b`] in little endian order.
pub fn LittleEndian.put_u16(b &mut []u8, v u16) {
	b[0] = v.truncate_cast_to_u8()
	b[1] = (v >> 8).truncate_cast_to_u8()
}

// put_u16_at writes a u16 to the two bytes in the array [`b`]
// at the specified offset in little endian order.
pub fn LittleEndian.put_u16_at(b &mut []u8, v u16, o usize) {
	b[o] = v.truncate_cast_to_u8()
	b[o + 1] = (v >> 8).truncate_cast_to_u8()
}

// put_u16_end writes a u16 to the last two bytes of the array [`b`]
// in little endian order.
pub fn LittleEndian.put_u16_end(b &mut []u8, v u16) {
	LittleEndian.put_u16_at(b, v, b.len - 2)
}

// u32 creates a u32 from the first four bytes in the array [`b`]
// in little endian order.
pub fn LittleEndian.u32(b []u8) -> u32 {
	return b[0] as u32 | (b[1] as u32 << 8) | (b[2] as u32 << 16) | (b[3] as u32 << 24)
}

// u32_at creates a u32 from four bytes in the array [`b`] at the
// specified offset in little endian order.
#[spawnfmt.skip]
pub fn LittleEndian.u32_at(b []u8, o usize) -> u32 {
    return b[o] as u32 |
           b[o + 1] as u32 << 8 |
           b[o + 2] as u32 << 16 |
           b[o + 3] as u32 << 24
}

// u32_end creates a u32 from the last four bytes in
// the array [`b`] in little endian order.
pub fn LittleEndian.u32_end(b []u8) -> u32 {
	return LittleEndian.u32_at(b, b.len - 4)
}

// put_u32 writes a u32 to the first four bytes in
// the array [`b`] in little endian order.
pub fn LittleEndian.put_u32(b &mut []u8, v u32) {
	b[0] = v.truncate_cast_to_u8()
	b[1] = (v >> 8).truncate_cast_to_u8()
	b[2] = (v >> 16).truncate_cast_to_u8()
	b[3] = (v >> 24).truncate_cast_to_u8()
}

// put_u32_at writes a u32 to the four bytes in the array
// [`b`] at the specified offset in little endian order.
pub fn LittleEndian.put_u32_at(b &mut []u8, v u32, o usize) {
	b[o] = v.truncate_cast_to_u8()
	b[o + 1] = (v >> 8).truncate_cast_to_u8()
	b[o + 2] = (v >> 16).truncate_cast_to_u8()
	b[o + 3] = (v >> 24).truncate_cast_to_u8()
}

// put_u32_end writes a u32 to the last four bytes in
// the array [`b`] in little endian order.
pub fn LittleEndian.put_u32_end(b &mut []u8, v u32) {
	LittleEndian.put_u32_at(b, v, b.len - 4)
}

// u64 creates a u64 from the first eight bytes in the
// array [`b`] in little endian order.
#[spawnfmt.skip]
pub fn LittleEndian.u64(b []u8) -> u64 {
    return b[0] as u64 |
           b[1] as u64 << 8 |
           b[2] as u64 << 16 |
           b[3] as u64 << 24 |
           b[4] as u64 << 32 |
           b[5] as u64 << 40 |
           b[6] as u64 << 48 |
           b[7] as u64 << 56
}

// u64_at creates a u64 from eight bytes in the array [`b`]
// at the specified offset in little endian order.
#[spawnfmt.skip]
pub fn LittleEndian.u64_at(b []u8, o usize) -> u64 {
    return b[o] as u64 |
           b[o + 1] as u64 << 8 |
           b[o + 2] as u64 << 16 |
           b[o + 3] as u64 << 24 |
           b[o + 4] as u64 << 32 |
           b[o + 5] as u64 << 40 |
           b[o + 6] as u64 << 48 |
           b[o + 7] as u64 << 56
}

// u64_end creates a u64 from the last eight bytes in the
// array [`b`] in little endian order.
pub fn LittleEndian.u64_end(b []u8) -> u64 {
	return LittleEndian.u64_at(b, b.len - 8)
}

// put_u64 writes a u64 to the first eight bytes in the
// array [`b`] in little endian order.
pub fn LittleEndian.put_u64(b &mut []u8, v u64) {
	b[0] = v.truncate_cast_to_u8()
	b[1] = (v >> 8).truncate_cast_to_u8()
	b[2] = (v >> 16).truncate_cast_to_u8()
	b[3] = (v >> 24).truncate_cast_to_u8()
	b[4] = (v >> 32).truncate_cast_to_u8()
	b[5] = (v >> 40).truncate_cast_to_u8()
	b[6] = (v >> 48).truncate_cast_to_u8()
	b[7] = (v >> 56).truncate_cast_to_u8()
}

// put_u64_at writes a u64 to the eight bytes in the array [`b`]
//  at the specified offset in little endian order.
pub fn LittleEndian.put_u64_at(b &mut []u8, v u64, o usize) {
	b[o] = v.truncate_cast_to_u8()
	b[o + 1] = (v >> 8).truncate_cast_to_u8()
	b[o + 2] = (v >> 16).truncate_cast_to_u8()
	b[o + 3] = (v >> 24).truncate_cast_to_u8()
	b[o + 4] = (v >> 32).truncate_cast_to_u8()
	b[o + 5] = (v >> 40).truncate_cast_to_u8()
	b[o + 6] = (v >> 48).truncate_cast_to_u8()
	b[o + 7] = (v >> 56).truncate_cast_to_u8()
}

// put_u64_end writes a u64 to the last eight bytes in
// the array [`b`] at in little endian order.
pub fn LittleEndian.put_u64_end(b &mut []u8, v u64) {
	LittleEndian.put_u64_at(b, v, b.len - 8)
}

pub struct BigEndian {}

// u16 creates a u16 from the first two bytes in the
// array [`b`] in big endian order.
pub fn BigEndian.u16(b []u8) -> u16 {
	return (b[0] as u16 << 8) | b[1] as u16
}

// u16_at creates a u16 from two bytes in the array [`b`]
// at the specified offset in big endian order.
pub fn BigEndian.u16_at(b []u8, o usize) -> u16 {
	return (b[o] as u16 << 8) | b[o + 1] as u16
}

// u16_end creates a u16 from the last two bytes of
// the array [`b`] in big endian order.
pub fn BigEndian.u16_end(b []u8) -> u16 {
	return BigEndian.u16_at(b, b.len - 2)
}

// put_u16 writes a u16 to the first two bytes in the
// array [`b`] in big endian order.
pub fn BigEndian.put_u16(b &mut []u8, v u16) {
	b[0] = (v >> 8).truncate_cast_to_u8()
	b[1] = v.truncate_cast_to_u8()
}

// put_u16_at writes a u16 to the two bytes in the array [`b`]
// at the specified offset in big endian order.
pub fn BigEndian.put_u16_at(b &mut []u8, v u16, o usize) {
	b[o] = (v >> 8).truncate_cast_to_u8()
	b[o + 1] = v.truncate_cast_to_u8()
}

// put_u16_end writes a u16 to the last two bytes of the array [`b`]
// in big endian order.
pub fn BigEndian.put_u16_end(b &mut []u8, v u16) {
	BigEndian.put_u16_at(b, v, b.len - 2)
}

// u32 creates a u32 from the first four bytes in the array [`b`]
// in big endian order.
pub fn BigEndian.u32(b []u8) -> u32 {
	return (b[0] as u32 << 24) | (b[1] as u32 << 16) | (b[2] as u32 << 8) | b[3] as u32
}

// u32_at creates a u32 from four bytes in the array [`b`] at the
// specified offset in big endian order.
#[spawnfmt.skip]
pub fn BigEndian.u32_at(b []u8, o usize) -> u32 {
    return b[o] as u32 << 24 |
           b[o + 1] as u32 << 16 |
           b[o + 2] as u32 << 8 |
           b[o + 3] as u32
}

// u32_end creates a u32 from the last four bytes in
// the array [`b`] in big endian order.
pub fn BigEndian.u32_end(b []u8) -> u32 {
	return BigEndian.u32_at(b, b.len - 4)
}

// put_u32 writes a u32 to the first four bytes in
// the array [`b`] in big endian order.
pub fn BigEndian.put_u32(b &mut []u8, v u32) {
	b[0] = (v >> 24).truncate_cast_to_u8()
	b[1] = (v >> 16).truncate_cast_to_u8()
	b[2] = (v >> 8).truncate_cast_to_u8()
	b[3] = v.truncate_cast_to_u8()
}

// put_u32_at writes a u32 to the four bytes in the array
// `b` at the specified offset in big endian order.
pub fn BigEndian.put_u32_at(b &mut []u8, v u32, o usize) {
	b[o] = (v >> 24).truncate_cast_to_u8()
	b[o + 1] = (v >> 16).truncate_cast_to_u8()
	b[o + 2] = (v >> 8).truncate_cast_to_u8()
	b[o + 3] = v.truncate_cast_to_u8()
}

// put_u32_end writes a u32 to the last four bytes in
// the array [`b`] in big endian order.
pub fn BigEndian.put_u32_end(b &mut []u8, v u32) {
	BigEndian.put_u32_at(b, v, b.len - 4)
}

// u64 creates a u64 from the first eight bytes in the
// array [`b`] in big endian order.
#[spawnfmt.skip]
pub fn BigEndian.u64(b []u8) -> u64 {
    return b[0] as u64 << 56 |
           b[1] as u64 << 48 |
           b[2] as u64 << 40 |
           b[3] as u64 << 32 |
           b[4] as u64 << 24 |
           b[5] as u64 << 16 |
           b[6] as u64 << 8 |
           b[7] as u64
}

// u64_at creates a u64 from eight bytes in the array [`b`]
// at the specified offset in big endian order.
#[spawnfmt.skip]
pub fn BigEndian.u64_at(b []u8, o usize) -> u64 {
    return b[o] as u64 << 56 |
           b[o + 1] as u64 << 48 |
           b[o + 2] as u64 << 40 |
           b[o + 3] as u64 << 32 |
           b[o + 4] as u64 << 24 |
           b[o + 5] as u64 << 16 |
           b[o + 6] as u64 << 8 |
           b[o + 7] as u64
}

// u64_end creates a u64 from the last eight bytes in the
// array [`b`] in big endian order.
pub fn BigEndian.u64_end(b []u8) -> u64 {
	return BigEndian.u64_at(b, b.len - 8)
}

// put_u64 writes a u64 to the first eight bytes in the
// array [`b`] in big endian order.
pub fn BigEndian.put_u64(b &mut []u8, v u64) {
	b[0] = (v >> 56).truncate_cast_to_u8()
	b[1] = (v >> 48).truncate_cast_to_u8()
	b[2] = (v >> 40).truncate_cast_to_u8()
	b[3] = (v >> 32).truncate_cast_to_u8()
	b[4] = (v >> 24).truncate_cast_to_u8()
	b[5] = (v >> 16).truncate_cast_to_u8()
	b[6] = (v >> 8).truncate_cast_to_u8()
	b[7] = v.truncate_cast_to_u8()
}

// put_u64_at writes a u64 to the eight bytes in the array [`b`]
// at the specified offset in big endian order.
pub fn BigEndian.put_u64_at(b &mut []u8, v u64, o usize) {
	b[o] = (v >> 56).truncate_cast_to_u8()
	b[o + 1] = (v >> 48).truncate_cast_to_u8()
	b[o + 2] = (v >> 40).truncate_cast_to_u8()
	b[o + 3] = (v >> 32).truncate_cast_to_u8()
	b[o + 4] = (v >> 24).truncate_cast_to_u8()
	b[o + 5] = (v >> 16).truncate_cast_to_u8()
	b[o + 6] = (v >> 8).truncate_cast_to_u8()
	b[o + 7] = v.truncate_cast_to_u8()
}

// put_u64_end writes a u64 to the last eight bytes in
// the array [`b`] in big endian order.
pub fn BigEndian.put_u64_end(b &mut []u8, v u64) {
	BigEndian.put_u64_at(b, v, b.len - 8)
}
