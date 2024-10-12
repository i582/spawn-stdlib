# `leb128` module

Provides functions for encoding and decoding LEB128 (Little Endian Base 128)
data.

LEB128 is a variable-length encoding scheme used for encoding integer values.
This module includes functions to encode and decode both signed and unsigned
64-bit integers. The encoding format is used in various applications, including
file formats and network protocols, to efficiently represent integer values.

### Example

Encoding and decoding a signed 64-bit integer:

```spawn
mut buffer := []u8{len: 20}
len := leb128.encode_i64(-1234567890123456789 as i64, &mut buffer)
assert buffer[..len] == [0x1d as u8, 0x7f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]

decoded, bytes_read := leb128.decode_i64(buffer[..encoded_size])
assert decoded == -1234567890123456789 as i64
assert bytes_read == encoded_size
```

Additional Information

- The LEB128 encoding scheme is designed to be efficient for encoding
  integers of various sizes while keeping the representation compact.
- The i64 encoding considers a sign extension, while the u64 encoding is
  straightforward and does not require sign handling.
- For encoding and decoding smaller integer types, cast them to i64 or u64
  before passing to the respective functions.
