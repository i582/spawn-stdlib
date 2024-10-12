module runtime

import sys.libc

// num_cpu returns the number of logical CPUs usable by the current process.
pub fn num_cpu() -> i32 {
	return libc.sysconf(libc.SC_NPROCESSORS_ONLN) as i32
}

// page_size returns the size of a virtual memory page in bytes.
pub fn page_size() -> usize {
	return libc.sysconf(libc.SC_PAGESIZE) as usize
}
