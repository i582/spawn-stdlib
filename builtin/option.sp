module builtin

pub struct Option[T] {
	data    T
	is_none bool
}

pub fn (o &mut Option[T]) set_data(data T) {
	o.data = data
	o.is_none = false
}

#[track_caller]
pub fn (o Option[T]) unwrap() -> T {
	if o.is_none {
		panic('called `Option.unwrap()` on a `none` value')
	}

	return o.data
}

pub fn (o Option[T]) unwrap_or(def T) -> T {
	if o.is_none {
		return def
	}

	return o.data
}

#[track_caller]
pub fn (o Option[T]) expect(msg string) -> T {
	if o.is_none {
		panic(msg)
	}

	return o.data
}

pub fn (o &mut Option[T]) insert(val T) -> &Option[T] {
	o.data = val
	o.is_none = false
	return o
}

pub fn (o Option[T]) map[U](f fn (el T) -> U) -> Option[U] {
	if o.is_none {
		return none
	}

	return f(o.data)
}

pub fn (o Option[T]) then[U](f fn (el T) -> U) -> ?U {
	if o.is_none {
		return none
	}

	return f(o.data)
}

pub fn (o Option[T]) then_maybe[U](f fn (el T) -> Option[U]) -> Option[U] {
	if o.is_none {
		return none
	}

	return f(o.data)
}

pub fn (o Option[T]) inspect(f fn (el T)) -> Option[T] {
	if o.is_none {
		return none
	}

	f(o.data)
	return o
}

pub fn (o Option[T]) clone() -> ?T
	where T: Clone
{
	if o.is_none {
		return none
	}
	return o.data.clone()
}

pub fn (o Option[T]) hash() -> u64
	where T: Hashable
{
	if o.is_none {
		return 0
	}
	return o.data.hash()
}

pub fn (o Option[T]) str() -> string
	where T: Display
{
	return o.inner_str(0)
}

pub fn (o Option[T]) inner_str(indent i32) -> string
	where T: Display
{
	if o.is_none {
		return 'none'
	}

	str := o.data.str()

	comptime if T is string {
		return 'Option("${str}")'
	}

	comptime if T is rune {
		return "Option(`${str}`)"
	}

	if str.count('\n') > 0 {
		mut result := []u8{cap: 10}
		indent_text_impl(&mut result, str, indent * 3, true)
		indented := string.view_from_bytes(result)
		return "Option(${indented})"
	}

	return "Option(${str})"
}

pub fn (o Option[T]) less(other Option[T]) -> bool
	where T: Ordered
{
	if o.is_none && other.is_none {
		return false
	}
	if o.is_none {
		return true
	}
	if other.is_none {
		return false
	}
	return o.data < other.data
}

pub fn (o Option[T]) equal(other Option[T]) -> bool
	where T: Equality
{
	if o.is_none && other.is_none {
		return true
	}
	if o.is_none || other.is_none {
		return false
	}
	return o.data == other.data
}

pub fn opt[T](data T) -> ?T {
	return Option[T]{
		data: data
		is_none: false
	}
}
