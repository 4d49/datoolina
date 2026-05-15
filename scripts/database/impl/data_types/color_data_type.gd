# Copyright (c) 2024-2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends AbstractDataType


func validate(value: Variant) -> bool:
	return value is Color


func get_default() -> Color:
	return Color.BLACK


func get_built_in_type() -> Variant.Type:
	return TYPE_COLOR


func get_type_hint() -> Hint:
	return Hint.NONE


func get_type_name() -> StringName:
	return &"color"
