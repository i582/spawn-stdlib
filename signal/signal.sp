module signal

import sys.libc

pub type SignalHandler = fn (_ Signal)

// signal registers a handler for the given signal and returns the previous handler.
//
// The handler is called with the signal number as its argument.
//
// Example:
// ```
// signal.signal(.SIGINT, fn (s signal.Signal) {
//     println('Received SIGINT')
//     os.exit(1)
// })
// ```
// Sets the handler for the SIGINT signal. When the user presses Ctrl-C, the handler
// is called and the program exits.
pub fn signal(sig Signal, handler SignalHandler) -> SignalHandler {
	return libc.signal(sig as i32, handler as libc.sighandler_t) as SignalHandler
}
