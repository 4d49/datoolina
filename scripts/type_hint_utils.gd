# Copyright (c) 2024-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.


const DB: GDScript = preload("res://scripts/database.gd")


static func hint_string_to_range(hint_string: String) -> Array:
	return DB.hint_string_to_range(hint_string)


static func hint_string_to_enum(hint_string: String) -> Dictionary[StringName, int]:
	return DB.hint_string_to_enum(hint_string)


static func table_view_hint(hint: DB.Hint, hint_string: String) -> Dictionary:
	match hint:
		DB.Hint.RANGE:
			return TableView.hint_range.callv(hint_string_to_range(hint_string))

		DB.Hint.ENUM:
			return TableView.hint_enum(hint_string_to_enum(hint_string))

		DB.Hint.COLOR_NO_ALPHA:
			return TableView.hint_color_no_alpha()

	return TableView.hint_none()
