module random

#[include("<Security/SecRandom.h>")]
#[cflags("-framework Security")]

extern {
	pub const errSecSuccess = 0

	pub type SecRandomRef = *void

	// @function SecRandomCopyBytes
	// @abstract
	// Return count random bytes in *bytes, allocated by the caller. It
	// is critical to check the return value for error.
	//
	// @param rnd
	// Only @p kSecRandomDefault is supported.
	//
	// @param count
	// The number of bytes to generate.
	//
	// @param bytes
	// A buffer to fill with random output.
	//
	// @result Return 0 on success, any other value on failure.
	//
	// @discussion
	// If @p rnd is unrecognized or unsupported, @p kSecRandomDefault is
	// used.
	pub fn SecRandomCopyBytes(rnd *mut SecRandomRef, count usize, bytes *mut void) -> i32
}
