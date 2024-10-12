module main

test "checked cast of u16 to all unsigned types" {
	zero_u16 := 0 as u16
	max_u16 := 65535 as u16

	t.assert_not_none(zero_u16 as? u8, 'cast 0 to u16 must be successful')
	t.assert_eq(zero_u16 as u32, 0 as u32, 'cast 0 to u32 must be successful')
	t.assert_eq(zero_u16 as u64, 0 as u64, 'cast 0 to u64 must be successful')
	t.assert_eq(zero_u16 as usize, 0 as usize, 'cast 0 to usize must be successful')

	t.assert_none(max_u16 as? u8, 'cast 65535 to u8 must fail')
	t.assert_eq(max_u16 as u32, 65535 as u32, 'cast 65535 to u32 must be successful')
	t.assert_eq(max_u16 as u64, 65535 as u64, 'cast 65535 to u64 must be successful')
	t.assert_eq(max_u16 as usize, 65535 as usize, 'cast 65535 to usize must be successful')
}

test "checked cast of u16 to all signed types" {
	zero_u16 := 0 as u16
	max_i16 := 32767 as u16
	max_i16_plus_1 := 32768 as u16
	max_u16 := 65535 as u16

	t.assert_not_none(zero_u16 as? i8, 'cast 0 to i8 must be successful')
	t.assert_eq(zero_u16 as i16, 0 as i16, 'cast 0 to i16 must be successful')
	t.assert_eq(zero_u16 as i32, 0 as i32, 'cast 0 to i32 must be successful')
	t.assert_eq(zero_u16 as i64, 0 as i64, 'cast 0 to i64 must be successful')
	t.assert_eq(zero_u16 as isize, 0 as isize, 'cast 0 to isize must be successful')

	t.assert_none(max_u16 as? i8, 'cast 65535 to i8 must fail')
	t.assert_none(max_u16 as? i16, 'cast 65535 to i16 must fail')
	t.assert_eq(max_u16 as i32, 65535 as i32, 'cast 65535 to i32 must be successful')
	t.assert_eq(max_u16 as i64, 65535 as i64, 'cast 65535 to i64 must be successful')
	t.assert_eq(max_u16 as isize, 65535 as isize, 'cast 65535 to isize must be successful')

	t.assert_none(max_i16 as? i8, 'cast 32767 to i8 must fail')
	t.assert_not_none(max_i16 as? i16, 'cast 32767 to i16 must be successful')
	t.assert_eq(max_i16 as i32, 32767 as i32, 'cast 32767 to i32 must be successful')
	t.assert_eq(max_i16 as i64, 32767 as i64, 'cast 32767 to i64 must be successful')
	t.assert_eq(max_i16 as isize, 32767 as isize, 'cast 32767 to isize must be successful')

	t.assert_none(max_i16_plus_1 as? i8, 'cast 32768 to i8 must fail')
	t.assert_none(max_i16_plus_1 as? i16, 'cast 32768 to i16 must fail')
	t.assert_eq(max_i16_plus_1 as i32, 32768 as i32, 'cast 32768 to i32 must be successful')
	t.assert_eq(max_i16_plus_1 as i64, 32768 as i64, 'cast 32768 to i64 must be successful')
	t.assert_eq(max_i16_plus_1 as isize, 32768 as isize, 'cast 32768 to isize must be successful')
}
