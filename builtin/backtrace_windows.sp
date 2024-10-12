module builtin

import mem
import sync.atomic

#[include("<windows.h>")]
#[include("<DbgHelp.h>")]
#[library("dbghelp")]

extern {
	const (
		SYMOPT_UNDNAME        = 0
		SYMOPT_DEFERRED_LOADS = 0
		SYMOPT_LOAD_LINES     = 0
	)

	struct SYMBOL_INFO {
		SizeOfStruct u32
		Address      u64
		MaxNameLen   u32
		Name         *u8
	}

	fn SymSetOptions(SymOptions u32) -> u32
	fn SymInitialize(hProcess *void, UserSearchPath *u8, fInvadeProcess bool) -> bool
	pub fn GetLastError() -> u32
	fn GetCurrentProcess() -> *void
	fn SymFromAddr(hProcess *void, Address u64, Displacement *u64, Symbol *SYMBOL_INFO) -> bool
	fn CaptureStackBackTrace(FramesToSkip u32, FramesToCapture u32, BackTrace *mut void, BackTraceHash *u32) -> u32
}

// initialized is flag that indicates whether the backtrace module has been initialized.
// Used only for Windows.
var initialized = atomic.Bool.from(false)

// print_backtrace prints the basic backtrace to stderr.
//
// See also `backtrace` module for more advanced stack traces.
pub fn print_backtrace() {
	trace := get_backtrace()
	for i in 0 .. trace.len {
		frame := trace[i]
		eprint(i.str().pad_end(3, b` `))
		eprint(' ')
		eprintln(frame)
	}
}

// get_backtrace returns the basic backtrace as an array of strings.
//
// See also `backtrace` module for more advanced stack traces.
pub fn get_backtrace() -> []string {
	if !initialized.load(.seq_cst) {
		SymSetOptions(SYMOPT_UNDNAME | SYMOPT_DEFERRED_LOADS | SYMOPT_LOAD_LINES)
		if !SymInitialize(GetCurrentProcess(), nil, true) {
			panic("SymInitialize failed: ${GetLastError()}")
		}
		initialized.store(true, .seq_cst)
	}

	mut buffer := [100]*void{}
	mut backtrace := []string{}
	frames := CaptureStackBackTrace(0, 100, &mut buffer[0], nil)
	proc := GetCurrentProcess()

	symbol_info_size := mem.size_of[SYMBOL_INFO]() as u32
	symbol := mem.calloc(symbol_info_size + 256, 1) as &mut SYMBOL_INFO
	symbol.SizeOfStruct = symbol_info_size
	symbol.MaxNameLen = 255

	for i in 0 .. frames {
		if SymFromAddr(proc, unsafe { buffer[i] as u64 }, nil, symbol) {
			backtrace.push(symbol.Address.hex_prefixed() + ' ' + string.from_c_str(symbol.Name))
		}
	}

	return backtrace
}
