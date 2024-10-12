module os

import fs
import env
import sys.libc

// init_args converts passed `argc` and `argv` to an array of strings.
// This function is used by the runtime to initialize `os.ARGS`.
pub fn init_args(argc i32, argv &&void) -> []string {
	// We use `&&void` since in Windows version we need `&&u16` and in Unix version we need `&&u8`.
	// So to simplify call site we use `&&void` and cast it to the correct type here.
	argv_u8 := argv as **u8
	mut args := []string{len: argc}
	for i in 0 .. argc as usize {
		args[i] = unsafe { string.from_c_str(argv_u8[i]) }
	}
	return args
}

// get_wd returns the current working directory.
pub fn get_wd() -> string {
	mut buf := [fs.MAX_PATH_LEN]u8{}
	if libc.getcwd(&mut buf[0], fs.MAX_PATH_LEN) == nil {
		return ''
	}
	return string.from_c_str(&buf[0])
}

// home_dir returns the current user's home directory.
pub fn home_dir() -> string {
	return env.find("HOME")
}

// tmp_dir returns the directory for temporary files.
//
// This directory is suitable for temporary files that are only needed
// during the execution of the program.
pub fn tmp_dir() -> string {
	if val := env.find_opt('TMPDIR') {
		return val
	}
	if val := env.find_opt('TEMP') {
		return val
	}
	if val := env.find_opt('TMP') {
		return val
	}
	return '/tmp'
}

// chdir changes the current working directory to the specified path.
pub fn chdir(path string) -> ! {
	IOError.throw(libc.chdir(path.c_str()) == 0, 'Cannot change directory to "${path}: "')!
}

// uname returns information about the platform the program is running on.
pub fn uname() -> Uname {
	mut uts := libc.utsname{}
	if libc.uname(&mut uts) != 0 {
		return Uname{}
	}
	return Uname{
		sysname: string.from_c_str(uts.sysname)
		nodename: string.from_c_str(uts.nodename)
		release: string.from_c_str(uts.release)
		version: string.from_c_str(uts.version)
		machine: string.from_c_str(uts.machine)
	}
}

// hostname returns the hostname of the machine.
pub fn hostname() -> !string {
	mut buf := [256]u8{}
	IOError.throw(libc.gethostname(&mut buf[0], buf.len()) == 0, 'Cannot get hostname: ')!
	return string.from_c_str(&buf[0])
}
