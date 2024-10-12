module intrinsics

#[include('<math.h>')]

// size_of returns the size of a type in bytes.
#[C('sizeof')]
pub fn size_of[T]() -> usize

// align_of returns the alignment of a type in bytes.
#[C('ALIGN_OF')]
pub fn align_of[T]() -> usize

// offset_of returns the offset of the field in the type T in bytes.
#[C('offset_of')]
pub fn offset_of[T](field string) -> usize

// likely is a hint to the compiler that the passed expression is **likely to be true**,
// so it can generate assembly code, with less chance of
// [branch misprediction](https://en.wikipedia.org/wiki/Branch_predictor).
//
// Example:
// ```
// if intrinsics.likely(x > 0) {
//   // this branch is likely to be taken
// }
// ```
//
// Compilers can use the information that a certain branch is not likely to be
// taken to optimize for the common case in the absence of better information
// (ie. compiling GCC with `-fprofile-arcs`).
//
// Recommendation: Modern CPUs dynamically predict branch execution paths,
// typically with accuracy greater than 97%. As a result, annotating every
// branch in a codebase is likely counterproductive; however, annotating
// specific branches that are both hot and consistently mispredicted is likely
// to yield performance improvements.
#[C('spawn_likely')]
pub fn likely(x bool) -> bool {
	return x
}

// unlikely is a hint to the compiler that the passed expression is **highly improbable**.
// See also [branch predictor](https://en.wikipedia.org/wiki/Branch_predictor).
//
// Example:
// ```
// if intrinsics.unlikely(x < 0) {
//   // this branch is unlikely to be taken
// }
// ```
#[C('spawn_unlikely')]
pub fn unlikely(x bool) -> bool {
	return x
}

// abort causes abnormal program termination unless SIGABRT is being caught and the signal
// handler does not return. If the program is terminated with SIGABRT, the program is said to
// be "aborted".
#[C('abort')]
pub fn abort() -> never

// memory_alloc allocates a block of memory of `size` bytes.
// Use `mem.alloc()` instead as stable version.
#[C('malloc')]
pub fn memory_alloc(size usize) -> *mut u8

// memory_calloc allocates a block of memory for an array of `count` elements,
// each of them `size` bytes long, and initializes all its bits to zero.
// Use `mem.calloc()` instead as stable version.
#[C('calloc')]
pub fn memory_calloc(count usize, size usize) -> *mut u8

// memory_realloc changes the size of the memory block pointed to by `ptr` to `size` bytes.
// Use `mem.realloc()` instead as stable version.
#[C('realloc')]
pub fn memory_realloc(ptr *void, size usize) -> *mut u8

// memory_set sets the first `n` bytes of the memory area pointed to by `s` to the specified value `c`.
// Use `mem.set()` instead as stable version.
#[C('memset')]
pub fn memory_set(s *mut void, c i32, n usize) -> *void

// memory_compare compares the first `n` bytes of the memory areas `s1` and `s2`.
// Use `mem.compare()` instead as stable version.
#[C('memcmp')]
pub fn memory_compare(s1 *void, s2 *void, n usize) -> i32

// memory_copy copies `size` bytes from memory area `src` to memory area `dest`.
// The memory areas must not overlap.
// Use `mem.fast_copy()` instead as stable version.
#[C('memcpy')]
pub fn memory_copy(dest *mut u8, src *u8, size usize) -> *mut u8

// memory_move copies `size` bytes from memory area `src` to memory area `dest`.
// The memory areas may overlap.
// Use `mem.copy()` instead as stable version.
#[C('memmove')]
pub fn memory_move(dest *mut u8, src *u8, size usize) -> *mut u8

// memory_free frees the memory space pointed to by `ptr`,
// which must have been returned by a previous call to `memory_alloc`, `memory_calloc` or `memory_realloc`.
// Otherwise, or if `memory_free(ptr)` has already been called before, undefined behavior occurs.
// If `ptr` is `null`, no operation is performed.
// Use `mem.c_free()` instead as stable version.
#[C('free')]
pub fn memory_free(ptr *void)

