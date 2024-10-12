module strings

import intrinsics

// levenshtein_distance returns the Levenshtein distance between two strings.
// The Levenshtein distance is the number of insertions, deletions, and
// substitutions required to transform one string into another.
//
// Example:
// ```
// assert levenshtein_distance("kitten", "sitting") == 3
// ```
//
// The algorithm is from:
// https://en.wikipedia.org/wiki/Levenshtein_distance#Iterative_with_two_matrix_rows
pub fn levenshtein_distance(a string, b string) -> usize {
	mut f := [0 as usize].repeat(b.len + 1)
	for i in 0 .. f.len {
		f[i] = i
	}
	for ca in a {
		mut j := 1
		mut fj1 := f[0]
		f[0] = f[0] + 1
		for cb in b {
			mut mn := if f[j] + 1 <= f[j - 1] + 1 { f[j] + 1 } else { f[j - 1] + 1 }
			if cb != ca {
				mn = if mn <= fj1 + 1 { mn } else { fj1 + 1 }
			} else {
				mn = if mn <= fj1 { mn } else { fj1 }
			}
			fj1 = f[j]
			f[j] = mn
			j++
		}
	}
	return f[f.len - 1]
}

// levenshtein_distance_percentage returns the Levenshtein distance between two
// strings as a percentage of the length of the longest string.
//
// Example:
// ```
// assert levenshtein_distance_percentage("kitten", "sitting") == 57.142857
// ```
pub fn levenshtein_distance_percentage(a string, b string) -> f64 {
	l := if a.len >= b.len { a.len } else { b.len }

	if intrinsics.unlikely(l == 0) {
		return 100.0
	}

	d := levenshtein_distance(a, b)
	lenght_distance_difference := l - d

	if lenght_distance_difference == 0 {
		return 0.0
	}

	return (lenght_distance_difference as f64 / l as f64) * 100.00
}

// dice_coefficient returns the Dice coefficient between two strings.
//
// It returns a float value between 0.0 and 1.0, where 1.0 means the
// strings are identical and 0.0 means they have no bigrams in common.
//
// The Dice coefficient is a measure of how similar two strings are. It is
// defined as 2 * |A ∩ B| / (|A| + |B|), where A and B are the sets of bigrams
// in the two strings.
//
// Example:
// ```
// assert dice_coefficient("night", "nacht") == 0.5
// ```
pub fn dice_coefficient(s1 string, s2 string) -> f64 {
	if s1.len == 0 || s2.len == 0 {
		return 0.0
	}
	if s1 == s2 {
		return 1.0
	}
	if s1.len < 2 || s2.len < 2 {
		return 0.0
	}

	a := if s1.len > s2.len { s1 } else { s2 }
	b := if a == s1 { s2 } else { s1 }

	mut first_bigrams := map[string]i32{}

	for i in 0 .. a.len - 1 {
		bigram := a[i..i + 2]
		q := if val := first_bigrams.get(bigram) { val + 1 } else { 1 }
		first_bigrams[bigram] = q
	}
	mut intersection_size := 0
	for i in 0 .. b.len - 1 {
		bigram := b[i..i + 2]
		count := if val := first_bigrams.get(bigram) { val + 1 } else { 0 }
		if count > 0 {
			first_bigrams[bigram] = count - 1
			intersection_size++
		}
	}
	return (2 * intersection_size) as f64 / (a.len + b.len - 2) as f64
}
