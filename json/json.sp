module json

import mem
import sys.libc
import reflection
import strings

pub fn decode[T](data string) -> ![T, ParseError] {
	res := raw_parse(data)
	if res == nil {
		err := cJSON_GetErrorPtr()
		if err != nil {
			pos := cJSON_GetErrorPos()
			return error(ParseError.from(string.view_from_c_str(err), pos, data))
		}
		return error(ParseError{
			line: 0
			msg: "unknown parse error"
		})
	}

	return decode_value[T](res)
}

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

fn decode_struct[T: reflection.Struct](data Handle) -> T {
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
				res.$(field.name) = decode_raw_string_field(data, json_name)
			} else {
				res.$(field.name) = data.string_field(json_name) or { '' }
			}
		}

		comptime if field.typ is bool {
			res.$(field.name) = data.bool_object_field(json_name) or { false }
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
				panic(err.msg())
			}

			comptime type TElem = field.typ.elem()
			res.$(field.name) = to_heap[TElem](decode_value[TElem](json_field))
		}

		comptime if field.typ is reflection.Struct && field.typ !is string {
			res.$(field.name) = decode_struct_type_field[field.typ](data, json_name)
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

fn decode_struct_type_field[T: reflection.Struct](data Handle, field_name string) -> T {
	json_field := data.field(field_name) or { return T{} }
	return decode_struct[T](json_field)
}

fn decode_option_field[T](data Handle, field_name string) -> ?T {
	json_field := data.field(field_name) or { return none }
	if json_field.is_null() {
		return none
	}

	return decode_value[T](json_field)
}

fn decode_map_field[K, V](data Handle, field_name string) -> map[K]V {
	json_field := data.field(field_name) or { return map[K]V{} }
	return decode_map[K, V](json_field)
}

fn decode_array_field[T](data Handle, field_name string) -> []T {
	json_field := data.field(field_name) or { return []T{} }
	return decode_array[T](json_field)
}

fn decode_raw_string_field(data Handle, field_name string) -> string {
	json_field := data.field(field_name) or { return '' }
	return json_field.to_string(true)
}

fn decode_array[T](data Handle) -> []T {
	mut res := []T{}
	arr := data.array()

	for el in arr {
		res.push(decode_value[T](el))
	}

	return res
}

fn decode_map[K, V](data Handle) -> map[string]V {
	mut res := map[string]V{}
	if data == nil {
		return res
	}

	obj := data

	mut el := obj.child as Handle
	for el != nil {
		key := string.view_from_c_str(el.string)
		val := obj.field(key) or { continue }
		res[key] = decode_value[V](val)

		el = el.next
	}

	return res
}

fn decode_value[T](data Handle) -> T {
	comptime if T is string {
		return data.as_string()
	}

	comptime if T is i32 {
		return data.i32()
	}

	comptime if T is reflection.Struct {
		comptime if T !is string {
			return decode_struct[T](data)
		}
	}

	comptime if T is reflection.Enum {
		return data.i32()
	}

	comptime if T is reflection.ArrayTy {
		comptime type TElem = type_info[T]().elem()
		return decode_array[TElem](data)
	}

	comptime if T is reflection.Ref {
		comptime type TElem = type_info[T]().elem()
		return decode_ref[TElem](data)
	}

	comptime if T is Handle {
		return data
	}

	panic("unsupported type for decode_value ${T}")
}

fn decode_ref[T](data Handle) -> &T {
	mut val := decode_value[T](data)
	return mem.to_heap_mut(&mut val)
}

pub fn encode[T](data T) -> string {
	h := encode_value[T](data)
	return string.view_from_c_str(cJSON_PrintBuffered(h, 100, 0))
}

pub fn encode_as_bytes[T](data T) -> []u8 {
	h := encode_value[T](data)
	res := cJSON_PrintBuffered(h, 100, 0)
	len := libc.strlen(res)
	return unsafe { Array.from_ptr_no_copy[u8](res, len) }
}

fn encode_struct[T: reflection.Struct](data T) -> Handle {
	b := cJSON_CreateObject()

	mut rename_to := ''
	comptime if attr := type_info[T]().attr("rename_all") {
		rename_to = attr.args[0].remove_surrounding('"', '"')
	}

	comptime for field in T.fields {
		mut json_name := rename_field(field.name, rename_to)
		comptime if attr := field.attr("json") {
			json_name = attr.args[0].remove_surrounding('"', '"')
		}

		omit_empty := field.has_attr("omit_empty")

		comptime if field.typ is string {
			encode_string_to(b, omit_empty, json_name, data.$(field.name))
		}
		comptime if field.typ is bool {
			cJSON_AddBoolToObject(b, json_name.c_str(), data.$(field.name))
		}
		comptime if field.typ is f64 {
			cJSON_AddNumberToObject(b, json_name.c_str(), data.$(field.name))
		}
		comptime if field.typ is i32 {
			cJSON_AddNumberToObject(b, json_name.c_str(), data.$(field.name))
		}
		comptime if field.typ is u64 {
			cJSON_AddNumberToObject(b, json_name.c_str(), data.$(field.name))
		}
		comptime if field.typ is reflection.Struct && field.typ !is string {
			inner := encode_struct[field.typ](data.$(field.name))
			cJSON_AddItemToObject(b, json_name.c_str(), inner)
		}
		comptime if field.typ.is_ref() {
			inner := encode_ref[field.typ.elem()](data.$(field.name))
			cJSON_AddItemToObject(b, json_name.c_str(), inner)
		}
		comptime if field.typ.is_enum() {
			cJSON_AddNumberToObject(b, json_name.c_str(), data.$(field.name))
		}
		comptime if field.typ.is_option() {
			data_val := data.$(field.name)
			res := encode_option[field.typ.elem()](data_val)
			if !res[1] || !omit_empty {
				cJSON_AddItemToObject(b, json_name.c_str(), res[0])
			}
		}
		comptime if field.typ.is_array() {
			res := encode_array[field.typ.elem()](data.$(field.name))
			if !res[1] || !omit_empty {
				cJSON_AddItemToObject(b, json_name.c_str(), res[0])
			}
		} $else comptime if field.typ.is_map() {
			res := encode_map[field.typ.key(), field.typ.value()](data.$(field.name))
			if !res[1] || !omit_empty {
				cJSON_AddItemToObject(b, json_name.c_str(), res[0])
			}
		}
		// comptime if field.typ.is_union() {
		//     for typ in field.typ.union_types() {
		//         if data.$(field.name) is typ {
		//             cJSON_AddItemToObject(b, json_name, encode_value[typ](data.$(field.name)))
		//         }
		//     }
		// }
	}

	return b
}

fn encode_string_to(h Handle, omit_empty bool, key string, val string) {
	if val == "" && omit_empty {
		return
	}
	cJSON_AddStringToObject(h, key.c_str(), val.c_str())
}

fn encode_option[T](data ?T) -> (Handle, bool) {
	if data != none {
		return encode_value[T](data), false
	}

	return cJSON_CreateNull(), true
}

fn encode_array[T](data []T) -> (Handle, bool) {
	arr := cJSON_CreateArray()
	for el in data {
		el_obj := encode_value[T](el)
		cJSON_AddItemToArray(arr, el_obj)
	}
	return arr, data.len == 0
}

fn encode_map[K, V](data map[string]V) -> (Handle, bool) {
	obj := cJSON_CreateObject()
	for key, val in data {
		cJSON_AddItemToObject(obj, key.c_str(), encode_value[V](val))
	}
	return obj, data.len == 0
}

fn encode_value[T](data T) -> Handle {
	comptime if T is string {
		return encode_string(data as string)
	}

	comptime if T is bool {
		return cJSON_CreateBool(data as i32)
	}

	comptime if T is i8 {
		return cJSON_CreateNumber(data as f64)
	}

	comptime if T is i16 {
		return cJSON_CreateNumber(data as f64)
	}

	comptime if T is i32 {
		return cJSON_CreateNumber(data as f64)
	}

	comptime if T is i64 {
		return cJSON_CreateNumber(data as f64)
	}

	comptime if T is i128 {
		return cJSON_CreateNumber(data as f64)
	}

	comptime if T is u8 {
		return cJSON_CreateNumber(data as f64)
	}

	comptime if T is u16 {
		return cJSON_CreateNumber(data as f64)
	}

	comptime if T is u32 {
		return cJSON_CreateNumber(data as f64)
	}

	comptime if T is u64 {
		return cJSON_CreateNumber(data as f64)
	}

	comptime if T is u128 {
		return cJSON_CreateNumber(data as f64)
	}

	comptime if T is f32 {
		return cJSON_CreateNumber(data as f64)
	}

	comptime if T is f64 {
		return cJSON_CreateNumber(data as f64)
	}

	comptime if T is reflection.ArrayTy {
		res := encode_array[reflection.type_info[T]().elem()](data as reflection.ArrayTy)
		return res[0]
	}

	comptime if T is reflection.MapTy {
		res := encode_map[reflection.type_info[T]().key(), reflection.type_info[T]().value()](data as reflection.MapTy)
		return res[0]
	}

	comptime if T is reflection.Struct {
		return encode_struct[T](data)
	}

	comptime if T is reflection.Enum {
		return cJSON_CreateNumber(data as f64)
	}

	comptime if data is reflection.Ref {
		return encode_ref[reflection.type_info[T]().elem()](data)
	}

	// comptime if data is reflection.Instantiation {
	//     return encode_value[reflection.type_info[T]().elem()](data)
	// }

	panic("unsupported type ${T}")
}

fn encode_string(data string) -> Handle {
	return cJSON_CreateString(data.c_str())
}

fn encode_ref[T](data &T) -> Handle {
	return encode_value[T](*data)
}
