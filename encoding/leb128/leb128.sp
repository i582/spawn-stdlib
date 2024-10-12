module leb128

// encode_i64 encodes a 64-bit signed integer into LEB128 format and
// writes the result to the buffer.
// Returns the number of bytes written to the buffer.
//
// Example:
// ```
// mut buffer := []u8{len: 20}
// value_i64 := -1234567890123456789 as i64
// len := leb128.encode_i64(value_i64, &mut buffer)
// assert buffer[..len] == [0x1d, 0x7f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]
// ```
pub fn encode_i64(value i64, buf &mut []u8) -> usize {
	mut val := value
	mut i := 0 as usize
	for val != 0 {
		mut b := (val & 0x7f) as u8
		val >>= 7
		if (val == 0 && b & 0x40 == 0) || (val == -1 && b & 0x40 != 0) {
			buf[i] = b
			return i + 1
		}
		buf[i] = b | 0x80
		i++
	}
	return i + 1
}

// encode_u64 encodes a 64-bit unsigned integer into LEB128 format and
// writes the result to the buffer.
// Returns the number of bytes written to the buffer.
//
// Example:
// ```
// mut buffer := []u8{len: 20}
// value_u64 := 1234567890123456789 as u64
// len := leb128.encode_u64(value_u64, &mut buffer)
// assert buffer[..len] == [0x15, 0x7a, 0x7b, 0x17, 0x6e, 0x0a, 0x00, 0x00]
// ```
pub fn encode_u64(value u64, buf &mut []u8) -> usize {
	mut val := value
	mut i := 0 as usize
	for {
		mut b := (val & 0x7f) as u8
		val >>= 7
		if val == 0 {
			buf[i] = b
			i++
			break
		}
		buf[i] = b | 0x80
		i++

		if value == 0 {
			break
		}
	}
	return i
}

// decode_i64 decodes a 64-bit signed integer from LEB128 format from the input byte array.
// Returns the decoded value and the number of bytes used for decoding.
//
// Example:
// ```
// encoded_i64 := [0x1d as u8, 0x7f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]
// decoded_i64, bytes_read_i64 := leb128.decode_i64(encoded_i64)
// assert decoded_i64 == -1234567890123456789 as i64
// assert bytes_read_i64 == 8
// ```
pub fn decode_i64(value []u8) -> (i64, usize) {
	mut result := 0 as u64
	mut shift := 0

	for b in value {
		result |= (b & 0x7f) as u64 << shift
		shift += 7
		if b & 0x80 == 0 {
			if shift < 64 && b & 0x40 != 0 {
				result |= ~(0 as u64) << shift
			}
			break
		}
	}
	return *((&result as &i64) as &u64), shift / 7
}

// decode_u64 decodes a 64-bit unsigned integer from LEB128 format from the input byte array.
// Returns the decoded value and the number of bytes used for decoding.
//
// Example:
// ```
// encoded_u64 := [0x15 as u8, 0x7a, 0x7b, 0x17, 0x6e, 0x0a, 0x00, 0x00]
// decoded_u64, bytes_read_u64 := leb128.decode_u64(encoded_u64)
// assert decoded_u64 == 1234567890123456789 as u64
// assert bytes_read_u64 == 8
// ```
pub fn decode_u64(value []u8) -> (u64, usize) {
	mut result := 0 as u64
	mut shift := 0

	for i, b in value {
		result |= (b & 0x7f) as u64 << shift
		shift += 7
		if b & 0x80 == 0 {
			return result, i + 1
		}
	}
	return 0, value.len
}
