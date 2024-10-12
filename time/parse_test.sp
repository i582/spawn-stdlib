module main

import time

const TEST_CASES = [
	("YY-MM-DD", "21-07-27", "2021-07-27T00:00:00Z"), // 2 digit year
	("YYYY-MM-DD", "2021-07-27", "2021-07-27T00:00:00Z"), // 4 digit year
	("M/D/YYYY", "7/27/2021", "2021-07-27T00:00:00Z"), // short month and day
	("M/D/YYYY", "07/27/2021", "2021-07-27T00:00:00Z"), // short month and day with leading zero
	("_M/_D/YYYY", " 7/27/2021", "2021-07-27T00:00:00Z"), // spaced month and day with single digit
	("_M/_D/YYYY", "07/27/2021", "2021-07-27T00:00:00Z"), // spaced month and day with double digit
	("MMMM DD, YYYY", "July 27, 2021", "2021-07-27T00:00:00Z"), // long month name
	("MMM DD, YYYY", "Jul 27, 2021", "2021-07-27T00:00:00Z"), // short month name
	("DD.MM.YYYY", "27.07.2021", "2021-07-27T00:00:00Z"), // day with month
	("h:m:s", "23:59:59", "0001-01-01T23:59:59Z"), // short hour, minute, and second
	("h:m:s", "1:9:5", "0001-01-01T01:09:05Z"), // short hour, minute, and second with single digits
	("hh:mm:ss", "23:59:59", "0001-01-01T23:59:59Z"), // hour, minute, and second
	("h:m:s PM", "1:9:5 PM", "0001-01-01T13:09:05Z"), // short hour, minute, and second with single digits and PM
	("hh:mm:ss PM", "11:59:59 PM", "0001-01-01T23:59:59Z"), // 12-hour time with PM
	// ("Mo YY", "2nd 21", "2021-02-01T00:00:00Z"), // ordinal month // TODO
	("WW, DD MMM YYYY", "Tuesday, 27 Jul 2021", "2021-07-27T00:00:00Z"), // full weekday name
	("W, DD MMM YYYY", "Tue, 27 Jul 2021", "2021-07-27T00:00:00Z"), // short weekday name
	("ZZZ", "+07:00", "0001-01-01T00:00:00+07:00"), // timezone with colon
	("Z", "+7", "0001-01-01T00:00:00+07:00"), // short timezone
	("Z", "+14", "0001-01-01T00:00:00+14:00"), // short timezone
	("ZZ", "+0700", "0001-01-01T00:00:00+07:00"), // timezone without colon
	("ZZ", "+1400", "0001-01-01T00:00:00+14:00"), // timezone without colon
	("ZZZZ", "MST", "0001-01-01T00:00:00-07:00"), // timezone name
	("Q DD.MM.YYYY", "3 27.07.2021", "2021-07-27T00:00:00Z"), // short quarter
	("Q DD.MM.YYYY", "4 27.10.2021", "2021-10-27T00:00:00Z"), // short quarter
	("QQ DD.MM.YYYY", "02 27.04.2021", "2021-04-27T00:00:00Z"), // long quarter
	("QQ DD.MM.YYYY", "01 27.03.2021", "2021-03-27T00:00:00Z"), // long quarter
	("DDD", "1", "0001-01-01T00:00:00Z"), // short year day in unknown year
	("DDD", "60", "0001-02-29T00:00:00Z"), // short year day in unknown year
	("DDD YYYY", "1 2024", "2024-01-01T00:00:00Z"), // short year day
	("DDD YYYY", "2 2024", "2024-01-02T00:00:00Z"), // short year day
	("DDD YYYY", "31 2024", "2024-01-31T00:00:00Z"), // short year day
	("DDD YYYY", "32 2024", "2024-02-01T00:00:00Z"), // short year day
	("DDD YYYY", "60 2024", "2024-02-29T00:00:00Z"), // leap year
	("DDD YYYY", "61 2024", "2024-03-01T00:00:00Z"), // leap year
	("DDD YYYY", "60 2023", "2023-03-01T00:00:00Z"), // non leap year
	("DDDD YYYY", "001 2024", "2024-01-01T00:00:00Z"), // year day
	("DDDD YYYY", "002 2024", "2024-01-02T00:00:00Z"), // year day
	// Long month names
	("MMMM DD, YYYY", "January 27, 2021", "2021-01-27T00:00:00Z"),
	("MMMM DD, YYYY", "February 27, 2021", "2021-02-27T00:00:00Z"),
	("MMMM DD, YYYY", "March 27, 2021", "2021-03-27T00:00:00Z"),
	("MMMM DD, YYYY", "April 27, 2021", "2021-04-27T00:00:00Z"),
	("MMMM DD, YYYY", "May 27, 2021", "2021-05-27T00:00:00Z"),
	("MMMM DD, YYYY", "June 27, 2021", "2021-06-27T00:00:00Z"),
	("MMMM DD, YYYY", "July 27, 2021", "2021-07-27T00:00:00Z"),
	("MMMM DD, YYYY", "August 27, 2021", "2021-08-27T00:00:00Z"),
	("MMMM DD, YYYY", "September 27, 2021", "2021-09-27T00:00:00Z"),
	("MMMM DD, YYYY", "October 27, 2021", "2021-10-27T00:00:00Z"),
	("MMMM DD, YYYY", "November 27, 2021", "2021-11-27T00:00:00Z"),
	("MMMM DD, YYYY", "December 27, 2021", "2021-12-27T00:00:00Z"),
	// Short month names
	("MMM DD, YYYY", "Jan 27, 2021", "2021-01-27T00:00:00Z"),
	("MMM DD, YYYY", "Feb 27, 2021", "2021-02-27T00:00:00Z"),
	("MMM DD, YYYY", "Mar 27, 2021", "2021-03-27T00:00:00Z"),
	("MMM DD, YYYY", "Apr 27, 2021", "2021-04-27T00:00:00Z"),
	("MMM DD, YYYY", "May 27, 2021", "2021-05-27T00:00:00Z"),
	("MMM DD, YYYY", "Jun 27, 2021", "2021-06-27T00:00:00Z"),
	("MMM DD, YYYY", "Jul 27, 2021", "2021-07-27T00:00:00Z"),
	("MMM DD, YYYY", "Aug 27, 2021", "2021-08-27T00:00:00Z"),
	("MMM DD, YYYY", "Sep 27, 2021", "2021-09-27T00:00:00Z"),
	("MMM DD, YYYY", "Oct 27, 2021", "2021-10-27T00:00:00Z"),
	("MMM DD, YYYY", "Nov 27, 2021", "2021-11-27T00:00:00Z"),
	("MMM DD, YYYY", "Dec 27, 2021", "2021-12-27T00:00:00Z"),
	// Full weekday names
	("WW, DD MMM YYYY", "Monday, 26 Jul 2021", "2021-07-26T00:00:00Z"),
	("WW, DD MMM YYYY", "Tuesday, 27 Jul 2021", "2021-07-27T00:00:00Z"),
	("WW, DD MMM YYYY", "Wednesday, 28 Jul 2021", "2021-07-28T00:00:00Z"),
	("WW, DD MMM YYYY", "Thursday, 29 Jul 2021", "2021-07-29T00:00:00Z"),
	("WW, DD MMM YYYY", "Friday, 30 Jul 2021", "2021-07-30T00:00:00Z"),
	("WW, DD MMM YYYY", "Saturday, 31 Jul 2021", "2021-07-31T00:00:00Z"),
	("WW, DD MMM YYYY", "Sunday, 01 Aug 2021", "2021-08-01T00:00:00Z"),
	// Short weekday names
	("W, DD MMM YYYY", "Mon, 26 Jul 2021", "2021-07-26T00:00:00Z"),
	("W, DD MMM YYYY", "Tue, 27 Jul 2021", "2021-07-27T00:00:00Z"),
	("W, DD MMM YYYY", "Wed, 28 Jul 2021", "2021-07-28T00:00:00Z"),
	("W, DD MMM YYYY", "Thu, 29 Jul 2021", "2021-07-29T00:00:00Z"),
	("W, DD MMM YYYY", "Fri, 30 Jul 2021", "2021-07-30T00:00:00Z"),
	("W, DD MMM YYYY", "Sat, 31 Jul 2021", "2021-07-31T00:00:00Z"),
	("W, DD MMM YYYY", "Sun, 01 Aug 2021", "2021-08-01T00:00:00Z"),
	// ANSIC
	(time.ANSIC, "Mon Jan  2 15:04:05 2006", "2006-01-02T15:04:05Z"),
	(time.ANSIC, "Mon Jan  2 03:04:05 2006", "2006-01-02T03:04:05Z"),
	(time.ANSIC, "Mon Jan  2 23:04:05 2006", "2006-01-02T23:04:05Z"),
	// UNIX_DATE
	(time.UNIX_DATE, "Mon Jan  2 15:04:05 MST 2006", "2006-01-02T15:04:05-07:00"),
	(time.UNIX_DATE, "Mon Jan  2 23:04:05 EST 2006", "2006-01-02T23:04:05-05:00"),
	// RFC822
	(time.RFC822, "02 Jan 06 15:04 MST", "2006-01-02T15:04:00-07:00"),
	(time.RFC822, "02 Jan 06 23:04 EST", "2006-01-02T23:04:00-05:00"),
	// RFC822Z
	(time.RFC822Z, "02 Jan 06 15:04 -0700", "2006-01-02T15:04:00-07:00"),
	(time.RFC822Z, "02 Jan 06 03:04 -0800", "2006-01-02T03:04:00-08:00"),
	(time.RFC822Z, "02 Jan 06 23:04 -0500", "2006-01-02T23:04:00-05:00"),
	// RFC850
	(time.RFC850, "Monday, 02-Jan-06 15:04:05 MST", "2006-01-02T15:04:05-07:00"),
	(time.RFC850, "Monday, 02-Jan-06 23:04:05 EST", "2006-01-02T23:04:05-05:00"),
	// RFC1123
	(time.RFC1123, "Mon, 02 Jan 2006 15:04:05 MST", "2006-01-02T15:04:05-07:00"),
	(time.RFC1123, "Mon, 02 Jan 2006 23:04:05 EST", "2006-01-02T23:04:05-05:00"),
	// RFC1123Z
	(time.RFC1123Z, "Mon, 02 Jan 2006 15:04:05 -0700", "2006-01-02T15:04:05-07:00"),
	(time.RFC1123Z, "Mon, 02 Jan 2006 03:04:05 -0800", "2006-01-02T03:04:05-08:00"),
	(time.RFC1123Z, "Mon, 02 Jan 2006 23:04:05 -0500", "2006-01-02T23:04:05-05:00"),
	// RFC3339
	(time.RFC3339, "2006-01-02T15:04:05Z", "2006-01-02T15:04:05Z"),
	(time.RFC3339, "2006-01-02T03:04:05Z", "2006-01-02T03:04:05Z"),
	(time.RFC3339, "2006-01-02T23:04:05Z", "2006-01-02T23:04:05Z"),
	// RFC3339_NANO
	// (time.RFC3339_NANO, "2006-01-02T15:04:05.999999999Z", "2006-01-02T15:04:05.999999999Z"),
	// (time.RFC3339_NANO, "2006-01-02T03:04:05.999999999Z", "2006-01-02T03:04:05.999999999Z"),
	// (time.RFC3339_NANO, "2006-01-02T23:04:05.999999999Z", "2006-01-02T23:04:05.999999999Z"),
	// KITCHEN
	(time.KITCHEN, "3:04PM", "0001-01-01T15:04:00Z"),
	(time.KITCHEN, "3:04AM", "0001-01-01T03:04:00Z"),
	// STAMP
	(time.STAMP, "Jan  2 15:04:05", "0001-01-02T15:04:05Z"),
	(time.STAMP, "Jan  2 03:04:05", "0001-01-02T03:04:05Z"),
	(time.STAMP, "Jan  2 23:04:05", "0001-01-02T23:04:05Z"),
	// DATE_TIME
	(time.DATE_TIME, "2006.01.02 15:04:05", "2006-01-02T15:04:05Z"),
	(time.DATE_TIME, "2006.01.02 03:04:05", "2006-01-02T03:04:05Z"),
	(time.DATE_TIME, "2006.01.02 23:04:05", "2006-01-02T23:04:05Z"),
	// DATE_ONLY
	(time.DATE_ONLY, "2006.01.02", "2006-01-02T00:00:00Z"),
	(time.DATE_ONLY, "1999.12.31", "1999-12-31T00:00:00Z"),
	(time.DATE_ONLY, "2020.05.15", "2020-05-15T00:00:00Z"),
	// TIME_ONLY
	(time.TIME_ONLY, "15:04:05", "0001-01-01T15:04:05Z"),
	(time.TIME_ONLY, "03:04:05", "0001-01-01T03:04:05Z"),
	(time.TIME_ONLY, "23:04:05", "0001-01-01T23:04:05Z"),
]

