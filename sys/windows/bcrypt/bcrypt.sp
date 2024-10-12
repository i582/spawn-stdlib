module bcrypt

#[include("<bcrypt.h>")]
#[library_path("libraries/bcrypt")]
#[library("bcrypt")]

extern pub const BCRYPT_USE_SYSTEM_PREFERRED_RNG = 0x00000002

extern pub fn BCryptGenRandom(algo i32, pb_buf *mut void, count i32, flags i32) -> i32
