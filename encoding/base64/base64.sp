module base64

var (
	// std_encoding is the standard base64 encoding, as defined in RFC 4648.
	std_encoding = Encoding.new(ENCODE_STD)
	// url_encoding is the alternate base64 encoding defined in RFC 4648.
	// It is typically used in URLs and file names.
	url_encoding = Encoding.new(ENCODE_URL)
)

// encode takes a byte array as input and returns the base64 encoded byte array.
//
// Example:
// ```
// src := [100 as u8, 200, 50]
// encoded := base64.encode(src)
// assert encoded == [90 as u8, 87, 120, 121]
// ```
pub fn encode(src []u8) -> []u8 {
	mut dst := []u8{len: std_encoding.encoded_len(src.len)}
	std_encoding.encode(&mut dst, src)
	return dst
}

// encode_str takes a string as input and returns the base64 encoded string.
//
// Example:
// ```
// data := "hello"
// encoded_str := base64.encode_str(data)
// assert encoded_str == "aGVsbG8="
// ```
pub fn encode_str(data string) -> string {
	return encode(data.bytes_no_copy()).ascii_str()
}

// decode takes a base64 encoded byte array as input and returns the decoded byte array.
//
// Example:
// ```
// src := [90 as u8, 87, 120, 121] // base64 encoded "dcy"
// decoded := base64.decode(src).unwrap()
// assert decoded == [100 as u8, 200, 50]
// ```
pub fn decode(src []u8) -> ![]u8 {
	mut dst := []u8{len: src.len}
	len := std_encoding.decode(&mut dst, src)!
	return dst[..len]
}

// decode_str takes a base64 encoded string as input and returns the decoded string.
//
// Example:
// ```
// data := "aGVsbG8="
// decoded_str := base64.decode_str(data).unwrap()
// assert decoded_str == "hello"
// ```
pub fn decode_str(data string) -> !string {
	return decode(data.bytes_no_copy())!.ascii_str()
}

// Encoding is a radix 64 encoding/decoding scheme, defined by a
// 64-character alphabet. The most common encoding is the "base64"
// encoding defined in RFC 4648 and used in MIME (RFC 2045) and PEM
// (RFC 1421).
//
// RFC 4648 also defines an alternate encoding, which is
// the standard encoding with `-` and `_` substituted for `+` and `/.`
pub struct Encoding {
	encode     [64]u8
	decode_map [256]u8
	pad_char   rune
	strict     bool
}

const (
	STD_PADDING = `=`
	NO_PADDING  = -1 as rune
)

const (
	ENCODE_STD = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	ENCODE_URL = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
)

// new returns a new padded [`Encoding`] defined by the given alphabet,
// which must be a 64-byte string that does not contain the padding character
// or CR / LF ('\r', '\n').
//
// The resulting [`Encoding`] uses the default padding character ('='),
// which may be changed or disabled via [`with_padding`].
pub fn Encoding.new(encoder string) -> &mut Encoding {
	if encoder.len != 64 {
		panic("encoding alphabet is not 64-bytes long")
	}

	for el in encoder {
		if el in [b`\n`, b`\r`] {
			panic("encoding alphabet contains newline character")
		}
	}

	e := &mut Encoding{}
	e.pad_char = `=`
	e.encode[..].copy_from(encoder.bytes_no_copy())
	e.decode_map.fill(255)

	for i in 0 .. encoder.len {
		e.decode_map[encoder[i]] = i as u8
	}

	return e
}

// with_padding creates a new encoding identical to enc except
// with a specified padding character, or [`NO_PADDING`] to disable padding.
//
// The padding character must not be '\r' or '\n', must not
// be contained in the encoding's alphabet and must be a rune equal or
// below '\xff'.
pub fn (enc &mut Encoding) with_padding(padding rune) -> &mut Encoding {
	if padding == `\r` || padding == `\n` || padding > 0xff {
		panic("invalid padding")
	}

	for ch in enc.encode {
		if ch as rune == padding {
			panic("padding contained in alphabet")
		}
	}

	enc.pad_char = padding
	return enc
}

// strict creates a new encoding identical to enc except with
// strict decoding enabled. In this mode, the decoder requires that
// trailing padding bits are zero, as described in RFC 4648 section 3.5.
//
// Note that the input is still malleable, as new line characters
// (CR and LF) are still ignored.
pub fn (enc &mut Encoding) strict() -> &mut Encoding {
	enc.strict = true
	return enc
}

