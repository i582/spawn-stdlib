module main

import rand

#[slow]
test "u64_below_max function call with 0 max return error" {
	_ = rand.u64_below_max(0) or {
		return
	}

	t.fail('function call with 0 max must return error')
}

#[slow]
test "u64_below_max function returns value in range [0, 10000)" {
	mut values := []u64{}

	for _ in 0 .. 1000000 {
		random_number := rand.u64_below_max(10000) or {
			t.fail("function can't return error here!")
			return
		}

		values.push(random_number)
	}

	t.assert_true(values.all(|value| value < 10000), 'function must return value in range [0, 10000)')
}

#[slow]
test "u64_below_max function returns value in range [0, MAX_U64)" {
	mut values := []u64{}

	for _ in 0 .. 1000000 {
		random_number := rand.u64_below_max(MAX_U64) or {
			t.fail("function can't return error here!")
			return
		}

		values.push(random_number)
	}

	t.assert_true(values.all(|value| value < MAX_U64), 'function must return value in range [0, MAX_U64)')
}

#[slow]
test "u64_below_max function returns value in range [0, 1)" {
	mut values := []u64{}

	for _ in 0 .. 1000000 {
		random_number := rand.u64_below_max(1) or {
			t.fail("function can't return error here!")
			return
		}

		values.push(random_number)
	}

	t.assert_true(values.all(|value| value < 1), 'function must return value in range [0, 1)')
}

#[slow]
test "u64_below_max function returns same values for the same seed" {
	rand.create_generator(1337)

	mut previous_values := []u64{}

	for _ in 0 .. 1000 {
		random_number := rand.u64_below_max(10000) or {
			t.fail("function can't return error here!")
			return
		}

		previous_values.push(random_number)
	}

	for _ in 0 .. 1000 {
		rand.create_generator(1337)
		mut values := []u64{}

		for _ in 0 .. 1000 {
			random_number := rand.u64_below_max(10000) or {
				t.fail("function can't return error here!")
				return
			}

			values.push(random_number)
		}

		t.assert_true(values.all(|value| previous_values.contains(value)), 'function must return same values for the same seed')
	}
}

#[slow]
test "u32_below_max function call with 0 max return error" {
	_ = rand.u32_below_max(0) or {
		return
	}

	t.fail('function call with 0 max must return error')
}

#[slow]
test "u32_below_max function returns value in range [0, 10000)" {
	mut values := []u32{}

	for _ in 0 .. 1000000 {
		random_number := rand.u32_below_max(10000) or {
			t.fail("function can't return error here!")
			return
		}

		values.push(random_number)
	}

	t.assert_true(values.all(|value| value < 10000), 'function must return value in range [0, 10000)')
}

#[slow]
test "u32_below_max function returns value in range [0, MAX_U32)" {
	mut values := []u32{}

	for _ in 0 .. 1000000 {
		random_number := rand.u32_below_max(MAX_U32) or {
			t.fail("function can't return error here!")
			return
		}

		values.push(random_number)
	}

	t.assert_true(values.all(|value| value < MAX_U32), 'function must return value in range [0, MAX_U32)')
}

#[slow]
test "u32_below_max function returns value in range [0, 1)" {
	mut values := []u32{}

	for _ in 0 .. 1000000 {
		random_number := rand.u32_below_max(1) or {
			t.fail("function can't return error here!")
			return
		}

		values.push(random_number)
	}

	t.assert_true(values.all(|value| value < 1), 'function must return value in range [0, 1)')
}

#[slow]
test "u32_below_max function returns same values for the same seed" {
	rand.create_generator(1337)

	mut previous_values := []u32{}

	for _ in 0 .. 1000 {
		random_number := rand.u32_below_max(10000) or {
			t.fail("function can't return error here!")
			return
		}

		previous_values.push(random_number)
	}

	for _ in 0 .. 1000 {
		rand.create_generator(1337)
		mut values := []u32{}

		for _ in 0 .. 1000 {
			random_number := rand.u32_below_max(10000) or {
				t.fail("function can't return error here!")
				return
			}

			values.push(random_number)
		}

		t.assert_true(values.all(|value| previous_values.contains(value)), 'function must return same values for the same seed')
	}
}