test "parse date with different formats" {
	for i, case in TEST_CASES {
		layout, value, expected := case
		tim := time.parse(layout, value) or {
			t.fail('unexpected error for ${value} in layout ${layout}: ${err.msg()}')
			continue
		}
		t.assert_eq(tim.format_rfc3339(), expected, 'actual value should be equal to expected in ${i}-case for ${value} in layout ${layout}')
	}
}

test "format date with different formats" {
	for i, case in TEST_CASES {
		if i in [3, 5] {
			continue
		}

		layout, value, _ := case
		tim := time.parse(layout, value) or {
			t.fail('unexpected error for ${value} in layout ${layout}: ${err.msg()}')
			continue
		}

		formatted := tim.custom_format(layout)

		t.assert_eq(formatted, value, 'actual value after format should be equal to expected in ${i}-case for ${value} in layout ${layout}')
	}
}

test "format date with all possible modifiers" {
	layout := "YY YYYY Q Qo QQ M _M Mo MM MMM MMMM _D D DD DDD DDDo DDDD h hh m mm s ss W WW Z ZZ ZZZ ZZZZ PM"

	date := time.parse(time.RFC850, "Monday, 02-Jan-06 15:04:05 MST").unwrap()

	res := date.custom_format(layout)
	expected := '06 2006 1 1st 01 1  1 1st 01 Jan January  2 2 02 2 2nd 002 15 3 4 04 5 05 Mon Monday -7 -0700 -07:00 MST PM'
	t.assert_eq(res, expected, 'actual value after format should be equal to expected')
}
