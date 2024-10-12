module main

import rand

#[slow]
test "next_f32 function returns value in range [0, 1)" {
	mut values := []f32{}

	for _ in 0 .. 10 {
		random_number := rand.next_f32()
		values.push(random_number)
	}

	t.assert_true(values.all(|value| (value > 0 || value.eq_epsilon(0)) && value < 1), 'Function must return value in range [0, 1)')
}

#[slow]
test "next_f32 function returns same values for the same seed" {
	rand.create_generator(1337)

	mut previous_values := []f32{}

	for _ in 0 .. 1000 {
		random_number := rand.next_f32()
		previous_values.push(random_number)
	}

	for _ in 0 .. 1000 {
		rand.create_generator(1337)
		mut values := []f32{}

		for _ in 0 .. 1000 {
			random_number := rand.next_f32()
			values.push(random_number)
		}

		t.assert_true(values.all(|value| previous_values.contains(value)), 'Function must return same values for the same seed')
	}
}
