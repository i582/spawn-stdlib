module diff

import term
import strings

enum DiffKind {
	insert
	delete
	equal
}

struct Diff {
	kind DiffKind
	text string
}

pub fn compare(mut text1 string, mut text2 string) -> []Diff {
	if text1 == text2 {
		return [Diff{ kind: .equal, text: text1 }]
	}

	// trim common prefix
	prefix_len := common_prefix_len(text1, text2)
	prefix := text1[0..prefix_len]
	text1 = text1[prefix_len..]
	text2 = text2[prefix_len..]

	// trim common suffix
	suffix_len := common_suffix_len(text1, text2)
	suffix := text1[text1.len - suffix_len..]
	text1 = text1[..text1.len - suffix_len]
	text2 = text2[..text2.len - suffix_len]

	// process diff
	mut diffs := compute_diff(text1, text2)

	// add prefix and suffix
	if prefix.len > 0 {
		diffs.push_front_many([Diff{ kind: .equal, text: prefix }])
	}
	if suffix.len > 0 {
		diffs.push_many([Diff{ kind: .equal, text: suffix }])
	}

	return diffs
}

fn compute_diff(text1 string, text2 string) -> []Diff {
	mut diffs := []Diff{}

	if text1.len == 0 {
		// add some text
		return [Diff{ kind: .insert, text: text2 }]
	} else if text2.len == 0 {
		// remove some text
		return [Diff{ kind: .delete, text: text1 }]
	}

	long_text, short_text := if text1.len > text2.len { text1, text2 } else { text2, text1 }

	if index := long_text.index_opt(short_text) {
		mut op := DiffKind.insert
		if text1.len > text2.len {
			op = .delete
		}

		return [Diff{ kind: op, text: long_text[..index.min(long_text.len)] }, Diff{ kind: .equal, text: short_text }, Diff{ kind: op, text: long_text[(index + short_text.len).min(long_text.len)..] }]
	} else if short_text.len == 1 {
		return [Diff{ kind: .delete, text: text1 }, Diff{ kind: .insert, text: text2 }]
	}

	return diff_bisect(text1, text2)
}

fn common_prefix_len(origin string, new string) -> usize {
	mut i := 0 as usize
	for ; i < origin.len && i < new.len && origin[i] == new[i]; i++ {}

	return i
}

fn common_suffix_len(origin string, new string) -> usize {
	mut i1 := origin.len as isize
	mut i2 := new.len as isize

	for n := 0 as usize;; n++ {
		i1--
		i2--

		if i1 < 0 || i2 < 0 || origin[i1] != new[i2] {
			return n
		}
	}
}

