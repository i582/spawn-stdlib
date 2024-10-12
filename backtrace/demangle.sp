module backtrace

// This file contains functions for converting C names into readable names on Spawn.
//
// THIS FILE CONTAINS VERY EARLY STAGE FUNCTIONS; THE MANGLING SCHEME IS NOT YET ESTABLISHED.

pub fn demangle(mut name string) -> string {
	if name.starts_with('__anon_func_') {
		idx := name.trim_prefix('__anon_func_').i32()
		return "{{closure ${idx}}}"
	}

	name = name.replace("$ptr_mut", '')
	if name.contains('___') {
		parts := name.split('___')
		return parts.fast_get(0).replace('$', '.') + '.' + demangle_name(parts.fast_get(1))
	}

	return demangle_name(name)
}

pub fn demangle_name(name string) -> string {
	if name.contains('__') {
		parts := name.split('__')
		return demangle_type(parts.fast_get(0)) + '.' + demangle_single_name(parts.fast_get(1))
	}

	return demangle_single_name(name)
}

pub fn demangle_type(name string) -> string {
	if name.contains('_') {
		parts := name.split('_')
		type_name := parts.fast_get(0)
		if parts.len == 2 {
			return type_name + '[' + demangle_type(parts.fast_get(1)) + ']'
		}
	}

	if name.ends_with('$ptr') {
		return '&' + demangle_type(name.substr(0, name.len - 4))
	}

	return name
}

pub fn demangle_single_name(name string) -> string {
	return name
}
