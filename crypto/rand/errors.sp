module rand

pub struct ReadError {
	msg string
}

pub fn (r ReadError) msg() -> string {
	if r.msg.len > 0 {
		return 'crypto.rand.read(): error reading random bytes: ${r.msg}'
	}
	return 'crypto.rand.read(): error reading random bytes'
}
