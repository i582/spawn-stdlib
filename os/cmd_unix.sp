module os

import strings
import errno
import sys.libc
import fs

// exec executes a command and returns the output and exit code.
// If the command cannot be executed, function returns an error.
//
// Example:
// ```
// res := ccmd.exec("ls -l")
// if res.exit_code != 0 {
//   println("Command failed: ${res.cmd}")
// }
//
// println("Output: ${res.output}")
// ```
pub fn exec(cmd string) -> !Res {
	f := libc.popen(cmd.c_str(), c"r") as fs.CFile
	if f == nil {
		last_errno := errno.last()
		return msg_err("popen failed: ${last_errno}")
	}

	fd := libc.fileno(f)

	mut res := strings.new_builder(1024)

	mut buf := [4096]u8{}
	for {
		nread := libc.read(fd, buf.as_ptr(), 4096)
		if nread == 0 {
			break
		}
		if nread == -1 {
			IOError.throw(false, "read failed: ")!
		}

		res.push_fixed(buf, nread)
	}

	exit_code := libc.pclose(f)

	return Res{ cmd: cmd, exit_code: exit_code, output: res.str_view().trim_suffix('\n') }
}

// exec_inplace replaces the current process with the specified [`program`]
// called with given [`args`].
//
// Overall this means the current program is stopped, and the new program
// takes over its execution. The new program inherits the same process ID and
// handles but starts with a fresh execution context. This is same to how Unix `exec`
// functions work.
//
// If the program cannot be executed, the function returns an error.
//
// Example:
// ```
// os.exec_inplace("ls", "-l") or {
//     eprintln("Failed to execute command: ${err}")
//     return
// }
// // If the command is executed successfully, this line will not be reached
// println("This line will never be printed.")
// ```
pub fn exec_inplace(program string, args ...string) -> ! {
	mut cargs := []*u8{}

	// From documentation:
	//   The first argument, by convention, should point to the filename associated
	//   with the file being executed.
	cargs.push(program.c_str())

	// From documentation:
	//   The execv(), execvp(), and execvpe() functions provide an array
	//   of pointers to null-terminated strings that represent the argument
	//   list available to the new program
	for arg in args {
		cargs.push(arg.c_str())
	}

	// From documentation:
	//   The array of pointers must be terminated by a NULL pointer
	cargs.push(nil)

	res := libc.execvp(program.c_str(), cargs.raw())

	// We raach this point only if `execvp` is failed
	IOError.throw(res != -1, "cannot execute '${program}': ")!

	exit(res)
}