// stack_alloc allocates a block of memory of `size` bytes on the stack.
// Use `mem.stack_alloc()` instead as stable version.
#[C('alloca')]
pub fn stack_alloc(size usize) -> &mut u8

// string_copy copies the string pointed to by `src` to `dest`.
#[C('strcpy')]
pub fn string_copy(dest *u8, src *u8) -> *u8

// string_len returns the length of the string pointed to by `s`.
#[C('strlen')]
pub fn string_len(s *u8) -> usize

// sqrtf32 returns the square root of `f32` value.
// Use `f32.sqrt()` instead as stable version.
#[C('sqrtf')]
pub fn sqrtf32(x f32) -> f32

// sqrtf64 returns the square root of `f64` value.
// Use `f64.sqrt()` instead as stable version.
#[C('sqrt')]
pub fn sqrtf64(x f64) -> f64

// logf32 returns the natural logarithm of `f32` value.
// Use `f32.ln()` instead as stable version.
#[C('logf')]
pub fn logf32(x f32) -> f32

// logf64 returns the natural logarithm of `f64` value.
// Use `f64.ln()` instead as stable version.
#[C('log')]
pub fn logf64(x f64) -> f64

// log2f32 returns the base 2 logarithm of `f32` value.
// Use `f32.log2()` instead as stable version.
#[C('log2f')]
pub fn log2f32(x f32) -> f32

// log2f64 returns the base 2 logarithm of `f64` value.
// Use `f64.log2()` instead as stable version.
#[C('log2')]
pub fn log2f64(x f64) -> f64

// log10f32 returns the base 10 logarithm of `f32` value.
// Use `f32.log10()` instead as stable version.
#[C('log10f')]
pub fn log10f32(x f32) -> f32

// log10f64 returns the base 10 logarithm of `f64` value.
// Use `f64.log10()` instead as stable version.
#[C('log10')]
pub fn log10f64(x f64) -> f64

// powf32 returns `x` to the power of `y`.
// Use `f32.powf(y)` instead as stable version.
#[C('powf')]
pub fn powf32(x f32, y f32) -> f32

// powf64 returns `x` to the power of `y`.
// Use `f64.powf(y)` instead as stable version.
#[C('pow')]
pub fn powf64(x f64, y f64) -> f64

// ceilf32 returns the smallest integer value greater than or equal to `x`.
// Use `f32.ceil()` instead as stable version.
#[C('ceilf')]
pub fn ceilf32(x f32) -> f32

// ceilf64 returns the smallest integer value greater than or equal to `x`.
// Use `f64.ceil()` instead as stable version.
#[C('ceil')]
pub fn ceilf64(x f64) -> f64

// floorf32 returns the largest integer value less than or equal to `x`.
// Use `f32.floor()` instead as stable version.
#[C('floorf')]
pub fn floorf32(x f32) -> f32

// floorf64 returns the largest integer value less than or equal to `x`.
// Use `f64.floor()` instead as stable version.
#[C('floor')]
pub fn floorf64(x f64) -> f64

// roundf32 returns the nearest integer value to `x`.
// Use `f32.round()` instead as stable version.
#[C('roundf')]
pub fn roundf32(x f32) -> f32

// roundf64 returns the nearest integer value to `x`.
// Use `f64.round()` instead as stable version.
#[C('round')]
pub fn roundf64(x f64) -> f64

// truncf32 returns the nearest integer value not greater in magnitude than `x`.
// Use `f32.trunc()` instead as stable version.
#[C('truncf')]
pub fn truncf32(x f32) -> f32

// truncf64 returns the nearest integer value not greater in magnitude than `x`.
// Use `f64.trunc()` instead as stable version.
#[C('trunc')]
pub fn truncf64(x f64) -> f64

// sinf32 returns the sine of `x` (expressed in radians).
// Use `f32.sin()` instead as stable version.
#[C('sinf')]
pub fn sinf32(x f32) -> f32

// sinf64 returns the sine of `x` (expressed in radians).
// Use `f64.sin()` instead as stable version.
#[C('sin')]
pub fn sinf64(x f64) -> f64

// cosf32 returns the cosine of `x` (expressed in radians).
// Use `f32.cos()` instead as stable version.
#[C('cosf')]
pub fn cosf32(x f32) -> f32

