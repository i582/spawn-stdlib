module builtin

// Different platforms we can compile for.
pub comptime const (
	// windows sets to true if current platform is Windows.
	windows = false
	// linux sets to true if current platform is Linux.
	linux = false
	// macos sets to true if current platform is macOS.
	macos = false
	// darwin sets to true if current platform is Darwin, which is macOS or iOS.
	darwin = false
	// freebsd sets to true if current platform is FreeBSD.
	freebsd = false
	// openbsd sets to true if current platform is OpenBSD.
	openbsd = false
	// netbsd sets to true if current platform is NetBSD.
	netbsd = false
	// unix sets to true if current platform is Unix-like.
	unix = false
)

// Different architectures we can compile for.
pub comptime const (
	// amd64 sets to true if current architecture is amd64, which is x86-64.
	amd64 = false
	// arm64 sets to true if current architecture is arm64.
	arm64 = false
)

// Different build modes.
pub comptime const (
	// optimized sets to true if we are compiling with optimizations (`--opt` flag).
	optimized = false
	// debug sets to true if we are compiling with debug info (`-g` flag).
	debug = false

	// musl sets to true if we are compiling with musl libc.
	musl = false
)

pub comptime const (
	// panic_strategy is the strategy to use when a panic occurs.
	// - "abort": abort the program immediately.
	// - "unwind": unwind the stack until `main`, run deferred functions,
	//   print the panic message with stack trace, and exit.
	panic_strategy = "unwind"
)

// Different memory handling options.
pub comptime const (
	// use_prealloc sets to true if we compile with `--prealloc` flag.
	use_prealloc = false
	// with_gc sets to true by default, and can be disabled with `--gc none` flag.
	with_gc = true
)

// Other build options.
pub comptime const (
	// no_bounds_checking sets to true if we compile with `-d no_bounds_checking` flag.
	// In this mode, all bounds checks are removed and we get better performance.
	no_bounds_checking = false
)
