# Copyright (c) 2024-2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends AbstractDataType


var _max_length: int = 0


func validate(value: Variant) -> bool:
	if value is String:
		if _max_length:
			return value.length() <= _max_length

		return true

	return false


func get_default() -> String:
	return ""


func get_built_in_type() -> Variant.Type:
	return TYPE_STRING


func get_type_name() -> StringName:
	return &"String"


func set_max_length(length: int) -> void:
	_max_length = maxi(length, 0)

func get_max_length() -> int:
	return _max_length
