module crc32

// Predefined polynomials.
const (
	// IEEE is by far and away the most common CRC-32 polynomial.
	// Used by ethernet (IEEE 802.3), v.42, fddi, gzip, zip, png, ...
	IEEE = 0xedb88320 as u32

	// Castagnoli's polynomial, used in iSCSI.
	// Has better error detection characteristics than IEEE.
	// https://dx.doi.org/10.1109/26.231911
	CASTAGNOLI = 0x82f63b78 as u32

	// Koopman's polynomial.
	// Also has better error detection characteristics than IEEE.
	// https://dx.doi.org/10.1109/DSN.2002.1028931
	KOOPMAN = 0xeb31d82e as u32
)

struct Crc32 {
	table [256]u32
}

fn (c &mut Crc32) gen_table(poly u32) {
	for i in 0 .. 256 {
		mut crc := i as u32
		for j := 0; j < 8; j++ {
			if crc & 1 != 0 {
				crc = (crc >> 1) ^ poly
			} else {
				crc = crc >> 1
			}
		}
		c.table[i] = crc
	}
}

fn (c &Crc32) sum32(data []u8) -> u32 {
	mut crc := ~(0 as u32)
	for i in 0 .. data.len {
		crc = c.table[(crc ^ data.fast_get(i)) & 0xff] ^ (crc >> 8)
	}
	return ~crc
}

pub fn (c &Crc32) checksum(data []u8) -> u32 {
	return c.sum32(data)
}

pub fn new(poly u32) -> Crc32 {
	mut c := Crc32{}
	c.gen_table(poly)
	return c
}

pub fn sum(data []u8) -> u32 {
	c := new(IEEE)
	return c.sum32(data)
}
