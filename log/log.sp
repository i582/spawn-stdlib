module log

import time
import io

pub fn log(level LogLevel, msg string) {
	logger.log(level, msg)
}

pub fn log_one(level LogLevel, msg string) {
	logger.log(level, msg)
}

pub fn warn(msg string) {
	logger.log(.warn, msg)
}

pub fn info(msg string) {
	logger.log(.info, msg)
}

pub fn trace(msg string) {
	logger.log(.trace, msg)
}

pub fn error_(msg string) {
	logger.log(.error, msg)
}

pub fn set_formatter(f Formatter) {
	logger.set_formatter(f)
}

pub fn set_level(level LogLevel) {
	logger.set_level(level)
}

pub fn set_flush_rate(dur time.Duration) {
	logger.flush_rate = dur
}

pub fn set_output(out io.Writer) {
	logger.set_output(out)
}

pub fn get_output() -> io.Writer {
	return logger.get_output()
}

pub fn with_fields(fields Fields) -> LogEntry {
	return logger.with_fields(fields)
}

pub fn with_duration(dur time.Duration) -> LogEntry {
	return logger.with_duration(dur)
}

pub fn use_color_mode(mode ColorMode) {
	logger.use_color_mode(mode)
}
