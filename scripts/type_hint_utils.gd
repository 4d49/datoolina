# Copyright (c) 2024-2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.


# FIXME
static func hint_string_to_range(hint_string: String) -> Array:
#	return DB.hint_string_to_range(hint_string)
	return []


# FIXME
static func hint_string_to_enum(hint_string: String) -> Dictionary[StringName, int]:
#	return DB.hint_string_to_enum(hint_string)
	return {}


static func table_view_hint(hint: int, hint_string: String) -> Dictionary:
#	# FIXME: Требуется исправление
#	match hint:
#		DB.Hint.RANGE:
#			return TableView.hint_range.callv(hint_string_to_range(hint_string))
#
#		DB.Hint.ENUM:
#			return TableView.hint_enum(hint_string_to_enum(hint_string))
#
#		DB.Hint.COLOR_NO_ALPHA:
#			return TableView.hint_color_no_alpha()

	return TableView.hint_none()
