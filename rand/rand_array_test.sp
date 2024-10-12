module main

import rand

#[slow]
test "element function call with empty array returns error" {
	array := []i32{}

	_ = rand.element(array) or {
		return
	}

	t.fail('function call with empty array must return error')
}

#[slow]
test "element function call with one-element array always return 1" {
	array := [1]
	mut values := []usize{}

	for _ in 0 .. 1000000 {
		random_element := rand.element(array) or {
			t.fail("function can't return error here!")
			return
		}

		values.push(random_element)
	}

	t.assert_true(values.all(|value| value == 1), 'function call with one-element array always return 1')
}

#[slow]
test "element function call with 3-elements array always return 1 or 2 or 3" {
	array := [1, 2, 3]
	mut values := []usize{}

	for _ in 0 .. 1000000 {
		random_element := rand.element(array) or {
			t.fail("function can't return error here!")
			return
		}

		values.push(random_element)
	}

	t.assert_true(values.all(|value| value in [1, 2, 3]), 'function call with two-elements array always return 1 or 2 or 3')
}

#[slow]
test "element function returns same values for the same seed" {
	rand.create_generator(1337)
	array := [1, 2, 3, 4, 5]

	mut previous_values := []usize{}

	for _ in 0 .. 1000 {
		random_number := rand.element(array) or {
			t.fail("function can't return error here!")
			return
		}

		previous_values.push(random_number)
	}

	for _ in 0 .. 1000 {
		rand.create_generator(1337)
		mut values := []usize{}

		for _ in 0 .. 1000 {
			random_number := rand.element(array) or {
				t.fail("function can't return error here!")
				return
			}

			values.push(random_number)
		}

		t.assert_true(values.all(|value| previous_values.contains(value)), 'function must return same values for the same seed')
	}
}

#[slow]
test "element_index function call with empty array returns error" {
	array := []i32{}

	_ = rand.element_index(array) or {
		return
	}

	t.fail('function call with empty array must return error')
}

#[slow]
test "element_index function call with one-element array always return 0 index" {
	array := [1]
	mut values := []usize{}

	for _ in 0 .. 1000000 {
		random_element_index := rand.element_index(array) or {
			t.fail("function can't return error here!")
			return
		}

		values.push(random_element_index)
	}

	t.assert_true(values.all(|value| value == 0), 'function call with one-element array always return 0 index')
}

#[slow]
test "element_index function call with two-elements array always return 0 or 1 index" {
	array := [1, 2]
	mut values := []usize{}

	for _ in 0 .. 1000000 {
		random_element_index := rand.element_index(array) or {
			t.fail("function can't return error here!")
			return
		}

		values.push(random_element_index)
	}

	t.assert_true(values.all(|value| value in [0, 1]), 'function call with two-elements array always return 0 or 1 index')
}

#[slow]
test "element_index function returns same values for the same seed" {
	rand.create_generator(1337)
	array := [1, 2, 3, 4, 5]

	mut previous_values := []usize{}

	for _ in 0 .. 1000 {
		random_number := rand.element_index(array) or {
			t.fail("function can't return error here!")
			return
		}

		previous_values.push(random_number)
	}

	for _ in 0 .. 1000 {
		rand.create_generator(1337)
		mut values := []usize{}

		for _ in 0 .. 1000 {
			random_number := rand.element_index(array) or {
				t.fail("function can't return error here!")
				return
			}

			values.push(random_number)
		}

		t.assert_true(values.all(|value| previous_values.contains(value)), 'function must return same values for the same seed')
	}
}
