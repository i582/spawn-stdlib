module log

import strings
import time

pub struct JsonFormatter {}

fn (_ &mut JsonFormatter) format(entry &LogEntry) -> ![]u8 {
	mut sb := strings.new_builder(150)
	sb.write_str('{')

	sb.write_str('"time": "')
	sb.write_str(entry.time.format_rfc3339())
	sb.write_str('", ')

	sb.write_str('"level": "')
	sb.write_str(entry.level.str())
	sb.write_str('", ')

	sb.write_str('"message": "')
	sb.write_str(entry.message)
	sb.write_str('"')

	fields := entry.fields
	if fields.len != 0 {
		sb.write_str(", ")
		sb.write_str('"fields": {')

		mut index := 0
		for key, field in fields {
			sb.write_str('"')
			sb.write_str(key)
			sb.write_str('": ')

			match field {
				i32 => format_int_to_sb(&mut sb, field)
				i64 => format_int_to_sb(&mut sb, field)
				f64 => sb.write_str(field.str())
				bool => {
					if field {
						sb.write_str("true")
					} else {
						sb.write_str("false")
					}
				}
				string => {
					sb.write_u8(b`"`)
					sb.write_str(field)
					sb.write_u8(b`"`)
				}
				time.Duration => {
					sb.write_u8(b`"`)
					sb.write_str(field.str())
					sb.write_u8(b`"`)
				}
			}

			if index < fields.len - 1 {
				sb.write_str(", ")
			}
			index++
		}
		sb.write_str('}')
	}

	sb.write_str('}')
	sb.write_str('\n')

	return sb
}
