module log

pub interface Formatter {
	// format returns the formatted log entry.
	//
	// NOTE: The returned buffer should be immediately copied if it is to be used
	//       after the next log call.
	fn format(self, entry &LogEntry) -> ![]u8
}
