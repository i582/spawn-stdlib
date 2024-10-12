module main

test "exclusive range" {
	range := Range.exclusive[isize](3, 10)

	t.assert_eq(range.str(), '3..10', 'actual value should be equal to expected')
	t.assert_opt_eq(range.start_bound(), 3, 'actual value should be equal to expected')
	t.assert_opt_eq(range.end_bound(), 10, 'actual value should be equal to expected')
	t.assert_false(range.inclusive, 'actual value should be equal to expected')
}

test "inclusive range" {
	range := Range.inclusive[isize](3, 10)

	t.assert_eq(range.str(), '3..=10', 'actual value should be equal to expected')
	t.assert_opt_eq(range.start_bound(), 3, 'actual value should be equal to expected')
	t.assert_opt_eq(range.end_bound(), 10, 'actual value should be equal to expected')
	t.assert_true(range.inclusive, 'actual value should be equal to expected')
}

test "to range" {
	range := Range.to[isize](10)

	t.assert_eq(range.str(), '..10', 'actual value should be equal to expected')
	t.assert_none(range.start_bound(), 'actual value should be equal to expected')
	t.assert_opt_eq(range.end_bound(), 10, 'actual value should be equal to expected')
	t.assert_false(range.inclusive, 'actual value should be equal to expected')
}

test "to inclusive range" {
	range := Range.to_inclusive[isize](10)

	t.assert_eq(range.str(), '..=10', 'actual value should be equal to expected')
	t.assert_none(range.start_bound(), 'actual value should be equal to expected')
	t.assert_opt_eq(range.end_bound(), 10, 'actual value should be equal to expected')
	t.assert_true(range.inclusive, 'actual value should be equal to expected')
}

test "from range" {
	range := Range.from[isize](10)

	t.assert_eq(range.str(), '10..', 'actual value should be equal to expected')
	t.assert_opt_eq(range.start_bound(), 10, 'actual value should be equal to expected')
	t.assert_none(range.end_bound(), 'actual value should be equal to expected')
	t.assert_false(range.inclusive, 'actual value should be equal to expected')
}
