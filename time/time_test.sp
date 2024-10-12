module main

import time

test "days_from_unix_epoch function" {
	cases := [
		// (year, month, day, expected)
		(1970, 1, 1, 0),
		(1970, 1, 2, 1),
		(1969, 12, 31, -1),
		(2000, 1, 1, 10957),
		(2020, 7, 27, 18470),
		(1960, 1, 1, -3653),
		(1900, 1, 1, -25567),
		(2100, 1, 1, 47482),
		(2000, 2, 29, 11016), // Leap year
		(2001, 3, 1, 11382),
		(1600, 1, 1, -135140), // Far past date
		(2400, 1, 1, 157054), // Far future date
	]

	for case in cases {
		year, month, day, expected := case
		t.assert_eq(time.days_from_unix_epoch(year, month, day), expected, "actual should be equal to expected for date ${year}-${month}-${day}")
	}
}

test "from_days_after_unix_epoch function" {
	cases := [
		// (days, expected_year, expected_month, expected_day)
		(0, 1970, 1, 1),
		(1, 1970, 1, 2),
		(-1, 1969, 12, 31),
		(10957, 2000, 1, 1),
		(18470, 2020, 7, 27),
		(-3653, 1960, 1, 1),
		(-25567, 1900, 1, 1),
		(47482, 2100, 1, 1),
		(11016, 2000, 2, 29), // Leap year
		(11382, 2001, 3, 1),
		(-135140, 1600, 1, 1), // Far past date
		(157054, 2400, 1, 1), // Far future date
	]

	for case in cases {
		days, expected_year, expected_month, expected_day := case
		result := time.Time.from_days_after_unix_epoch(days)
		t.assert_eq(result.year, expected_year, "year should be equal to expected for days ${days}")
		t.assert_eq(result.month, expected_month, "month should be equal to expected for days ${days}")
		t.assert_eq(result.day, expected_day, "day should be equal to expected for days ${days}")
	}
}

test "relative time method" {
	cases := [
		// (time_offset, expected_relative_string)
		(0, "now"),
		(20, "now"),
		(time.SECONDS_PER_MINUTE - 5, "1 minute ago"),
		(time.SECONDS_PER_MINUTE, "1 minute ago"),
		(2 * time.SECONDS_PER_MINUTE, "2 minutes ago"),
		(time.SECONDS_PER_HOUR, "1 hour ago"),
		(2 * time.SECONDS_PER_HOUR, "2 hours ago"),
		(time.SECONDS_PER_DAY, "1 day ago"),
		(2 * time.SECONDS_PER_DAY, "2 days ago"),
		(time.SECONDS_PER_WEEK, "1 week ago"),
		(2 * time.SECONDS_PER_WEEK, "2 weeks ago"),
		(time.SECONDS_PER_YEAR, "1 year ago"),
		(2 * time.SECONDS_PER_YEAR, "2 years ago"),
		(-time.SECONDS_PER_MINUTE, "in 1 minute"),
		(-2 * time.SECONDS_PER_MINUTE, "in 2 minutes"),
		(-time.SECONDS_PER_HOUR, "in 1 hour"),
		(-2 * time.SECONDS_PER_HOUR, "in 2 hours"),
		(-time.SECONDS_PER_DAY, "in 1 day"),
		(-2 * time.SECONDS_PER_DAY, "in 2 days"),
		(-time.SECONDS_PER_WEEK, "in 1 week"),
		(-2 * time.SECONDS_PER_WEEK, "in 2 weeks"),
		(-time.SECONDS_PER_YEAR, "in 1 year"),
		(-2 * time.SECONDS_PER_YEAR, "in 2 years"),
	]

	for case in cases {
		time_offset, expected_relative_string := case

		base_time := time.Time.now()
		relative_time := if time_offset < 0 {
			base_time.add((-time_offset) * time.SECOND)
		} else {
			base_time.sub(time_offset * time.SECOND)
		}
		t.assert_eq(relative_time.relative(), expected_relative_string, "relative time should be correct for offset ${time_offset}")
	}
}

