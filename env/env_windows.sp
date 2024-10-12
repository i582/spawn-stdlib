module env

import sys.winapi

// find_opt returns the value of the environment variable with the given name.
// If the variable is not set, `none` is returned.
pub fn find_opt(key string) -> ?string {
	wide_key := key.to_wide()
	env := winapi._wgetenv(wide_key)
	if env == nil {
		return none
	}
	return string.from_wide(env)
}

// set sets the value of the environment variable with the given name.
// If an error occurs, it returns `false`.
pub fn set(key string, value string, overwrite bool) -> bool {
	// On Windows we cannot use `setenv`, so we use `putenv` instead.
	key_value := '${key}=${value}'
	if overwrite {
		return winapi._putenv(key_value.data) == 0
	}

	if find(key).len != 0 {
		// The environment variable already exists and `overwrite` is `false`.
		return true
	}

	return winapi._putenv(key_value.data) == 0
}

// unset unsets the environment variable with the given name.
// If an error occurs, it returns `false`.
pub fn unset(key string) -> bool {
	// On Windows we cannot use `unsetenv`, so we use `putenv` with empty value instead.
	key_value := '${key}='
	return winapi._putenv(key_value.data) == 0
}

// envs returns a map of all environment variables.
pub fn envs() -> map[string]string {
	mut res := map[string]string{}

	// The GetEnvironmentStrings function returns a pointer to a block of memory that
	// contains the environment variables of the calling process.
	// Each environment block contains the environment variables in the following format:
	// Var1=Value1\0
	// Var2=Value2\0
	// Var3=Value3\0
	env := winapi.GetEnvironmentStringsW()
	mut cursor := env

	for cursor != nil && unsafe { *cursor != 0 } {
		// get the next environment variable, `string.from_wide` takes
		// symbols until the first null character
		env_str := string.from_wide(cursor)
		if name, value := env_str.split_once("=") {
			res[name] = value
		}

		// move the cursor to the next environment variable
		// taking into account the length of the current one
		// and the null character at the end
		cursor = unsafe { cursor + env_str.len + 1 }
	}

	winapi.FreeEnvironmentStringsW(env)
	return res
}
