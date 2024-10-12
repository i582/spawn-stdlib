module http

pub enum Version {
	unknown
	v1_1
	v2_0
	v1_0
}

pub fn (v Version) str() -> string {
	return match v {
		.v1_0 => 'HTTP/1.0'
		.v1_1 => 'HTTP/1.1'
		.v2_0 => 'HTTP/2.0'
		.unknown => 'unknown'
	}
}

pub fn Version.from_str(v string) -> Version {
	return match v.to_lower() {
		'http/1.0' => .v1_0
		'http/1.1' => .v1_1
		'http/2.0' => .v2_0
		else => .unknown
	}
}
