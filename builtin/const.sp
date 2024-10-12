module builtin

// Limits of the various numeric types.
pub const (
	MAX_U8 = 255 as u8
	MIN_U8 = 0 as u8

	MAX_U16 = 65_535 as u16
	MIN_U16 = 0 as u16

	MAX_U32 = 4_294_967_295 as u32
	MIN_U32 = 0 as u32

	MAX_U64 = 18_446_744_073_709_551_615 as u64
	MIN_U64 = 0 as u64

	MAX_U128 = 340_282_366_920_938_463_463_374_607_431_768_211_455 as u128
	MIN_U128 = 0 as u128

	MAX_I8 = 127 as i8
	MIN_I8 = -128 as i8

	MAX_I16 = 32_767 as i16
	MIN_I16 = -32_768 as i16

	MAX_I32 = 2_147_483_647 as i32
	MIN_I32 = -2_147_483_648 as i32

	MAX_I64 = 9_223_372_036_854_775_807 as i64
	MIN_I64 = -9_223_372_036_854_775_808 as i64

	MAX_I128 = 170_141_183_460_469_231_731_687_303_715_884_105_727 as i128
	MIN_I128 = -170_141_183_460_469_231_731_687_303_715_884_105_728 as i128

	MAX_F32              = 0x1p127 * (1 + (1 - 0x1p-23)) as f32 // 3.40282346638528859811704183484516925440e+38
	SMALLEST_NONZERO_F32 = 0x1p-126 * 0x1p-23                   // 1.401298464324817070923729583289916131280e-45

	MAX_F64              = 0x1p1023 * (1 + (1 - 0x1p-52)) as f64 // 1.797693134862315708145274237317043567981e+308
	SMALLEST_NONZERO_F64 = 0x1p-1022 * 0x1p-52                   // 4.9406564584124654417656879286822137236505980e-324

	// NOTE: because of rune is de facto `i32` type, but unicode characters (which is `rune` type is used for) do not cover
	// the whole range of `i32` type, we have these values defined here to define range of valid values for `rune` type.
	// Also, this is the reason why they are called `VALID` values.
	MAX_VALID_RUNE = 0x10FFFF as rune
	MIN_VALID_RUNE = 0 as rune

	MAX_USIZE = 18_446_744_073_709_551_615 as usize // TODO: not true on 32-bit

	MAX_ISIZE = 9_223_372_036_854_775_807 as isize  // TODO: not true on 32-bit
	MIN_ISIZE = -9_223_372_036_854_775_808 as isize // TODO: not true on 32-bit
)
