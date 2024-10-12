module libc

#[include('pwd.h')]
#[include('grp.h')]

extern {
	#[typedef]
	pub struct passwd {
		pw_name   *u8 // user name
		pw_passwd *u8 // encrypted password
		pw_uid    u32 // user uid
		pw_gid    u32 // user gid
		pw_change i32 // password change time
		pw_class  *u8 // user access class
		pw_gecos  *u8 // Honeywell login info
		pw_dir    *u8 // home directory
		pw_shell  *u8 // default shell
		pw_expire i32 // account expiration
	}

	pub fn getpwuid(uid u32) -> *passwd

	#[typedef]
	pub struct group {
		gr_name   *u8  // group name
		gr_passwd *u8  // group password
		gr_gid    u32  // group gid
		gr_mem    **u8 // group members
	}

	pub fn getgrgid(gid u32) -> *group
}
