module os

import sys.winapi
import mem
import strings

// exec executes a command and returns the output and exit code.
// The command is executed in a shell, so you can use shell syntax.
//
// If execution of command fails, `exec` returns an error with last
// WinAPI error message and code.
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
	child_stdin := nil as winapi.HANDLE
	mut child_stdout_read := nil as winapi.HANDLE
	mut child_stdout_write := nil as winapi.HANDLE

	mut sa := winapi.SECURITY_ATTRIBUTES{}
	sa.nLength = mem.size_of[winapi.SECURITY_ATTRIBUTES]() as u32
	sa.bInheritHandle = true

	mut cmd_wide := [32768]u16{}
	mut pcmd := cmd
	if pcmd.contains('./') {
		// windows shell doesn't like forward slashes
		pcmd = pcmd.replace('./', '.\\')
	}
	pcmd = 'cmd /C "${cmd} 2>&1"'

	winapi.throw(winapi.CreatePipe(&mut child_stdout_read, &mut child_stdout_write, &sa, 0), "exec failed, CreatePipe error")!
	winapi.throw(winapi.SetHandleInformation(child_stdout_read, winapi.HANDLE_FLAG_INHERIT, 0), "exec failed, SetHandleInformation error")!
	winapi.throw(winapi.ExpandEnvironmentStringsW(pcmd.to_wide(), &mut cmd_wide[0], 32768) != 0, "exec failed, ExpandEnvironmentStringsW error")!

	proc_info := winapi.PROCESS_INFORMATION{}
	start_info := winapi.STARTUPINFOA{
		cb: mem.size_of[winapi.STARTUPINFOA]() as u32
		hStdInput: child_stdin
		hStdOutput: child_stdout_write
		hStdError: child_stdout_write
		dwFlags: winapi.STARTF_USESTDHANDLES
	}
	winapi.throw(winapi.CreateProcessW(nil, &cmd_wide[0], nil, nil, true, 0, nil, nil, &start_info, &proc_info), "exec failed, CreateProcessW error")!

	winapi.CloseHandle(child_stdin)
	winapi.CloseHandle(child_stdout_write)

	mut data := strings.new_builder(1024)

	mut buf := [4096]u8{}
	mut bytes_read := 0 as u32
	for {
		read := winapi.ReadFile(child_stdout_read, &mut buf[0], 1000, &mut bytes_read, nil)
		if !read || bytes_read == 0 {
			break
		}

		data.push_fixed(buf, bytes_read)
	}

	mut exit_code := 0 as u32
	winapi.throw(winapi.WaitForSingleObject(proc_info.hProcess, winapi.INFINITE) == winapi.WAIT_FAILED, "exec failed, WaitForSingleObject error")!
	winapi.throw(winapi.GetExitCodeProcess(proc_info.hProcess, &mut exit_code), "exec failed, GetExitCodeProcess error")!

	winapi.CloseHandle(proc_info.hProcess)
	winapi.CloseHandle(proc_info.hThread)

	return Res{
		output: data.str_view().trim_suffix('\r\n')
		exit_code: exit_code
	}
}

// exec_inplace replaces the current process with the specified [`program`]
// called with given [`args`].
//
// Overall this means the current program is stopped, and the new program
// takes over its execution. Unlike Unix `exec` functions, `CreateProcess`
// on Windows starts a new process but does not directly replace the current
// process. Instead, it waits for the new process to complete before exiting.
//
// If the program cannot be executed, the function throws an error.
//
// Example:
// ```
// os.exec_inplace(r"C:\path\to\your\program.exe", "arg1", "arg2") or {
//     eprintln("Failed to execute command: ${err}")
//     return
// }
// // If the command is executed successfully, this line will not be reached
// println("This line will never be printed.")
// ```
pub fn exec_inplace(program string, args ...string) -> ! {
	mut pi := winapi.PROCESS_INFORMATION{}
	mut si := winapi.STARTUPINFOA{
		cb: mem.size_of[winapi.STARTUPINFOA]() as u32
	}

	is_batch_file := program.ends_with('.bat') || program.ends_with('.cmd')
	program_utf16, command_line_utf16 := if is_batch_file {
		command_prompt()!, make_bat_command_line(program, args)!
	} else {
		program.to_wide() as *u16, make_command_line(program, args)!
	}

	flags := winapi.CREATE_UNICODE_ENVIRONMENT
	if !winapi.CreateProcess(program_utf16, command_line_utf16, nil, nil, false, flags, nil, nil, &si, &pi) {
		winapi.throw(false, "Cannot execute '${program}'")!
	}

	winapi.WaitForSingleObject(pi.hProcess, winapi.INFINITE)

	winapi.CloseHandle(pi.hProcess)
	winapi.CloseHandle(pi.hThread)

	exit(0)
}

fn make_bat_command_line(program string, args []string) -> !&u16 {
	mut cmd := strings.new_builder(20)
	cmd.write_str("cmd.exe /e:ON /v:OFF /d /c \"")

	cmd.write_str(program)

	for arg in args {
		cmd.write_str(' ')
		cmd.write_str(arg)
	}

	cmd.write_u8(b`"`)
	cmd.push(0)

	return cmd.str_view().to_wide()
}

fn make_command_line(program string, args []string) -> !&u16 {
	mut cmd := strings.new_builder(20)

	// Always quote the program name to ensure correct parsing of arguments by CreateProcess.
	// Note that quotes are not escaped here because they are not valid in the first argument.
	// However, this is acceptable since file paths generally do not contain quotes.
	cmd.write_u8(b`"`)
	cmd.write_str(program)
	cmd.write_u8(b`"`)

	for arg in args {
		cmd.write_str(' ')
		cmd.write_str(arg)
	}

	cmd.push(0)

	return cmd.str_view().to_wide()
}

// command_prompt returns `cmd.exe` for use with bat scripts, encoded as a UTF-16 string.
fn command_prompt() -> !*u16 {
	mut sys := system_directory()!
	cmd_path := r'\cmd.exe'
	sys.push_ptr(cmd_path.to_wide(), cmd_path.len)
	sys.push(0)
	return sys.raw()
}

fn system_directory() -> ![]u16 {
	mut buf := [512]u16{}
	actual_len := winapi.GetSystemDirectoryW(&mut buf[0], 512)
	if actual_len > 512 {
		panic('system directory path is too long')
	}
	winapi.throw(actual_len != 0, 'GetSystemDirectoryW failed')!
	return buf[..actual_len].copy()
}
