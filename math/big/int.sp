module big

pub const (
	// ZERO_INT = &mut Int{ abs: [] }
	ONE_INT  = Int.new(1)
	TWO_INT  = Int.new(2)
	TEN_INT  = Int.new(10)
)

pub struct Int {
	neg bool
	abs Nat
}

pub fn Int.new(val i64) -> &mut Int {
	mut u := val
	if val < 0 {
		u = -u
	}

	abs := if u == 0 { []usize{} } else { [u as usize] }
	return &mut Int{ neg: val < 0, abs: abs }
}

pub fn (z &mut Int) add(x &Int, y &Int) -> &mut Int {
	mut neg := x.neg
	if x.neg == y.neg {
		// x + y == x + y
		// (-x) + (-y) == -(x + y)
		z.abs = z.abs.add(x.abs, y.abs)
	} else {
		// x + (-y) == x - y == -(y - x)
		// (-x) + y == y - x == -(x - y)
		// if x.abs.cmp(y.abs) >= 0 {
		//     z.abs = z.abs.sub(x.abs, y.abs)
		// } else {
		//     neg = !neg
		//     z.abs = z.abs.sub(y.abs, x.abs)
		// }
	}
	z.neg = z.abs.len > 0 && neg // 0 has no sign
	return z
}

pub fn (z &mut Int) shl(x &Int, n usize) -> &mut Int {
	z.abs = z.abs.shl(x.abs, n)
	z.neg = x.neg
	return z
}
