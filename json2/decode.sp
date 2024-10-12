module json2

import mem
import reflection
import json2.syntax
import strings

#[skip_inline]
fn to_heap[T](mut val T) -> &T {
	return mem.to_heap_mut(&mut val)
}

fn rename_field(name string, rename_to string) -> string {
	if rename_to == "" {
		return name
	}
	if rename_to == "camelCase" {
		return to_camel_case(name)
	}
	return name
}

fn to_camel_case(name string) -> string {
	mut res := strings.new_builder(name.len + 1)
	mut capitalize := false
	for c in name {
		if c == b`_` {
			capitalize = true
		} else {
			if capitalize {
				res.write_u8(c.to_upper())
				capitalize = false
			} else {
				res.write_u8(c)
			}
		}
	}
	return res.str_view()
}

fn decode_struct[T: reflection.Struct](data syntax.Object) -> T {
	mut res := T{}

	mut rename_to := ''
	comptime if attr := type_info[T]().attr("rename_all") {
		rename_to = attr.value(0)
	}

	comptime for field in T.fields {
		comptime if field.has_attr("skip") {
			// fast path, we don't need to process this field
			comptime continue
		}

		mut json_name := rename_field(field.name, rename_to)
		comptime if attr := field.attr("json") {
			json_name = attr.value(0)
		}

		comptime if field.typ is string {
			if field.has_attr("raw") {
				// TODO
				res.$(field.name) = decode_raw_string_field(data, json_name)
			} else {
				res.$(field.name) = data.string_field(json_name) or { '' }
			}

			// don't process struct in `if field.typ is reflection.Struct {}`
			comptime continue
		}

		comptime if field.typ is reflection.Struct {
			res.$(field.name) = decode_struct_type_field[field.typ](data, json_name)
		}

		comptime if field.typ is bool {
			res.$(field.name) = data.bool_field(json_name) or { false }
		}

		comptime if field.typ is i32 {
			res.$(field.name) = data.i32_field(json_name) or { 0 }
		}

		comptime if field.typ is u64 {
			res.$(field.name) = data.u64_field(json_name) or { 0 }
		}

		comptime if field.typ.is_ref() {
			json_field := data.field(json_name) or {
				// TODO: Just give a default value of a type and create ref to it?
				panic("is none")
			}

			comptime type TElem = field.typ.elem()
			res.$(field.name) = to_heap[TElem](decode_value[TElem](json_field))
		}

		comptime if field.typ.is_enum() {
			res.$(field.name) = data.i32_field(json_name) or { 0 }
		}

		comptime if field.typ.is_option() {
			comptime type TElem = field.typ.elem()
			res.$(field.name) = decode_option_field[TElem](data, json_name)
		}

		comptime if field.typ.is_map() {
			comptime type TKey = field.typ.key()
			comptime type TValue = field.typ.value()
			res.$(field.name) = decode_map_field[TKey, TValue](data, json_name)
		}

		comptime if field.typ.is_array() {
			comptime type TElem = field.typ.elem()
			res.$(field.name) = decode_array_field[TElem](data, json_name)
		}

		// TODO: implement handing of structure's fields of union type
		//
		// comptime if field.typ.is_union() {
		//     json_field := data.field(json_name)
		//
		//     comptime for typ in field.typ.union_types() {
		//         comptime if typ.is_array() {
		//             if json_field.is_array() {
		//                 res.$(field.name) = decode_array[typ.elem()](json_field)
		//             }
		//         }
		//     }
		// }
	}

	return res
}

fn decode_struct_type_field[T: reflection.Struct](data syntax.Object, field_name string) -> T {
	json_field := data.field(field_name) or { return T{} }
	return decode_struct[T](json_field as syntax.Object)
}

fn decode_option_field[T](data syntax.Object, field_name string) -> ?T {
	json_field := data.field(field_name) or { return none }
	if json_field is syntax.Null {
		return none
	}

	return decode_value[T](json_field)
}

fn decode_map_field[K, V](data syntax.Object, field_name string) -> map[K]V {
	json_field := data.field(field_name) or { return map[K]V{} }
	return decode_map[K, V](json_field)
}

fn decode_array_field[T](data syntax.Object, field_name string) -> []T {
	json_field := data.field(field_name) or { return []T{} }
	return decode_array[T](json_field)
}

fn decode_raw_string_field(data syntax.Object, field_name string) -> string {
	json_field := data.field(field_name) or { return '' }
	return json_field as string
}

fn decode_array[T](data syntax.Value) -> []T {
	if data !is syntax.JsonArray {
		return []
	}

	mut res := []T{}

	mut cur := data.head
	for cur != none {
		res.push(decode_value[T](cur.val))
		cur = cur.next
	}

	return res
}

fn decode_map[K, V](data syntax.Value) -> map[string]V {
	if data !is syntax.Object {
		return {}
	}

	mut res := map[string]V{}

	mut cur := data.head
	for cur != none {
		key := cur.key
		value := decode_value[V](cur.value)
		res[key] = value
		cur = cur.next
	}

	return res
}

fn decode_value[T](data syntax.Value) -> T {
	comptime if T is string {
		return data as string
	}

	comptime if T is i32 {
		return (data as syntax.Number).value.i32()
	}

	comptime if T is reflection.Struct {
		comptime if T !is string {
			return decode_struct[T](data as syntax.Object)
		}
	}

	comptime if T is reflection.Enum {
		return (data as syntax.Number).value.i32()
	}

	comptime if T is reflection.ArrayTy {
		comptime type TElem = type_info[T]().elem()
		return decode_array[TElem](data)
	}

	comptime if T is reflection.Ref {
		comptime type TElem = type_info[T]().elem()
		return decode_ref[TElem](data)
	}

	panic("unsupported type for decode_value ${T}")
}

fn decode_ref[T](data syntax.Value) -> &T {
	mut val := decode_value[T](data)
	return mem.to_heap_mut(&mut val)
}
