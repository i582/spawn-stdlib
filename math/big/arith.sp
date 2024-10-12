module big

import math.bits

pub fn add_arrays(z &mut []usize, x []usize, y []usize) -> usize {
	mut c := 0 as usize
	for i := 0; i < z.len && i < x.len && i < y.len; i++ {
		zi, cc := bits.add64(x[i], y[i], c)
		z[i] = zi as usize
		c = cc as usize
	}
	return c
}

pub fn add_word_to_array(z &mut []usize, x []usize, y usize) -> usize {
	mut c := y
	for i := 0; i < z.len && i < x.len; i++ {
		zi, cc := bits.add64(x[i], c, 0)
		z[i] = zi as usize
		c = cc as usize
	}
	return c
}

pub fn shl_array_by_word(z &mut []usize, x []usize, s usize) -> usize {
	if z.len == 0 {
		return 0
	}
	if s == 0 {
		z.copy_from(x)
		return 0
	}

	s1 := s & (64 - 1)
	mut s2 := 64 - s1
	s2 &= 64 - 1 // ditto
	c := x[z.len - 1] >> s2

	for i := z.len - 1; i > 0; i-- {
		z[i] = x[i] << s | x[i - 1] >> s2
	}

	z[0] = x[0] << s
	return c
}
