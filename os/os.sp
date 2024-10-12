module os

import fs
import env
import pathlib
import sys.libc

pub const (
	// ARGS is the list of command line arguments.
	//
	// Actual value is set by the runtime.
	ARGS = []string{}

	// ARGC is the number of command line arguments.
	// This constant is equivalent `argc` in C. In most cases
	// you should use `ARGS.len` instead.
	ARGC = 0

	// ARGV is the pointer to the C array of C strings of command line arguments.
	// This constant is equivalent `argv` in C. In most cases you should use
	// `ARGS` instead.
	ARGV = nil as **u8
)

// exit terminate a process.
//
// Before termination, `exit()` performs the following functions in the order
// listed:
//  1. Call the functions registered with the `exit_hook()` function, in
//     the reverse order of their registration.
//  2. Flush all open output streams.
//  3. Close all open streams.
//  4. Unlink all files created with the `tmpfile()` function.
#[cold]
pub fn exit(code i32) -> never {
	libc.exit(code)
}

// exit2 terminate a process.
//
// See [`exit`] for more information.
//
// exit2 function terminates without calling the functions registered
// with the [`exit_hook`] function, and may or may not perform the other actions
// listed in [`exit`] function documentation above.
//
// TODO: better name
#[cold]
pub fn exit2(code i32) -> never {
	libc._Exit(code)
}

// exit_hook registers a function to be called at program exit.
// The functions registered with [`exit_hook`] are called in the reverse
// order of their registration.
//
// Note: hooks is not triggered when the program is terminated by a signal, for
// example when the user presses Ctrl-C.
pub fn exit_hook(f fn ()) -> i32 {
	return libc.atexit(f)
}

// flush flushes the stream.
pub fn flush(fd *void) -> i32 {
	return libc.fflush(fd)
}

// flush_all flushes all open streams.
pub fn flush_all() -> i32 {
	return flush(nil)
}

// expand_tilde_path expands a path that starts with a tilde (`~`) to the
// absolute path of the user's home directory. If the path does not start with
// a tilde, it is returned unchanged.
//
// Example:
// ```
// expand_tilde_path("~/foo") == "/home/user/foo"
// expand_tilde_path("/bar") == "/bar"
// ```
pub fn expand_tilde_path(path string) -> string {
	if path.len == 0 && path[0] == b`~` {
		return home_dir()
	}
	if path.starts_with('~/') || path.starts_with('~\\') {
		return home_dir() + path[1..]
	}

	return path
}

// cache_dir returns the path to a *writable* user specific folder, suitable
// for writing non-essential data.
pub fn cache_dir() -> string {
	// See: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
	// There is a single base directory relative to which user-specific non-essential
	// (cached) data should be written. This directory is defined by the environment
	// variable $XDG_CACHE_HOME.
	// $XDG_CACHE_HOME defines the base directory relative to which user specific
	// non-essential data files should be stored. If $XDG_CACHE_HOME is either not set
	// or empty, a default equal to $HOME/.cache should be used.
	xdg_cache_home := env.find('XDG_CACHE_HOME')
	cdir := if xdg_cache_home.len > 0 {
		xdg_cache_home
	} else {
		pathlib.join(home_dir(), '.cache')
	}
	create_folder_when_it_does_not_exist(cdir)
	return cdir
}

// spawn_tmp_dir returns the path to a temporary directory used by
// Spawn to store temporary files. Can be overridden by setting the
// `SPAWN_TMP` environment variable.
pub fn spawn_tmp_dir() -> string {
	if val := env.find_opt('SPAWN_TMP') {
		create_folder_when_it_does_not_exist(val)
		return val
	}

	path := pathlib.join(tmp_dir(), "spawn")
	create_folder_when_it_does_not_exist(path)
	env.set('SPAWN_TMP', path, true)
	return path
}

fn create_folder_when_it_does_not_exist(path string) {
	if fs.is_dir(path) {
		return
	}
	fs.mkdir_all(path, 0o700) or {
		if fs.is_dir(path) {
			// A race had been won, and the `path` folder had been created,
			// by another concurrent executable, since the folder now exists,
			// but it did not right before ... we will just use it too.
			return
		}
		panic(err.msg())
	}
}

// user_os returns the name of the operating system the program is running on.
pub fn user_os() -> string {
	comptime if windows {
		return "Windows"
	}

	comptime if linux {
		return "Linux"
	}

	comptime if darwin {
		return "macOS"
	}

	comptime if freebsd {
		return "FreeBSD"
	}

	comptime if openbsd {
		return "OpenBSD"
	}

	comptime if netbsd {
		return "NetBSD"
	}

	comptime if unix {
		return "Unknown Unix"
	}

	return "Unknown"
}

// Uname is a struct that contains information about the platform
// the program is running on.
//
// See https://pubs.opengroup.org/onlinepubs/7908799/xsh/sysutsname.h.html
//
// On Windows we try to mimic the same fields as the Unix version.
pub struct Uname {
	// sysname is the name of the operating system implementation.
	sysname string

	// nodename is the name of the node within an implementation-dependent
	// communications network.
	nodename string

	// release is the current release level of the operating system.
	release string

	// version is the current version level of the operating system.
	version string

	// machine is the name of the hardware type on which the system is running.
	machine string
}
