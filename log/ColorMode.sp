module log

pub enum ColorMode {
	auto
	always
	never
}

fn get_color_mode_by_name(name string) -> ?ColorMode {
	match name {
		'auto' => return .auto
		'always' => return .always
		'never' => return .never
	}
	return none
}
