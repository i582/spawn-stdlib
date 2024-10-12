module json

pub fn raw_parse(data string) -> Handle {
	return cJSON_Parse(data.data)
}

pub type Handle = *mut cJSON

pub fn (h Handle) is_array() -> bool {
	return cJSON_IsArray(h) != 0
}

pub fn (h Handle) is_string() -> bool {
	return cJSON_IsString(h) != 0
}

pub fn (h Handle) as_string() -> string {
	res := cJSON_GetStringValue(h)
	if res == nil {
		return ""
	}
	return string.from_c_str(res)
}

pub fn (h Handle) bool() -> bool {
	return cJSON_IsTrue(h) != 0
}

pub fn (h Handle) is_number() -> bool {
	return cJSON_IsNumber(h) != 0
}

pub fn (h Handle) i32() -> i32 {
	if !h.is_number() {
		return 0
	}

	return cJSON_GetNumberValue(h) as i32
}

pub fn (h Handle) u64() -> u64 {
	if !h.is_number() {
		return 0
	}

	return cJSON_GetNumberValue(h) as u64
}

pub fn (h Handle) array() -> []Handle {
	mut arr := []Handle{}
	size := cJSON_GetArraySize(h)
	for i in 0 .. size {
		arr.push(cJSON_GetArrayItem(h, i))
	}
	return arr
}

pub fn (h Handle) field(name string) -> !Handle {
	json_field_handle := cJSON_GetObjectItem(h, name.data)

	if json_field_handle == nil {
		return msg_err("Can't find field `${name}` in provided JSON object")
	}

	return json_field_handle
}

pub fn (h Handle) i32_field(name string) -> !i32 {
	return h.field(name)!.i32()
}

pub fn (h Handle) u64_field(name string) -> !u64 {
	return h.field(name)!.u64()
}

pub fn (h Handle) string_field(name string) -> !string {
	return h.field(name)!.as_string()
}

pub fn (h Handle) bool_value() -> bool {
	return cJSON_IsTrue(h) != 0
}

pub fn (h Handle) bool_object_field(name string) -> !bool {
	return h.field(name)!.bool_value()
}

pub fn (h Handle) to_string(compact bool) -> string {
	res := if !compact {
		cJSON_PrintBuffered(h, 100, 1)
	} else {
		cJSON_PrintBuffered(h, 100, 0)
	}
	return string.view_from_c_str(res)
}

pub fn (h Handle) is_null() -> bool {
	if h == nil {
		return true
	}
	return cJSON_IsNull(h) != 0
}

pub struct Null {}

pub struct Builder {
	parent ?&mut Builder
	root   Handle
}

pub fn Builder.new() -> &mut Builder {
	return &mut Builder{ root: cJSON_CreateObject() }
}

pub fn Builder.empty_array() -> &mut Builder {
	return &mut Builder{ root: cJSON_CreateArray() }
}

pub fn (b &mut Builder) field[T](name string, value T) -> &mut Builder {
	// comptime if value is string {
	//     cJSON_AddItemToObject(b.root, name.data, cJSON_CreateString(value.clone().c_str()))
	//     return b
	// }
	//
	// comptime if value is i32 {
	//     cJSON_AddItemToObject(b.root, name.data, cJSON_CreateNumber(value as f64))
	//     return b
	// }
	//
	// comptime if value is bool {
	//     cJSON_AddItemToObject(b.root, name.data, cJSON_CreateBool(value as i32))
	//     return b
	// }

	// comptime if value is Null {
	//     cJSON_AddItemToObject(b.root, name.data, cJSON_CreateNull())
	//     return b
	// }

	// comptime if value is &mut Builder {
	//     cJSON_AddItemToObject(b.root, name.data, value.root)
	//     return b
	// }

	type_name := T.str()
	panic('unsupported type: ${type_name}')
}

pub fn (b &mut Builder) object2(name string, cb fn (b2 &mut Builder)) -> &mut Builder {
	obj := cJSON_CreateObject()
	cJSON_AddItemToObject(b.root, name.data, obj)
	new_builder := &mut Builder{ parent: b, root: obj }
	cb(new_builder)
	return b
}

pub fn (b &mut Builder) object(name string, cb fn (b2 &mut Builder) -> &mut Builder) -> &mut Builder {
	obj := cJSON_CreateObject()
	cJSON_AddItemToObject(b.root, name.data, obj)
	new_builder := &mut Builder{ parent: b, root: obj }
	cb(new_builder)
	return b
}

pub fn (b &mut Builder) array() -> &mut Builder {
	obj := cJSON_CreateArray()
	return &mut Builder{ parent: b, root: obj }
}

pub fn (b &mut Builder) array_field(name string) -> &mut Builder {
	obj := cJSON_CreateArray()
	new_builder := &mut Builder{ parent: b, root: obj }
	cJSON_AddItemToObject(b.root, name.data, obj)
	return new_builder
}

pub fn (b &mut Builder) element_builder2(element_builder &mut Builder) -> &mut Builder {
	cJSON_AddItemToArray(b.root, element_builder.root)
	return b
}

pub fn (b &mut Builder) element_builder(cb fn () -> &mut Builder) -> &mut Builder {
	new_builder := cb()
	cJSON_AddItemToArray(b.root, new_builder.root)
	return b
}

pub fn (b &mut Builder) element[T](value T) -> &mut Builder {
	comptime if value is string {
		cJSON_AddItemToArray(b.root, cJSON_CreateString(value.c_str()))
		return b
	}

	comptime if value is i32 {
		cJSON_AddItemToArray(b.root, cJSON_CreateNumber(value as f64))
		return b
	}

	comptime if value is bool {
		cJSON_AddItemToArray(b.root, cJSON_CreateBool(value as i32))
		return b
	}

	comptime if value is Null {
		cJSON_AddItemToArray(b.root, cJSON_CreateNull())
		return b
	}

	comptime if value is &mut Builder {
		cJSON_AddItemToArray(b.root, value.root)
		return b
	}

	type_name := T.str()
	panic('unsupported type: ${type_name}')
}

pub fn (b &mut Builder) build(compact bool) -> string {
	mut top_parent := b
	for top_parent.parent != none {
		top_parent = top_parent.parent
	}

	res := if !compact {
		cJSON_PrintBuffered(top_parent.root, 100, 1)
	} else {
		cJSON_PrintBuffered(top_parent.root, 100, 0)
	}
	return string.view_from_c_str(res)
}