// cosf64 returns the cosine of `x` (expressed in radians).
// Use `f64.cos()` instead as stable version.
#[C('cos')]
pub fn cosf64(x f64) -> f64

// tanf32 returns the tangent of `x` (expressed in radians).
// Use `f32.tan()` instead as stable version.
#[C('tanf')]
pub fn tanf32(x f32) -> f32

// tanf64 returns the tangent of `x` (expressed in radians).
// Use `f64.tan()` instead as stable version.
#[C('tan')]
pub fn tanf64(x f64) -> f64

// asinf32 returns the arcsine of `x` (expressed in radians).
// Use `f32.asin()` instead as stable version.
#[C('asinf')]
pub fn asinf32(x f32) -> f32

// asinf64 returns the arcsine of `x` (expressed in radians).
// Use `f64.asin()` instead as stable version.
#[C('asin')]
pub fn asinf64(x f64) -> f64

// acosf32 returns the arccosine of `x` (expressed in radians).
// Use `f32.acos()` instead as stable version.
#[C('acosf')]
pub fn acosf32(x f32) -> f32

// acosf64 returns the arccosine of `x` (expressed in radians).
// Use `f64.acos()` instead as stable version.
#[C('acos')]
pub fn acosf64(x f64) -> f64

// atanf32 returns the arctangent of `x` (expressed in radians).
// Use `f32.atan()` instead as stable version.
#[C('atanf')]
pub fn atanf32(x f32) -> f32

// atanf64 returns the arctangent of `x` (expressed in radians).
// Use `f64.atan()` instead as stable version.
#[C('atan')]
pub fn atanf64(x f64) -> f64

// expf32 returns the exponential of `x`.
// Use `f32.exp()` instead as stable version.
#[C('expf')]
pub fn expf32(x f32) -> f32

// expf64 returns the exponential of `x`.
// Use `f64.exp()` instead as stable version.
#[C('exp')]
pub fn expf64(x f64) -> f64

// exp2f32 returns 2 raised to the power of `x`.
// Use `f32.exp2()` instead as stable version.
#[C('exp2f')]
pub fn exp2f32(x f32) -> f32

// exp2f64 returns 2 raised to the power of `x`.
// Use `f64.exp2()` instead as stable version.
#[C('exp2')]
pub fn exp2f64(x f64) -> f64

#[C('fopen')]
pub fn file_open(filename *u8, mode *u8) -> *void

#[C('fclose')]
pub fn file_close(stream *void) -> i32

#[enable_if(!windows)]
#[C('fseek')]
pub fn file_seek(stream *void, offset i64, origin i32) -> i32

#[enable_if(windows)]
#[C('_fseeki64')]
pub fn file_seek(stream *void, offset i64, origin i32) -> i32

#[C('ftell')]
pub fn file_tell(stream *void) -> i64

#[C('rewind')]
pub fn file_rewind(stream *void)

#[C('fread')]
pub fn file_read(ptr *void, size usize, n_items usize, stream *void) -> usize

#[C('fwrite')]
pub fn file_write(ptr *void, size usize, n_items usize, stream *void) -> u32

#[C('feof')]
pub fn file_eof(stream *void) -> i32

#[C('ferror')]
pub fn file_error(stream *void) -> i32

#[C('qsort')]
pub fn quick_sort[T](base *mut T, num_items usize, size usize, compare fn (a &T, b &T) -> i32)
pub fn caller_location() -> Location

// compiler_error causes a compilation error with the given message.
//
// This intrinsic is useful only with `comptime if` conditions and can be used to
// stop the compilation when some condition is not met.
//
// Example:
// ```
// comptime if !linux {
//   intrinsics.compiler_error("This code is only for Linux")
// }
// ```
pub fn compiler_error(msg string) -> never

// compiler_warning causes a compilation warning with the given message.
//
// This intrinsic is useful only with `comptime if` conditions and can be used to
// show a warning when some condition is not met.
//
// Example:
// ```
// comptime if !linux {
//   intrinsics.compiler_warning("This code is unstable on non-Linux platforms")
// }
// ```
pub fn compiler_warning(msg string)
