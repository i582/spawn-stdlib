module big

import intrinsics

type Nat = []usize

pub fn (z &mut Nat) make(n usize) -> Nat {
	if intrinsics.likely(n <= z.cap) {
		// reuse z
		z.set_len(n)
		return z[..n]
	}
	if n == 1 {
		// Most nats start small and stay that way; don't over-allocate.
		return []usize{len: 1}
	}

	// Choosing a good value for e has significant performance impact
	// because it increases the chance that a value can be reused.
	e := 4
	return []usize{len: n, cap: n * e}
}

pub fn (z &mut Nat) set_val(x Nat) -> Nat {
	z1 := z.make(x.len)
	z1.copy_from(x)
	return z1
}

pub fn (z &mut Nat) add(x Nat, y Nat) -> Nat {
	m := x.len
	n := y.len

	match {
		m < n => return z.add(y, x)
		m == 0 => {
			// n == 0 because m >= n; result is 0
			return z[..0]
		}
		n == 0 => {
			// result is x
			return z.set_val(x)
		}
	}

	// m > 0

	mut z1 := z.make(m + 1)
	mut c := add_arrays(&mut z1[..n], x, y)
	if m > n {
		c = add_word_to_array(&mut z1[n..m], x[n..], c)
	}
	z1[m] = c

	return z1.norm()
}

pub fn (z Nat) cmp(y Nat) -> Ordering {
	m := z.len
	n := y.len

	if m != n || m == 0 {
		if m < n {
			return .less
		} else if m > n {
			return .greater
		}

		return .equal
	}

	mut i := m - 1
	for i > 0 && z[i] == y[i] {
		i--
	}

	if z[i] < y[i] {
		return .less
	}

	if z[i] > y[i] {
		return .greater
	}

	return .equal
}

pub fn (z &mut Nat) shl(x Nat, s usize) -> Nat {
	m := x.len
	if m == 0 {
		return z[..0]
	}

	n := m + s / 64
	mut z1 := z.make(n + 1)
	z1[n] = shl_array_by_word(&mut z1[n - m..n], x, s % 64)
	(z1[0..n - m] as Nat).clear()

	return z1.norm()
}

pub fn (z &mut Nat) clear() {
	for i in 0 .. z.len {
		z[i] = 0
	}
}

pub fn (z Nat) norm() -> Nat {
	mut i := z.len
	for i > 0 && z[i - 1] == 0 {
		i--
	}
	return z[..i]
}

pub fn (z Nat) itoa(meg bool, base i32) -> string {
	if z.len == 0 {
		return "0"
	}

	return ""
}
