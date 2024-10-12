module os

import sys.winapi
import fs
import env

// init_args converts passed `argc` and `argv` to an array of strings.
// This function is used by the runtime to initialize `os.ARGS`.
pub fn init_args(argc i32, argv &&void) -> []string {
	// We use `&&void` since in Windows version we need `&&u16` and in Unix version we need `&&u8`.
	// So to simplify call site we use `&&void` and cast it to the correct type here.
	argv_u16 := argv as **u16
	mut args := []string{len: argc}
	for i in 0 .. argc {
		args[i] = unsafe { string.from_wide(argv_u16[i]) }
	}
	return args
}

// get_wd returns the current working directory.
pub fn get_wd() -> string {
	mut buf := [fs.MAX_PATH_LEN]u16{}
	if winapi._wgetcwd(&mut buf[0], fs.MAX_PATH_LEN as usize) == nil {
		return ''
	}
	return string.from_wide(&buf[0])
}

// home_dir returns the current user's home directory.
pub fn home_dir() -> string {
	return env.find_opt("HOME") or { env.find("USERPROFILE") }
}

// tmp_dir returns the directory for temporary files.
//
// This directory is suitable for temporary files that are only needed
// during the execution of the program.
pub fn tmp_dir() -> string {
	mut buf := [fs.MAX_PATH_LEN]u16{}
	ret := winapi.GetTempPath(fs.MAX_PATH_LEN as u32, &mut buf[0])
	if ret != 0 {
		return string.from_wide(&buf[0])
	}

	// TEMP and TMP already checked by GetTempPath
	if val := env.find_opt('TMPDIR') {
		return val
	}
	return 'C:\\tmp'
}

// chdir changes the current working directory to the specified path.
pub fn chdir(path string) -> ! {
	res := winapi._wchdir(path.to_wide())
	if res != 0 {
		return error(IOError.from_errno('chdir failed: '))
	}
}

// uname returns information about the platform the program is running on.
//
// On Windows we cannot rely on `uname` function since it is not available,
// so we try to mimic the output of `uname` as close as possible.
pub fn uname() -> Uname {
	nodename := hostname() or { '' }

	mut sinfo := winapi.SYSTEM_INFO{}
	winapi.GetSystemInfo(&mut sinfo)
	winapi.processor_arch_to_string(sinfo.wProcessorArchitecture)
	machine := winapi.processor_arch_to_string(sinfo.wProcessorArchitecture)

	// cmd /d/c ve returns the Windows version in form:
	// `\r\nMicrosoft Windows [Version 10.0.22621.3296]`
	version_info := exec('cmd /d/c ver').unwrap().output.trim_start('\r\n')

	// Extract the version number from the output.
	// `10.0.22621.3296`
	only_version := version_info.
		split('Version').
		get(1).unwrap_or('').
		trim_suffix(']').
		trim_spaces()

	// index of second dot
	release_end := only_version.index_after(only_version.index('.'), '.')
	if release_end == -1 {
		// mailformed version number
		return Uname{
			sysname: 'Windows_NT'
			nodename: nodename
			release: only_version
			version: version_info
			machine: machine
		}
	}

	// 10.0
	release := only_version[0..release_end]

	return Uname{
		sysname: 'Windows_NT'
		nodename: nodename
		release: release
		version: version_info
		machine: machine
	}
}

// hostname returns the hostname of the machine.
pub fn hostname() -> !string {
	mut host := [winapi.MAX_COMPUTERNAME_LENGTH + 1]u16{}
	mut size := (winapi.MAX_COMPUTERNAME_LENGTH + 1) as u32
	winapi.throw(winapi.GetComputerNameW(&mut host[0], &mut size) != 0, 'Cannot get the computer name')!
	return string.from_wide(&host[0])
}
