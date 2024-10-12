module net

const MSG_NOSIGNAL = 0x4000

enum WsaError {
	some
}

fn (e WsaError) desc() -> string {
	return ""
}

pub fn wsa_error(_ i32) -> WsaError {
	return .some
}

pub fn wsa_last_error() -> WsaError {
	return .some
}
