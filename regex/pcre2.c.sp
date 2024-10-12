module regex

// Windows
#[library_if(windows, "pcre2-8-0")]
#[include_path(windows, "C:\\msys64\\mingw64\\include")]
#[library_path(windows, "C:\\msys64\\mingw64\\bin")]
#[include_if(windows, "pcre2.h")]

// thirdparty with prebuilt
#[include_if(darwin || linux, "$SPAWN_ROOT/thirdparty/pcre2/include/pcre2.h")]
#[library_path("$SPAWN_ROOT/thirdparty/pcre2/lib/")]
#[library_if(darwin && arm64, "pcre2-darwin-arm64")]
#[library_if(darwin && amd64, "pcre2-darwin-amd64")]
#[library_if(linux && amd64, "pcre2-linux-amd64")]

extern {
	const (
		PCRE2_ERROR_NOMATCH = 0
	)

	const (
		PCRE2_INFO_CAPTURECOUNT = 0
	)

	struct pcre2_code {}
	struct pcre2_general_context {}
	struct pcre2_compile_context {}
	struct pcre2_convert_context {}
	struct pcre2_match_context {}
	struct pcre2_match_data {}
	struct pcre2_real_general_context {}
	struct pcre2_real_compile_context {}
	struct pcre2_real_match_context {}
	struct pcre2_real_convert_context {}
	struct pcre2_real_code {}
	struct pcre2_real_match_data {}
	struct pcre2_real_jit_stack {}

	struct pcre2_callout_block {
		version               u32
		callout_number        u32
		capture_top           u32
		capture_last          u32
		offset_vector         *usize
		mark                  *u8
		subject               *u8
		subject_length        usize
		start_match           usize
		current_position      usize
		pattern_position      usize
		next_item_length      usize
		callout_string_offset usize
		callout_string_length usize
		callout_string        *u8
		callout_flags         u32
	}

	struct pcre2_callout_enumerate_block {
		version               u32
		pattern_position      usize
		next_item_length      usize
		callout_number        u32
		callout_string_offset usize
		callout_string_length usize
		callout_string        *u8
	}

	struct pcre2_substitute_callout_block {
		version        u32
		input          *u8
		output         *u8
		output_offsets [2]usize
		ovector        *usize
		oveccount      u32
		subscount      u32
	}

	fn pcre2_config(_ u32, _ *void) -> i32
	fn pcre2_general_context_copy(ctx *pcre2_general_context) -> *pcre2_general_context
	fn pcre2_general_context_create(_ fn (_ u32, _ *void) -> *void, _ fn (_ *void, _ *void), _ *void) -> *pcre2_general_context
	fn pcre2_general_context_free(ctx *pcre2_general_context)
	fn pcre2_compile_context_copy(ctx *pcre2_compile_context) -> *pcre2_compile_context
	fn pcre2_compile_context_create(ctx *pcre2_general_context) -> *pcre2_compile_context
	fn pcre2_compile_context_free(ctx *pcre2_compile_context)
	fn pcre2_set_bsr(ctx *pcre2_compile_context, _ u32) -> i32
	fn pcre2_set_character_tables(ctx *pcre2_compile_context, _ *u8) -> i32
	fn pcre2_set_compile_extra_options(ctx *pcre2_compile_context, _ u32) -> i32
	fn pcre2_set_max_pattern_length(ctx *pcre2_compile_context, _ usize) -> i32
	fn pcre2_set_newline(ctx *pcre2_compile_context, _ u32) -> i32
	fn pcre2_set_parens_nest_limit(ctx *pcre2_compile_context, _ u32) -> i32
	fn pcre2_set_compile_recursion_guard(ctx *pcre2_compile_context, _ fn () -> i32, _ *void) -> i32
	fn pcre2_convert_context_copy(ctx *pcre2_convert_context) -> *pcre2_convert_context
	fn pcre2_convert_context_create(ctx *pcre2_general_context) -> *pcre2_convert_context
	fn pcre2_convert_context_free(ctx *pcre2_convert_context)
	fn pcre2_set_glob_escape(ctx *pcre2_convert_context, _ u32) -> i32
	fn pcre2_set_glob_separator(ctx *pcre2_convert_context, _ u32) -> i32
	fn pcre2_pattern_convert(_ *u8, _ usize, _ u32, _ **u8, _ *usize, ctx *pcre2_convert_context) -> i32
	fn pcre2_converted_pattern_free(_ *u8)
	fn pcre2_match_context_copy(ctx *pcre2_match_context) -> *pcre2_match_context
	fn pcre2_match_context_create(ctx *pcre2_general_context) -> *pcre2_match_context
	fn pcre2_match_context_free(ctx *pcre2_match_context)
	fn pcre2_set_callout(ctx *pcre2_match_context, _ fn (_ *i32, _ *void) -> i32, _ *void) -> i32
	fn pcre2_set_substitute_callout(ctx *pcre2_match_context, _ fn (_ *i32, _ *void) -> i32, _ *void) -> i32
	fn pcre2_set_depth_limit(ctx *pcre2_match_context, _ u32) -> i32
	fn pcre2_set_heap_limit(ctx *pcre2_match_context, _ u32) -> i32
	fn pcre2_set_match_limit(ctx *pcre2_match_context, _ u32) -> i32
	fn pcre2_set_offset_limit(ctx *pcre2_match_context, _ usize) -> i32
	fn pcre2_set_recursion_limit(ctx *pcre2_match_context, _ u32) -> i32
	fn pcre2_set_recursion_memory_management(ctx *pcre2_match_context, _ fn (_ u32, _ *void) -> *void, _ fn (_ *void, _ *void), _ *void) -> i32
	fn pcre2_compile(pattern *u8, len usize, options u32, err_code *mut i32, err_offset *mut usize, ctx *pcre2_compile_context) -> *pcre2_code
	fn pcre2_code_free(pattern *pcre2_code)
	fn pcre2_code_copy(pattern *pcre2_code) -> *pcre2_code
	fn pcre2_code_copy_with_tables(pattern *pcre2_code) -> *pcre2_code
	fn pcre2_pattern_info(pattern *pcre2_code, len u32, _ *void) -> i32
	fn pcre2_callout_enumerate(pattern *pcre2_code, _ fn (_ *i32, _ *void) -> i32, _ *void) -> i32
	fn pcre2_match_data_create(_ u32, ctx *pcre2_general_context) -> *pcre2_match_data
	fn pcre2_match_data_create_from_pattern(pattern *pcre2_code, ctx *pcre2_general_context) -> *pcre2_match_data
	fn pcre2_dfa_match(pattern *pcre2_code, _ *u8, _ usize, _ usize, _ u32, data *pcre2_match_data, ctx *pcre2_match_context, _ *i32, _ usize) -> i32
	fn pcre2_match(pattern *pcre2_code, subject *u8, len usize, pos usize, opts u32, data *pcre2_match_data, ctx *pcre2_match_context) -> i32
	fn pcre2_match_data_free(data *pcre2_match_data)
	fn pcre2_get_mark(data *pcre2_match_data) -> *u8
	fn pcre2_get_match_data_size(data *pcre2_match_data) -> usize
	fn pcre2_get_ovector_count(data *pcre2_match_data) -> u32
	fn pcre2_get_ovector_pointer(data *pcre2_match_data) -> *usize
	fn pcre2_get_startchar(data *pcre2_match_data) -> usize
	fn pcre2_substring_copy_byname(data *pcre2_match_data, _ *u8, _ *u8, _ *usize) -> i32
	fn pcre2_substring_copy_bynumber(data *pcre2_match_data, _ u32, _ *u8, _ *usize) -> i32
	fn pcre2_substring_free(str *u8)
	fn pcre2_substring_get_byname(data *pcre2_match_data, _ *u8, _ **u8, _ *usize) -> i32
	fn pcre2_substring_get_bynumber(data *pcre2_match_data, _ u32, _ **u8, _ *usize) -> i32
	fn pcre2_substring_length_byname(data *pcre2_match_data, _ *u8, _ *usize) -> i32
	fn pcre2_substring_length_bynumber(data *pcre2_match_data, _ u32, _ *usize) -> i32
	fn pcre2_substring_nametable_scan(pattern *pcre2_code, _ *u8, _ **u8, _ **u8) -> i32
	fn pcre2_substring_number_from_name(pattern *pcre2_code, _ *u8) -> i32
	fn pcre2_substring_list_free(_ **u8)
	fn pcre2_substring_list_get(data *pcre2_match_data, _ ***u8, _ **usize) -> i32
	fn pcre2_serialize_encode(code **pcre2_code, _ i32, _ **u8, _ *usize, ctx *pcre2_general_context) -> i32
	fn pcre2_serialize_decode(code **pcre2_code, _ i32, _ *u8, ctx *pcre2_general_context) -> i32
	fn pcre2_serialize_get_number_of_codes(_ *u8) -> i32
	fn pcre2_serialize_free(_ *u8)
	fn pcre2_substitute(pattern *pcre2_code, _ *u8, _ usize, _ usize, _ u32, data *pcre2_match_data, ctx *pcre2_match_context, _ *u8, _ usize, _ *u8, _ *usize) -> i32

	fn pcre2_get_error_message(_ i32, _ *u8, _ usize) -> i32
	fn pcre2_maketables(ctx *pcre2_general_context) -> *u8
	fn pcre2_maketables_free(ctx *pcre2_general_context, _ *u8)
}

extern {
	struct pcre2_jit_stack {}

	type pcre2_jit_callback = fn (_ *void) -> *pcre2_real_jit_stack

	fn pcre2_jit_compile(pattern *pcre2_code, len u32) -> i32
	fn pcre2_jit_match(pattern *pcre2_code, _ *u8, _ usize, _ usize, _ u32, data *pcre2_match_data, ctx *pcre2_match_context) -> i32
	fn pcre2_jit_free_unused_memory(ctx *pcre2_general_context)
	fn pcre2_jit_stack_create(_ usize, _ usize, ctx *pcre2_general_context) -> *pcre2_jit_stack
	fn pcre2_jit_stack_assign(ctx *pcre2_match_context, _ pcre2_jit_callback, _ *void)
	fn pcre2_jit_stack_free(_ *pcre2_jit_stack)
}
