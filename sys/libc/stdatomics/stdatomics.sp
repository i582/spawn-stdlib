module stdatomics

#[include("<stdatomic.h>")]

extern {
	pub const (
		memory_order_relaxed = 0
		memory_order_consume = 0
		memory_order_acquire = 0
		memory_order_release = 0
		memory_order_acq_rel = 0
		memory_order_seq_cst = 0
	)

	pub fn atomic_store[T](object *mut T, desired T)
	pub fn atomic_store_explicit[T](object *mut T, desired T, order i32)

	pub fn atomic_load[T](object *T) -> T
	pub fn atomic_load_explicit[T](object *T, order i32) -> T

	pub fn atomic_exchange[T](object *mut T, desired T) -> T
	pub fn atomic_exchange_explicit[T](object *mut T, desired T, order i32) -> T

	pub fn atomic_compare_exchange_strong[T](object *mut T, expected *mut T, desired T) -> bool
	pub fn atomic_compare_exchange_strong_explicit[T](object *mut T, expected *mut T, desired *mut T, success_order i32, failure_order i32) -> bool

	pub fn atomic_compare_exchange_weak[T](object *mut T, expected *mut T, desired T) -> bool
	pub fn atomic_compare_exchange_weak_explicit[T](object *mut T, expected *mut T, desired T, success_order i32, failure_order i32) -> bool

	pub fn atomic_fetch_add[T](object *mut T, operand T) -> T
	pub fn atomic_fetch_add_explicit[T](object *mut T, operand T, order i32) -> T

	pub fn atomic_fetch_sub[T](object *mut T, operand T) -> T
	pub fn atomic_fetch_sub_explicit[T](object *mut T, operand T, order i32) -> T

	pub fn atomic_fetch_or[T](object *mut T, operand T) -> T
	pub fn atomic_fetch_or_explicit[T](object *mut T, operand T, order i32) -> T

	pub fn atomic_fetch_xor[T](object *mut T, operand T) -> T
	pub fn atomic_fetch_xor_explicit[T](object *mut T, operand T, order i32) -> T

	pub fn atomic_fetch_and[T](object *mut T, operand T) -> T
	pub fn atomic_fetch_and_explicit[T](object *mut T, operand T, order i32) -> T
}
