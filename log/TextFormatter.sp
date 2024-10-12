module log

import strings
import term
import time

pub struct TextFormatter {
	is_terminal bool
	initialized bool

	buf strings.Builder = strings.new_builder(100)
}

fn (t &mut TextFormatter) init(entry &LogEntry) {
	t.is_terminal = check_if_terminal(entry.logger.out)
}

fn (t &mut TextFormatter) format(entry &LogEntry) -> ![]u8 {
	t.buf.clear()

	if !t.initialized {
		t.init(entry)
		t.initialized = true
	}

	if !t.should_colorize(entry) {
		// fast path without allocations
		entry.time.format_rfc3339_to(&mut t.buf)
	} else {
		t.buf.write_str(t.colorize(entry, entry.time.format_rfc3339(), term.gray))
	}

	t.buf.write_u8(b` `)
	t.format_level(entry)
	t.buf.write_u8(b` `)
	t.format_message(entry)
	t.format_fields(entry)
	t.buf.write_str('\n')

	return t.buf.as_array()
}

fn (t &mut TextFormatter) format_level(entry &LogEntry) {
	level := entry.level
	level_label := level.label()

	if !t.should_colorize(entry) {
		// fast path without extra allocations
		t.buf.write_u8(b`[`)
		t.buf.write_str(level_label)
		t.buf.write_u8(b`]`)
	} else {
		colored := t.colorize(entry, '[${level_label}]', t.level_color(level))
		t.buf.write_str(colored)
	}

	if level in [.info, .warn] {
		t.buf.write_u8(b` `)
	}
}

fn (t &mut TextFormatter) format_message(entry &LogEntry) {
	t.buf.write_str(entry.message)

	if entry.fields.len == 0 {
		// no extra padding needed
		return
	}

	if entry.message.len < 35 {
		for _ in 0 .. 35 - entry.message.len {
			t.buf.write_u8(b` `)
		}
	}
}

fn (t &mut TextFormatter) format_fields(entry &LogEntry) {
	fields := entry.fields
	if fields.len == 0 {
		return
	}

	level_color := t.level_color(entry.level)
	t.buf.write_u8(b` `)

	mut index := 0
	for key, field in fields {
		t.buf.write_str(t.colorize(entry, key, level_color))
		t.buf.write_u8(b`=`)

		match field {
			i32 => format_int_to_sb(&mut t.buf, field)
			i64 => format_int_to_sb(&mut t.buf, field)
			f64 => t.buf.write_str(field.str())
			bool => {
				if field {
					t.buf.write_str("true")
				} else {
					t.buf.write_str("false")
				}
			}
			string => t.buf.write_str(field)
			time.Duration => t.buf.write_str(field.str())
		}

		if index <= fields.len - 1 {
			t.buf.write_u8(b` `)
		}
		index++
	}
}

fn (t &TextFormatter) colorize(entry &LogEntry, msg string, fun fn (msg string) -> string) -> string {
	if !t.should_colorize(entry) {
		return msg
	}

	return fun(msg)
}

fn (t &TextFormatter) should_colorize(entry &LogEntry) -> bool {
	return entry.logger.color_mode != .never && t.is_terminal
}

fn (_ &TextFormatter) level_color(level LogLevel) -> fn (msg string) -> string {
	return match level {
		.panic => term.red
		.fatal => term.red
		.error => term.red
		.warn => term.yellow
		.info => term.gray
		.debug => term.gray
		.trace => term.gray
	}
}

fn format_int_to_sb(sb &mut strings.Builder, mut val i64) {
	if val < 0 {
		sb.write_u8(b`-`)
		val = -val
	}

	mut digits := 0
	mut tmp := val
	for tmp > 0 {
		tmp /= 10
		digits++
	}

	tmp = val
	for digits > 0 {
		mut pow := 1
		for _ in 0 .. digits - 1 {
			pow *= 10
		}

		digit := tmp / pow
		sb.write_u8(b`0` + digit as u8)
		tmp %= pow
		digits--
	}
}