pub fn diff_bisect(text1 string, text2 string) -> []Diff {
	runes1_len := text1.len as i32
	runes2_len := text2.len as i32

	max_d := (runes1_len + runes2_len + 1) / 2
	v_offset := max_d
	v_length := 2 * max_d

	mut v1 := []i32{len: v_length}
	mut v2 := []i32{len: v_length}
	for i in 0 .. v_length {
		v1[i] = -1
		v2[i] = -1
	}
	v1[v_offset + 1] = 0
	v2[v_offset + 1] = 0

	delta := runes1_len - runes2_len
	// If the total number of characters is odd, then the front path will collide
	// with the reverse path.
	front := delta % 2 != 0
	// Offsets for start and end of k loop. Prevents mapping of space beyond the
	// grid.
	mut k1start := 0
	mut k1end := 0
	mut k2start := 0
	mut k2end := 0

	for d := 0; d < max_d; d++ {
		// Walk the front path one step.
		for k1 := -d + k1start; k1 <= d - k1end; k1 = k1 + 2 {
			k1_offset := v_offset + k1

			mut x1 := 0
			if k1 == -d || k1 != d && v1.fast_get(k1_offset - 1) < v1.fast_get(k1_offset + 1) {
				x1 = v1.fast_get(k1_offset + 1)
			} else {
				x1 = v1.fast_get(k1_offset - 1) + 1
			}

			mut y1 := x1 - k1
			for x1 < runes1_len && y1 < runes2_len && text1[x1] == text2[y1] {
				x1++
				y1++
			}

			v1[k1_offset] = x1
			if x1 > runes1_len {
				// Ran off the right of the graph.
				k1end = k1end + 2
			} else if y1 > runes2_len {
				// Ran off the bottom of the graph.
				k1start = k1start + 2
			} else if front {
				k2_offset := v_offset + delta - k1
				if k2_offset >= 0 && k2_offset < v_length && v2.fast_get(k2_offset) != -1 {
					// Mirror x2 onto top-left coordinate system.
					x2 := runes1_len - v2.fast_get(k2_offset)
					if x1 >= x2 {
						// Overlap detected.
						return diff_bisect_split(text1, text2, x1, y1)
					}
				}
			}
		}
		// Walk the reverse path one step.
		for k2 := -d + k2start; k2 <= d - k2end; k2 = k2 + 2 {
			k2_offset := v_offset + k2

			mut x2 := 0
			if k2 == -d || k2 != d && v2.fast_get(k2_offset - 1) < v2.fast_get(k2_offset + 1) {
				x2 = v2.fast_get(k2_offset + 1)
			} else {
				x2 = v2.fast_get(k2_offset - 1) + 1
			}

			mut y2 := x2 - k2
			for x2 < runes1_len && y2 < runes2_len && text1[runes1_len - x2 - 1] == text2[runes2_len - y2 - 1] {
				x2++
				y2++
			}

			v2[k2_offset] = x2
			if x2 > runes1_len {
				// Ran off the left of the graph.
				k2end = k2end + 2
			} else if y2 > runes2_len {
				// Ran off the top of the graph.
				k2start = k2start + 2
			} else if !front {
				k1_offset := v_offset + delta - k2
				if k1_offset >= 0 && k1_offset < v_length && v1.fast_get(k1_offset) != -1 {
					x1 := v1.fast_get(k1_offset)
					y1 := v_offset + x1 - k1_offset
					// Mirror x2 onto top-left coordinate system.
					x2 = runes1_len - x2
					if x1 >= x2 {
						// Overlap detected.
						return diff_bisect_split(text1, text2, x1, y1)
					}
				}
			}
		}
	}

	// Diff took too long and hit the deadline or
	// number of diffs equals number of characters, no commonality at all.
	return [Diff{ kind: .delete, text: text1 }, Diff{ kind: .insert, text: text2 }]
}

fn diff_bisect_split(text1 string, text2 string, x usize, y usize) -> []Diff {
	text1a := text1[..x]
	text2a := text2[..y]
	text1b := text1[x..]
	text2b := text2[y..]

	// Compute both diffs serially.
	// TODO: should work with `+` operator
	return compare(text1a, text2a).add(compare(text1b, text2b))
}

pub struct ColoredDiffOptions {
	left_name  string = "left"
	right_name string = "right"
}

pub fn colored_diff(diffs []Diff, opts ...fn (_ &mut ColoredDiffOptions)) -> string {
	mut options := ColoredDiffOptions{}
	for opt in opts {
		opt(&mut options)
	}

	mut sb := strings.new_builder(100)

	sb.write_str(term.bright_red("+++"))
	sb.write_str(" ")
	sb.write_str(options.left_name)
	sb.write_str("\n")
	sb.write_str(term.green("---"))
	sb.write_str(" ")
	sb.write_str(options.right_name)
	sb.write_str("\n")

	for d in diffs {
		text := d.text.clone()

		match d.kind {
			.insert => sb.write_str(term.bright_green(text))
			.delete => sb.write_str(term.bright_red(text))
			.equal => sb.write_str(text)
		}
	}

	return sb.str_view()
}

pub fn default_diff(diffs []Diff) -> string {
	mut sb := strings.new_builder(100)

	for d in diffs {
		text := d.text.clone()

		match d.kind {
			.insert => sb.write_str("+")
			.delete => sb.write_str("-")
			.equal => {}
		}

		sb.write_str(text)
		sb.write_u8(b`\n`)
	}

	return sb.str_view()
}
