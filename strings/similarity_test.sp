module main

import strings

test "levenshtein_distance function" {
	cases := [
		('', '', 0),
		('hello', 'hello', 0),
		('A', '', 1),
		('', 'ŵ', 2),
		('Java', 'JavaScript', 6),
		('atomic', 'atom', 2),
		('object', 'inject', 2),
		('flaw', 'lawn', 2),
		('A', 'X', 1),
		('gattaca', 'tataa', 3),
		('bullfrog', 'frogger', 7),
	]

	for case in cases {
		first, second, expected := case
		t.assert_eq(strings.levenshtein_distance(first, second), expected, 'actual should be equal to expected')
	}
}

test "levenshtein_distance_percentage function" {
	cases := [
		('', '', 10000),
		('hello', 'hello', 10000),
		('A', '', 0),
		('', 'ŵ', 0),
		('Java', 'JavaScript', 4000),
		('atomic', 'atom', 6666),
		('object', 'inject', 6666),
		('flaw', 'lawn', 5000),
		('A', 'X', 0),
		('gattaca', 'tataa', 5714),
		('bullfrog', 'frogger', 1250),
	]

	for case in cases {
		first, second, expected := case
		t.assert_eq((strings.levenshtein_distance_percentage(first, second) * 100) as i32, expected, 'actual should be equal to expected')
	}
}

test "dice_coefficient function" {
	cases := [
		('', '', 0.0),
		('A', 'A', 1.0),
		('hello', 'hello', 1.0),
		('Java', 'JavaScript', 0.5),
		('gattaca', 'tataa', 0.6),
		('Aldous Huxley', 'Isaac Asimov', 0.0),
	]

	for case in cases {
		first, second, expected := case
		t.assert_eq(strings.dice_coefficient(first, second), expected, 'actual should be equal to expected')
	}
}
