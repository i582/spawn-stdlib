module dl

// On Windows there is no such constant, so we define it to 0.
pub const (
	RTLD_LAZY     = 0
	RTLD_NOW      = 0
	RTLD_GLOBAL   = 0
	RTLD_LOCAL    = 0
	RTLD_NODELETE = 0
	RTLD_NOLOAD   = 0
)

pub type Handle = *mut void
