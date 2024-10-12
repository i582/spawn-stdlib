module runtime

import env
import sys.winapi

// num_cpu returns the number of logical CPUs usable by the current process.
pub fn num_cpu() -> i32 {
	mut sinfo := winapi.SYSTEM_INFO{}
	winapi.GetSystemInfo(&mut sinfo)
	nr := sinfo.dwNumberOfProcessors as i32
	if nr == 0 {
		return env.find('NUMBER_OF_PROCESSORS').i32()
	}
	return nr
}

// page_size returns the size of a virtual memory page in bytes.
pub fn page_size() -> usize {
	mut sinfo := winapi.SYSTEM_INFO{}
	winapi.GetSystemInfo(&mut sinfo)
	return sinfo.dwPageSize as usize
}
