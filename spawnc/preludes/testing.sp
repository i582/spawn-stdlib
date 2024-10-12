module main

import testing

const (
	TESTING_PATH    = ""
	TEST_REPORTER   = "discard"
	OUTPUT_FORMAT   = ""
	OUTPUT_FILE     = ""
	COVERAGE        = false
	COVERAGE_FILE   = ""
	COVERAGE_FORMAT = ""
	COVERAGE_TYPE   = "set"
)

fn main() {
	mut tr := testing.Tester{ name: "global" }
	tr.set_reporter(TEST_REPORTER)
	tr.set_output(OUTPUT_FORMAT, OUTPUT_FILE)

	/* tests here */

	tr.finish()

	if COVERAGE {
		if cov := testing.dump_coverage(COVERAGE_TYPE, COVERAGE_FORMAT, TESTING_PATH, COVERAGE_FILE) {
			cov.print()
		}
		testing.print_coverage_rate()
	}
}
