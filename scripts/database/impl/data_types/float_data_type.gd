# Copyright (c) 2024-2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends AbstractDataType


var _default: float = 0.0


func validate(value: Variant) -> bool:
	return value is float or value is int


func set_default(value: Variant) -> void:
	if validate(value):
		_default = value

func get_default() -> float:
	return _default


func get_built_in_type() -> Variant.Type:
	return TYPE_FLOAT


func get_type_hint() -> Hint:
	return Hint.NONE


func get_type_name() -> StringName:
	return &"float"