// encode encodes [`src`] using the encoding enc, writing
// `encoded_len(src.len)` bytes to [`dst`].
//
// The encoding pads the output to a multiple of 4 bytes,
// so [`encode`] is not appropriate for use on individual blocks
// of a large data stream.
pub fn (enc &Encoding) encode(dst &mut []u8, src []u8) -> usize {
	if src.len == 0 {
		return 0
	}

	result_len := enc.encoded_len(src.len)

	mut di, mut si := 0, 0
	n := (src.len / 3) * 3
	for si < n {
		// Convert 3x 8bit source bytes into 4 bytes
		val := src[si + 0] as u32 << 16 | src[si + 1] as u32 << 8 | src[si + 2] as u32

		dst[di + 0] = enc.encode[val >> 18 & 0x3F]
		dst[di + 1] = enc.encode[val >> 12 & 0x3F]
		dst[di + 2] = enc.encode[val >> 6 & 0x3F]
		dst[di + 3] = enc.encode[val & 0x3F]

		si += 3
		di += 4
	}

	remain := src.len - si
	if remain == 0 {
		return result_len
	}

	// Add the remaining small block
	mut val := src[si + 0] as u32 << 16
	if remain == 2 {
		val |= src[si + 1] as u32 << 8
	}

	dst[di + 0] = enc.encode[val >> 18 & 0x3F]
	dst[di + 1] = enc.encode[val >> 12 & 0x3F]

	match remain {
		2 => {
			dst[di + 2] = enc.encode[val >> 6 & 0x3F]
			if enc.pad_char != NO_PADDING {
				dst[di + 3] = (enc.pad_char & 0xFF) as u8
			}
		}
		1 => {
			if enc.pad_char != NO_PADDING {
				dst[di + 2] = (enc.pad_char & 0xFF) as u8
				dst[di + 3] = (enc.pad_char & 0xFF) as u8
			}
		}
	}

	return result_len
}

// encoded_len returns the length in bytes of the base64 encoding
// of an input buffer of length [`n`].
pub fn (enc &Encoding) encoded_len(n usize) -> usize {
	if enc.pad_char == NO_PADDING {
		return (n * 8 + 5) / 6 // minimum number chars at 6 bits per char
	}
	return (n + 2) / 3 * 4 // minimum number 4-char quanta, 3 bytes each
}

// decode decodes [`src`] using the encoding enc. It writes at most
// `decoded_len(src.len)` bytes to dst and returns the number of bytes
// written.
// New line characters (\r and \n) are ignored.
pub fn (enc &Encoding) decode(dst &mut []u8, src []u8) -> !usize {
	if src.len == 0 {
		return 0
	}

	mut n := 0 as usize
	mut si := 0
	for src.len - si >= 8 && dst.len - n >= 8 {
		src2 := src[si..si + 8]
		dn := assemble64(enc.decode_map[src2[0]], enc.decode_map[src2[1]], enc.decode_map[src2[2]], enc.decode_map[src2[3]], enc.decode_map[src2[4]], enc.decode_map[src2[5]], enc.decode_map[src2[6]], enc.decode_map[src2[7]])

		dst[n + 0] = (dn >> 56).truncate_cast_to_u8()
		dst[n + 1] = (dn >> 48).truncate_cast_to_u8()
		dst[n + 2] = (dn >> 40).truncate_cast_to_u8()
		dst[n + 3] = (dn >> 32).truncate_cast_to_u8()
		dst[n + 4] = (dn >> 24).truncate_cast_to_u8()
		dst[n + 5] = (dn >> 16).truncate_cast_to_u8()
		dst[n + 6] = (dn >> 8).truncate_cast_to_u8()
		dst[n + 7] = dn.truncate_cast_to_u8()
		n += 6
		si += 8
	}

	for src.len - si >= 4 && dst.len - n >= 4 {
		src2 := src[si..si + 4]
		dn := assemble32(enc.decode_map[src2[0]], enc.decode_map[src2[1]], enc.decode_map[src2[2]], enc.decode_map[src2[3]])

		dst[n + 0] = (dn >> 24).truncate_cast_to_u8()
		dst[n + 1] = (dn >> 16).truncate_cast_to_u8()
		dst[n + 2] = (dn >> 8).truncate_cast_to_u8()
		dst[n + 3] = dn.truncate_cast_to_u8()

		n += 3
		si += 4
	}

	// adjust len to return the correct number of bytes written to dst
	n -= (src[src.len - 1] == `=`) as usize
	n -= (src[src.len - 2] == `=`) as usize

	return n
}

// decoded_len returns the maximum length in bytes of the decoded data
// corresponding to [`n`] bytes of base64-encoded data.
pub fn (enc &Encoding) decoded_len(n usize) -> usize {
	if enc.pad_char == NO_PADDING {
		// unpadded data may end with partial block of 2-3 characters.
		return n * 6 / 8
	}
	// padded base64 should always be a multiple of 4 characters in length.
	return n / 4 * 3
}

// assemble64 assembles 8 digits into 6 bytes.
#[spawnfmt.skip]
fn assemble64(n1 u8, n2 u8, n3 u8, n4 u8, n5 u8, n6 u8, n7 u8, n8 u8) -> u64 {
    return n1 as u64 << 58 |
           n2 as u64 << 52 |
           n3 as u64 << 46 |
           n4 as u64 << 40 |
           n5 as u64 << 34 |
           n6 as u64 << 28 |
           n7 as u64 << 22 |
           n8 as u64 << 16
}

// assemble32 assembles 4 digits into 3 bytes.
#[spawnfmt.skip]
fn assemble32(n1 u8, n2 u8, n3 u8, n4 u8) -> u32 {
    return n1 as u32 << 26 |
           n2 as u32 << 20 |
           n3 as u32 << 14 |
           n4 as u32 << 8
}
