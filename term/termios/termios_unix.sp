module termios

import sys.libc

pub struct Termios {
	inner libc.termios
}

pub fn Termios.for_fd(fd i32) -> Termios {
	mut termios := libc.termios{}
	libc.tcgetattr(fd, &mut termios)
	return Termios{ inner: termios }
}

pub fn (t &Termios) apply_to(fd i32, optional_actions i32) -> i32 {
	return libc.tcsetattr(fd, optional_actions, &t.inner)
}

pub fn (t &mut Termios) disable_echo() {
	t.inner.c_lflag &= invert(libc.ECHO)
}

pub fn (t &mut Termios) enable_echo() {
	t.inner.c_lflag |= libc.ECHO
}

pub fn Termios.terminal_size() -> (u16, u16) {
	mut winsz := libc.winsize{}
	libc.ioctl(0, libc.TIOCGWINSZ, &mut winsz as *void)
	return winsz.ws_row, winsz.ws_col
}
