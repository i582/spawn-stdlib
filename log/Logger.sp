module log

import time
import io
import fs

var logger = Logger{
	formatter: TextFormatter{}
	out: fs.stderr()
}

pub struct Logger {
	disabled   bool
	color_mode ColorMode

	formatter  Formatter
	out        io.Writer
	last_flush time.SystemTime
	flush_rate time.Duration   = 5 * time.SECOND

	level u64 = LogLevel.info as u64
}

pub fn (l &mut Logger) disable() {
	l.disabled = true
}

pub fn (l &mut Logger) enable() {
	l.disabled = false
}

pub fn (l &mut Logger) use_color_mode(mode ColorMode) {
	l.color_mode = mode
}

pub fn (l &mut Logger) use_color_mode_string(mode string) {
	enum_value := get_color_mode_by_name(mode) or { .auto }
	l.color_mode = enum_value
}

pub fn (l &Logger) level() -> u64 {
	return l.level
}

pub fn (l &mut Logger) set_level(level LogLevel) {
	l.level = level as u64
}

pub fn (l &mut Logger) set_flush_rate(dur time.Duration) {
	l.flush_rate = dur
}

pub fn (l &mut Logger) set_output(out io.Writer) {
	l.out = out
}

pub fn (l &mut Logger) get_output() -> io.Writer {
	return l.out
}

pub fn (l &Logger) is_level_enabled(level LogLevel) -> bool {
	return l.level() >= level as u64
}

pub fn (l &mut Logger) log(level LogLevel, msg string) {
	if !l.is_level_enabled(level) {
		return
	}

	entry := LogEntry.new(l)
	entry.log(level, msg)
}

pub fn (l &mut Logger) set_formatter(formatter Formatter) {
	l.formatter = formatter
}

pub fn (l &mut Logger) with_fields(fields Fields) -> LogEntry {
	entry := LogEntry.new(l)
	return entry.with_fields(fields)
}

pub fn (l &mut Logger) with_duration(dur time.Duration) -> LogEntry {
	entry := LogEntry.new(l)
	return entry.with_duration(dur)
}
