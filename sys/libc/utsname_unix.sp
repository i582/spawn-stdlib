module libc

#[include("<sys/utsname.h>")]

extern {
	#[typedef]
	pub struct utsname {
		sysname  *u8
		nodename *u8
		release  *u8
		version  *u8
		machine  *u8
	}

	pub fn uname(name *mut utsname) -> i32
}