// TODO: this test is unstable, sometimes it fails and sometimes it passes.
//       I'm not sure if this is problem in crappy random generator or in crappy implementation of the test.
//       Someone with deep understanding of random should figure it out.
// test 'function returns uniformly distributed values' {
//     max := 100 as u32
//     samples := max * 5 as u32
//     mut values_count := [100]u32{}
//
//     for _ in 0 .. samples {
//         random_number := rand.u32_below_max(max) or {
//             t.fail("function can't return error here!")
//             return
//         }
//
//         values_count[random_number] += 1
//     }
//
//     expected_distribution := samples as f64 / max as f64
//     mut chi_squared := 0.0
//
//     for value in values_count {
//         diff := value as f64 - expected_distribution
//
//         if diff.eq_epsilon(0) {
//             continue
//         }
//
//         chi_squared += diff * diff / expected_distribution;
//     }
//
//     t.assert_true(chi_squared < (0.05 + ((max - 1) as f64)), 'function must return uniformly distributed values')
// }

// TODO: I'm not sure if this test makes any sense. I mean there are situations where 2 same numbers generated by random immediately
//       and seems this is not a corrupted behaviour.
//       Someone with deep understanding of random should figure it out.
// test 'function returns numbers with no immediate repetition' {
//     mut values := []u32{}
//
//     for _ in 0 .. 1000000 {
//         random_number := rand.u32_below_max(1000) or {
//             t.fail("function can't return error here!")
//             return
//         }
//
//         values.push(random_number)
//     }
//
//     for i in 0 .. values.len - 1 {
//         t.assert_true(values[i] != values[i + 1], 'function must return numbers with no immediate repetition')
//     }
// }

#[slow]
test "u32_in_range function call with same min and max returns error" {
	_ = rand.u32_in_range(1, 1) or {
		return
	}

	t.fail('function call with same min and max must return error')
}

#[slow]
test "u32_in_range function call with min > max returns error" {
	random_number := rand.u32_in_range(2, 1) or {
		return
	}

	t.fail('function call with min > max must return error')
}

#[slow]
test "u32_in_range function returns 0 for range [0, 1)" {
	mut values := []u32{}

	for _ in 0 .. 1000000 {
		random_number := rand.u32_in_range(0, 1) or {
			t.fail("function can't return error here!")
			return
		}

		values.push(random_number)
	}

	t.assert_true(values.all(|value| value == 0), 'function must return 0 for range [0, 1)')
}

#[slow]
test "u32_in_range function returns values in range [1, 10000)" {
	mut values := []u32{}

	for _ in 0 .. 1000000 {
		random_number := rand.u32_in_range(1, 10000) or {
			t.fail("function can't return error here!")
			return
		}

		values.push(random_number)
	}

	t.assert_true(values.all(|value| value >= 1 && value < 10000), 'function must return values in range [1, 10000)')
}

#[slow]
test "u32_below_max function returns value in range [1, MAX_U32)" {
	mut values := []u32{}

	for _ in 0 .. 1000000 {
		random_number := rand.u32_in_range(1, MAX_U32) or {
			t.fail("function can't return error here!")
			return
		}

		values.push(random_number)
	}

	t.assert_true(values.all(|value| value >= 1 && value < MAX_U32), 'function must return value in range [0, MAX_U32)')
}

#[slow]
test "u32_in_range function returns same values for the same seed" {
	rand.create_generator(1337)

	mut previous_values := []u32{}

	for _ in 0 .. 1000 {
		random_number := rand.u32_in_range(0, 10000) or {
			t.fail("function can't return error here!")
			return
		}

		previous_values.push(random_number)
	}

	for _ in 0 .. 1000 {
		rand.create_generator(1337)
		mut values := []u32{}

		for _ in 0 .. 1000 {
			random_number := rand.u32_in_range(0, 10000) or {
				t.fail("function can't return error here!")
				return
			}

			values.push(random_number)
		}

		t.assert_true(values.all(|value| previous_values.contains(value)), 'function must return same values for the same seed')
	}
}
