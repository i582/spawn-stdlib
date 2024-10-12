module pcg

// Implementation is based on Go's v2 rand PCG source code.
// https://cs.opensource.google/go/go/+/refs/tags/go1.22.2:src/math/rand/v2/pcg.go

import math

const (
	MUL_HI    = 2549297995355413924 as u64
	MUL_LO    = 4865540595714422341 as u64
	INC_HI    = 6364136223846793005 as u64
	INC_LO    = 1442695040888963407 as u64
	CHEAP_MUL = 0x0da942042e4dd58b5 as u64
)

pub struct PCG {
	hi u64
	lo u64
}

pub fn PCG.new(seed_hi u64, seed_lo u64) -> PCG {
	return PCG{ hi: seed_hi, lo: seed_lo }
}

pub fn (gen &mut PCG) next() -> (u64, u64) {
	mut hi, mut lo := math.mul_u64(gen.lo, MUL_LO)
	hi += gen.hi * MUL_LO + gen.lo * MUL_HI
	new_lo, c := math.add_u64(lo, INC_LO, 0)
	lo = new_lo
	hi, _ = math.add_u64(hi, INC_HI, c)

	gen.lo = lo
	gen.hi = hi

	return hi, lo
}

pub fn (gen &mut PCG) u64() -> u64 {
	mut hi, lo := gen.next()

	hi ^= hi >> 32
	hi *= CHEAP_MUL
	hi ^= hi >> 48
	hi *= lo | 1

	return hi
}

pub fn (gen &mut PCG) u32() -> u32 {
	return (gen.u64() & 0xFFFF_FFFF as u32) as u32
}
