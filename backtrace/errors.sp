module backtrace

// NoDebugInfoError represents an error when the binary does not
// contain debugging information, so the backtrace cannot be
// obtained using [`capture`].
pub struct NoDebugInfoError {}

// msg returns stub message of [`NoDebugInfoError`] error.
fn (n NoDebugInfoError) msg() -> string {
	return 'no debug info found'
}
