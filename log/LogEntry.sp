module log

import time
import fs

pub union Value = i32 |
                  i64 |
                  f64 |
                  bool |
                  string |
                  time.Duration

pub type Fields = map[string]Value

pub struct LogEntry {
	logger  &mut Logger
	fields  Fields
	time    time.Time
	level   LogLevel
	message string
}

pub fn LogEntry.new(logger &mut Logger) -> LogEntry {
	return LogEntry{ logger: logger }
}

// clone_with_same_fields returns a new LogEntry with the same values.
//
// NOTE: fields map is not cloned, but shared between the original and the new LogEntry.
// This way we can avoid unnecessary allocations.
pub fn (entry &LogEntry) clone_with_same_fields() -> LogEntry {
	return LogEntry{
		logger: entry.logger
		fields: entry.fields
		time: entry.time
		level: entry.level
		message: entry.message
	}
}

pub fn (entry &LogEntry) with_fields(fields Fields) -> LogEntry {
	return LogEntry{
		logger: entry.logger
		fields: fields
		time: entry.time
		level: entry.level
		message: entry.message
	}
}

pub fn (entry &LogEntry) with_duration(dur time.Duration) -> LogEntry {
	return entry.with_fields({
		'duration': dur as Value
	})
}

pub fn (entry &LogEntry) error(msg string) {
	entry.log(.error, msg)
}

pub fn (entry &LogEntry) warn(msg string) {
	entry.log(.warn, msg)
}

pub fn (entry &LogEntry) info(msg string) {
	entry.log(.info, msg)
}

pub fn (entry &LogEntry) trace(msg string) {
	entry.log(.trace, msg)
}

pub fn (entry &LogEntry) log(level LogLevel, msg string) {
	if !entry.logger.is_level_enabled(level) {
		return
	}
	entry.log_impl(level, msg)
}

pub fn (entry &LogEntry) log_one(level LogLevel, msg string) {
	entry.log(level, msg)
}

pub fn (entry &LogEntry) log_impl(level LogLevel, msg string) {
	mut new_entry := entry.clone_with_same_fields()
	new_entry.time = time.utc()
	new_entry.level = level
	new_entry.message = msg

	new_entry.write()

	if level == LogLevel.panic {
		formatted := entry.logger.formatter.format(&new_entry) or {
			panic('failed to format log message: ${err.msg()}')
		}
		panic(formatted.ascii_str())
	}
}

fn (entry &mut LogEntry) write() {
	formatted := entry.logger.formatter.format(entry) or {
		eprintln('failed to format log message: ${err}')
		return
	}

	entry.logger.out.write(formatted) or {
		eprintln('failed to write log message: ${err}')
		return
	}

	if entry.logger.last_flush.elapsed() > entry.logger.flush_rate {
		mut out := entry.logger.out
		if out is fs.File {
			out.flush() or {}
		}

		entry.logger.last_flush = time.system_now()
	}
}
