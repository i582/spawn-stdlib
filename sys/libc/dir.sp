module libc

#[include('<dirent.h>')]

extern {
	#[typedef]
	pub struct dirent {
		d_name *u8
	}

	pub struct DIR {}

	pub fn opendir(path *u8) -> *DIR
	pub fn closedir(dir *DIR) -> i32
	pub fn readdir(dir *DIR) -> *dirent

	pub fn mkdir(path *u8, mode u32) -> i32
	pub fn rmdir(path *u8) -> i32
	pub fn chdir(path *u8) -> i32
	pub fn getcwd(buf *u8, size usize) -> *u8
	pub fn symlink(from *u8, to *u8) -> i32
	pub fn link(from *u8, to *u8) -> i32
}
