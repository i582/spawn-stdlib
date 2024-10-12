module json

#[cflags("$SPAWN_ROOT/thirdparty/cjson/cJSON.c")]
#[include_path("$SPAWN_ROOT/thirdparty/cjson")]
#[include("<cJSON.h>")]

extern {
	struct cJSON {
		next        *mut cJSON
		prev        *mut cJSON
		child       *mut cJSON
		type_       i32
		valuestring *u8
		valueint    i32
		valuedouble f64
		string      *u8
	}

	struct cJSON_Hooks {
		malloc_fn fn (_ usize) -> *void
		free_fn   fn (_ *void)
	}

	type cJSON_bool = i32

	fn cJSON_Version() -> *u8
	fn cJSON_InitHooks(hooks *cJSON_Hooks)
	fn cJSON_Parse(value *u8) -> *mut cJSON
	fn cJSON_ParseWithOpts(value *u8, return_parse_end **u8, require_null_terminated cJSON_bool) -> *mut cJSON
	fn cJSON_Print(item *mut cJSON) -> *u8
	fn cJSON_PrintUnformatted(item *mut cJSON) -> *u8
	fn cJSON_PrintBuffered(item *mut cJSON, prebuffer i32, fmt cJSON_bool) -> *u8
	fn cJSON_PrintPreallocated(item *mut cJSON, buffer *u8, length i32, format cJSON_bool) -> cJSON_bool
	fn cJSON_Delete(c *mut cJSON)
	fn cJSON_GetArraySize(array *mut cJSON) -> i32
	fn cJSON_GetArrayItem(array *mut cJSON, index i32) -> *mut cJSON
	fn cJSON_GetObjectItem(object *mut cJSON, str *u8) -> *mut cJSON
	fn cJSON_GetObjectItemCaseSensitive(object *mut cJSON, str *u8) -> *mut cJSON
	fn cJSON_HasObjectItem(object *mut cJSON, str *u8) -> cJSON_bool
	fn cJSON_GetErrorPtr() -> *u8
	fn cJSON_GetErrorPos() -> usize
	fn cJSON_GetStringValue(item *mut cJSON) -> *u8
	fn cJSON_GetNumberValue(item *mut cJSON) -> f64
	fn cJSON_IsInvalid(item *mut cJSON) -> cJSON_bool
	fn cJSON_IsFalse(item *mut cJSON) -> cJSON_bool
	fn cJSON_IsTrue(item *mut cJSON) -> cJSON_bool
	fn cJSON_IsBool(item *mut cJSON) -> cJSON_bool
	fn cJSON_IsNull(item *mut cJSON) -> cJSON_bool
	fn cJSON_IsNumber(item *mut cJSON) -> cJSON_bool
	fn cJSON_IsString(item *mut cJSON) -> cJSON_bool
	fn cJSON_IsArray(item *mut cJSON) -> cJSON_bool
	fn cJSON_IsObject(item *mut cJSON) -> cJSON_bool
	fn cJSON_IsRaw(item *mut cJSON) -> cJSON_bool
	fn cJSON_CreateNull() -> *mut cJSON
	fn cJSON_CreateTrue() -> *mut cJSON
	fn cJSON_CreateFalse() -> *mut cJSON
	fn cJSON_CreateBool(boolean cJSON_bool) -> *mut cJSON
	fn cJSON_CreateNumber(num f64) -> *mut cJSON
	fn cJSON_CreateString(str *u8) -> *mut cJSON
	fn cJSON_CreateRaw(raw *u8) -> *mut cJSON
	fn cJSON_CreateArray() -> *mut cJSON
	fn cJSON_CreateObject() -> *mut cJSON
	fn cJSON_CreateStringReference(str *u8) -> *mut cJSON
	fn cJSON_CreateObjectReference(child *mut cJSON) -> *mut cJSON
	fn cJSON_CreateArrayReference(child *mut cJSON) -> *mut cJSON
	fn cJSON_CreateIntArray(numbers *i32, count i32) -> *mut cJSON
	fn cJSON_CreateFloatArray(numbers *f32, count i32) -> *mut cJSON
	fn cJSON_CreateDoubleArray(numbers *f64, count i32) -> *mut cJSON
	fn cJSON_CreateStringArray(strings **u8, count i32) -> *mut cJSON
	fn cJSON_AddItemToArray(array *mut cJSON, item *mut cJSON)
	fn cJSON_AddItemToObject(object *mut cJSON, str *u8, item *mut cJSON)
	fn cJSON_AddItemToObjectCS(object *mut cJSON, str *u8, item *mut cJSON)
	fn cJSON_AddItemReferenceToArray(array *mut cJSON, item *mut cJSON)
	fn cJSON_AddItemReferenceToObject(object *mut cJSON, str *u8, item *mut cJSON)
	fn cJSON_DetachItemViaPointer(parent *mut cJSON, item *mut cJSON) -> *mut cJSON
	fn cJSON_DetachItemFromArray(array *mut cJSON, which i32) -> *mut cJSON
	fn cJSON_DeleteItemFromArray(array *mut cJSON, which i32)
	fn cJSON_DetachItemFromObject(object *mut cJSON, str *u8) -> *mut cJSON
	fn cJSON_DetachItemFromObjectCaseSensitive(object *mut cJSON, str *u8) -> *mut cJSON
	fn cJSON_DeleteItemFromObject(object *mut cJSON, str *u8)
	fn cJSON_DeleteItemFromObjectCaseSensitive(object *mut cJSON, str *u8)
	fn cJSON_InsertItemInArray(array *mut cJSON, which i32, newitem *mut cJSON)
	fn cJSON_ReplaceItemViaPointer(parent *i32, item *mut cJSON, replacement *mut cJSON) -> cJSON_bool
	fn cJSON_ReplaceItemInArray(array *mut cJSON, which i32, newitem *mut cJSON)
	fn cJSON_ReplaceItemInObject(object *mut cJSON, str *u8, newitem *mut cJSON)
	fn cJSON_ReplaceItemInObjectCaseSensitive(object *mut cJSON, str *u8, newitem *mut cJSON)
	fn cJSON_Duplicate(item *mut cJSON, recurse cJSON_bool) -> *mut cJSON
	fn cJSON_Compare(a *i32, b *i32, case_sensitive cJSON_bool) -> cJSON_bool
	fn cJSON_Minify(json *u8)
	fn cJSON_AddNullToObject(object *mut cJSON, name *u8) -> *mut cJSON
	fn cJSON_AddTrueToObject(object *mut cJSON, name *u8) -> *mut cJSON
	fn cJSON_AddFalseToObject(object *mut cJSON, name *u8) -> *mut cJSON
	fn cJSON_AddBoolToObject(object *mut cJSON, name *u8, boolean cJSON_bool) -> *mut cJSON
	fn cJSON_AddNumberToObject(object *mut cJSON, name *u8, number f64) -> *mut cJSON
	fn cJSON_AddStringToObject(object *mut cJSON, name *u8, str *u8) -> *mut cJSON
	fn cJSON_AddRawToObject(object *mut cJSON, name *u8, raw *u8) -> *mut cJSON
	fn cJSON_AddObjectToObject(object *mut cJSON, name *u8) -> *mut cJSON
	fn cJSON_AddArrayToObject(object *mut cJSON, name *u8) -> *mut cJSON
	fn cJSON_SetNumberHelper(object *mut cJSON, number f64) -> f64
	fn cJSON_malloc(size usize) -> *void
	fn cJSON_free(object *void)
}
