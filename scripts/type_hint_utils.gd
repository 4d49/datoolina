# Copyright (c) 2024-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.


const DictionaryDB: GDScript = preload("res://scripts/dictionary_database.gd")


static func hint_string_to_range(hint_string: String) -> Array:
	return DictionaryDB.hint_string_to_range(hint_string)


static func hint_string_to_enum(hint_string: String) -> Dictionary[StringName, int]:
	return DictionaryDB.hint_string_to_enum(hint_string)


static func table_view_hint(hint: DictionaryDB.Hint, hint_string: String) -> Dictionary:
	match hint:
		DictionaryDB.Hint.RANGE:
			return TableView.hint_range.callv(hint_string_to_range(hint_string))

		DictionaryDB.Hint.ENUM:
			return TableView.hint_enum(hint_string_to_enum(hint_string))

		DictionaryDB.Hint.COLOR_NO_ALPHA:
			return TableView.hint_color_no_alpha()

	return TableView.hint_none()
