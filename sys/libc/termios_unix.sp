module libc

// open(), O_EVTONLY, O_NONBLOCK
#[include('<fcntl.h>')]
#[include("<termios.h>")]
#[include("<sys/ioctl.h>")]

pub const CC_LEN = 20

extern {
	pub const (
		TCSANOW   = 0
		TCSADRAIN = 0
		TCSAFLUSH = 0
		TCSASOFT  = 0
	)

	pub const (
		ECHO     = 0
		ICANON   = 0
		IEXTEN   = 0
		ISIG     = 0
		NOFLSH   = 0
		TOSTOP   = 0
		VDISCARD = 0
		VEOF     = 0
		VEOL     = 0
		VEOL2    = 0
		VERASE   = 0
		VINTR    = 0
		IGNBRK   = 0
		BRKINT   = 0
		PARMRK   = 0
		IXON     = 0
		ICRNL    = 0
		OPOST    = 0
	)

	pub const (
		VTIME = 0
		VMIN  = 0
	)

	#[typedef]
	pub struct termios {
		c_iflag  usize
		c_oflag  usize
		c_cflag  usize
		c_lflag  usize
		c_cc     [CC_LEN]u8
		c_ispeed usize
		c_ospeed usize
	}

	pub fn tcgetattr(fd i32, termios_p *mut termios) -> i32
	pub fn tcsetattr(fd i32, optional_actions i32, termios_p *termios) -> i32
	pub fn ioctl(fd i32, request u64, arg *mut void) -> i32

	pub const (
		O_EVTONLY = 0x00008000
	)

	pub fn open(path *u8, flags i32) -> i32

	pub const (
		TIOCGWINSZ = 0
	)

	#[typedef]
	pub struct winsize {
		ws_row u16
		ws_col u16
	}
}
