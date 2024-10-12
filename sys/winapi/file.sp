module winapi

#[include("<sys/stat.h>")]

extern {
	#[typedef]
	pub struct _stat64 {
		st_dev   i16
		st_ino   u16
		st_mode  u16
		st_nlink i16
		st_uid   i16
		st_gid   i16
		st_rdev  i16
		st_size  i64
		st_atime i64
		st_mtime i64
		st_ctime i64
	}

	pub const (
		S_IFMT  = 0
		S_IFDIR = 0
	)

	pub const (
		S_IRUSR = 0 as u32
		S_IWUSR = 0 as u32
		S_IXUSR = 0 as u32
	)

	pub const (
		S_IRGRP = 0 as u32
		S_IWGRP = 0 as u32
		S_IXGRP = 0 as u32
	)

	pub const (
		S_IROTH = 0 as u32
		S_IWOTH = 0 as u32
		S_IXOTH = 0 as u32
	)

	pub fn _wstat64(path *u16, buf *mut _stat64) -> i32
}
