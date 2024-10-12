module env

// find returns the value of the environment variable with the given name.
// If the variable is not set, the empty string is returned.
//
// To distinguish between the empty string and the variable not being set,
// use `find_opt`.
pub fn find(key string) -> string {
	return find_opt(key) or { '' }
}