test "relative short time method" {
	cases := [
		// (time_offset, expected_relative_string)
		(0, "now"),
		(20, "now"),
		(time.SECONDS_PER_MINUTE - 5, "1m ago"),
		(time.SECONDS_PER_MINUTE, "1m ago"),
		(2 * time.SECONDS_PER_MINUTE, "2m ago"),
		(time.SECONDS_PER_HOUR, "1h ago"),
		(2 * time.SECONDS_PER_HOUR, "2h ago"),
		(time.SECONDS_PER_DAY, "1d ago"),
		(2 * time.SECONDS_PER_DAY, "2d ago"),
		(time.SECONDS_PER_WEEK, "1w ago"),
		(2 * time.SECONDS_PER_WEEK, "2w ago"),
		(time.SECONDS_PER_YEAR, "1y ago"),
		(2 * time.SECONDS_PER_YEAR, "2y ago"),
		(-time.SECONDS_PER_MINUTE, "in 1m"),
		(-2 * time.SECONDS_PER_MINUTE, "in 2m"),
		(-time.SECONDS_PER_HOUR, "in 1h"),
		(-2 * time.SECONDS_PER_HOUR, "in 2h"),
		(-time.SECONDS_PER_DAY, "in 1d"),
		(-2 * time.SECONDS_PER_DAY, "in 2d"),
		(-time.SECONDS_PER_WEEK, "in 1w"),
		(-2 * time.SECONDS_PER_WEEK, "in 2w"),
		(-time.SECONDS_PER_YEAR, "in 1y"),
		(-2 * time.SECONDS_PER_YEAR, "in 2y"),
	]

	for case in cases {
		time_offset, expected_relative_string := case

		base_time := time.Time.now()
		relative_time := if time_offset < 0 {
			base_time.add((-time_offset) * time.SECOND)
		} else {
			base_time.sub(time_offset * time.SECOND)
		}
		t.assert_eq(relative_time.relative_short(), expected_relative_string, "relative short time should be correct for offset ${time_offset}")
	}
}

test "duration as string method" {
	cases := [
		(0 as time.Duration, "0s"),
		(1 as time.Duration, "1ns"),
		(234 as time.Duration, "234ns"),
		(1007 as time.Duration, "1.007us"),
		(7007 as time.Duration, "7.007us"),
		(15007 as time.Duration, "15.007us"),
		(33015 as time.Duration, "33.015us"),
		(1533 as time.Duration, "1.533us"),
		(3723000 as time.Duration, "3.723ms"),
		(1000000 as time.Duration, "1.000ms"),
		(1533000 as time.Duration, "1.533ms"),
		(60000000000 as time.Duration, "1:00.000"),
		(3723000000000 as time.Duration, "1:02:03"),
		(86400000000000 as time.Duration, "24:00:00"),
		(72000000000000 as time.Duration, "20:00:00"),
		(1234567890000 as time.Duration, "20:34.567"),
		(987654321000 as time.Duration, "16:27.654"),
		(time.INFINITE - 1, "2562047:47:16"),
		(time.INFINITE, "inf"),
	]

	for case in cases {
		duration, expected := case
		t.assert_eq(duration.str(), expected, 'actual value should be equal to expected')
	}
}

test "duration as string method with special constants" {
	cases := [
		(1 as i64 * time.NANOSECOND, "1ns"),
		(123 as i64 * time.MICROSECOND, "123.000us"),
		(1999 as i64 * time.MILLISECOND, "1.999s"),
		(100 as i64 * time.SECOND, "1:40.000"),
		(23 as i64 * time.MINUTE, "23:00.000"),
		(2 as i64 * time.HOUR, "2:00:00"),
	]

	for case in cases {
		duration, expected := case
		t.assert_eq((duration as time.Duration).str(), expected, 'actual value should be equal to expected')
	}
}

test "as_secs method" {
	cases := [
		(1 as time.Duration, 0),
		(999_999_999 as time.Duration, 0),
		(1_000_000_000 as time.Duration, 1),
		(1_500_000_000 as time.Duration, 1),
		(2_000_000_000 as time.Duration, 2),
		(60_000_000_000 as time.Duration, 60),
		(3_600_000_000_000 as time.Duration, 3600),
	]

	for case in cases {
		duration, expected := case
		t.assert_eq(duration.as_secs(), expected, 'actual value should be equal to expected')
	}
}

test "as_millis method" {
	cases := [
		(1 as time.Duration, 0),
		(999_999 as time.Duration, 0),
		(1_000_000 as time.Duration, 1),
		(1_500_000 as time.Duration, 1),
		(2_000_000 as time.Duration, 2),
		(60_000_000 as time.Duration, 60),
		(3_600_000_000 as time.Duration, 3600),
	]

	for case in cases {
		duration, expected := case
		t.assert_eq(duration.as_millis(), expected, 'actual value should be equal to expected')
	}
}

test "as_micros method" {
	cases := [
		(1 as time.Duration, 0),
		(999 as time.Duration, 0),
		(1_000 as time.Duration, 1),
		(1_500 as time.Duration, 1),
		(2_000 as time.Duration, 2),
		(60_000 as time.Duration, 60),
		(3_600_000 as time.Duration, 3600),
	]

	for case in cases {
		duration, expected := case
		t.assert_eq(duration.as_micros(), expected, 'actual value should be equal to expected')
	}
}

test "as_nanos method" {
	cases := [
		(1 as time.Duration, 1),
		(999 as time.Duration, 999),
		(1_000 as time.Duration, 1_000),
		(1_500 as time.Duration, 1_500),
		(2_000 as time.Duration, 2_000),
		(60_000 as time.Duration, 60_000),
		(3_600_000 as time.Duration, 3_600_000),
	]

	for case in cases {
		duration, expected := case
		t.assert_eq(duration.as_nanos(), expected, 'actual value should be equal to expected')
	}
}
