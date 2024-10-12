module libc

extern {
	pub struct sstat {
		st_dev   u64
		st_ino   u64
		st_mode  u32
		st_nlink u64
		st_uid   u32
		st_gid   u32
		st_rdev  u64
		st_size  u64
		st_atime i32
		st_mtime i32
		st_ctime i32
	}

	pub const (
		S_IFMT   = 0 as u32
		S_IFIFO  = 0 as u32
		S_IFCHR  = 0 as u32
		S_IFDIR  = 0 as u32
		S_IFBLK  = 0 as u32
		S_IFREG  = 0 as u32
		S_IFLNK  = 0 as u32
		S_IFSOCK = 0 as u32
		S_IFWHT  = 0 as u32
	)

	pub const (
		S_IRWXU = 0 as u32
		S_IRUSR = 0 as u32
		S_IWUSR = 0 as u32
		S_IXUSR = 0 as u32
	)

	pub const (
		S_IRWXG = 0 as u32
		S_IRGRP = 0 as u32
		S_IWGRP = 0 as u32
		S_IXGRP = 0 as u32
	)

	pub const (
		S_IRWXO = 0 as u32
		S_IROTH = 0 as u32
		S_IWOTH = 0 as u32
		S_IXOTH = 0 as u32
		S_ISUID = 0 as u32
		S_ISGID = 0 as u32
		S_ISVTX = 0 as u32
	)

	pub fn isatty(fd i32) -> i32

	pub const (
		R_OK = 0
		W_OK = 0
		X_OK = 0
	)

	pub fn access(path *u8, amode i32) -> i32
	pub fn lstat(path *u8, buf *mut sstat) -> i32
	pub fn stat(path *u8, buf *mut sstat) -> i32
	pub fn readlink(path *u8, buf *u8, bufsiz u64) -> isize

	pub fn pipe(fds *mut i32) -> i32
	pub fn dup2(oldfd i32, newfd i32) -> i32
	pub fn fork() -> i32
	pub fn close(fd i32) -> i32
	pub fn fdopen(fd i32, mode *u8) -> *mut FILE
	pub fn fgets(s *u8, size i32, stream *mut FILE) -> *u8
	pub fn fclose(stream *mut FILE) -> i32
	pub fn waitpid(pid i32, status *mut i32, options i32) -> i32

	pub fn execlp(file *u8, arg0 *u8) -> i32
	pub fn execvp(path *u8, args **u8) -> i32

	pub fn chmod(path *u8, mode u32) -> i32

	pub fn getpid() -> i32

	pub fn WIFEXITED(status i32) -> i32
	pub fn WEXITSTATUS(status i32) -> i32
	pub fn WIFSIGNALED(status i32) -> i32
	pub fn WTERMSIG(status i32) -> i32
}
