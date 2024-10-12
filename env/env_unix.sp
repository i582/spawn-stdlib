module env

import sys.libc

// find_opt returns the value of the environment variable with the given name.
// If the variable is not set, `none` is returned.
pub fn find_opt(key string) -> ?string {
	env := libc.getenv(key.c_str())
	if env == nil {
		return none
	}
	return string.from_c_str(env)
}

// set sets the value of the environment variable with the given name.
// If an error occurs, it returns `false`.
pub fn set(key string, value string, overwrite bool) -> bool {
	return libc.setenv(key.c_str(), value.c_str(), overwrite as i32) == 0
}

// unset unsets the environment variable with the given name.
// If an error occurs, it returns `false`.
pub fn unset(key string) -> bool {
	return libc.unsetenv(key.c_str()) == 0
}

// envs returns a map of all environment variables.
pub fn envs() -> map[string]string {
	env := libc.environ
	if env == nil {
		return map[string]string{}
	}

	mut res := map[string]string{}
	mut index := 0
	for {
		env_var := unsafe { env[index] as *u8 }
		if env_var == nil {
			break
		}

		// creates view over the C string, it's safe because
		// `.split_once()` will allocate new strings anyway, so
		// we save extra allocations here
		env_str := string.view_from_c_str(env_var)
		if name, value := env_str.split_once("=") {
			res[name] = value
		}

		index++
	}

	return res
}
