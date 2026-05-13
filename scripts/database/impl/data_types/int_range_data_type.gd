# Copyright (c) 2024-2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends AbstractRangeDataType


# 32-bit signed integer limits
const MIN_VALUE: int = -0x80000000
const MAX_VALUE: int =  0x7FFFFFFF


var _min_value: int = MIN_VALUE
var _max_value: int = MAX_VALUE


func set_min(min: Variant) -> void:
	_min_value = min

func get_min() -> int:
	return _min_value


func set_max(max: Variant) -> void:
	_max_value = max

func get_max() -> int:
	return _max_value


func validate(value: Variant) -> bool:
	if value is int or value is float:
		return value >= get_min() and value <= get_max()

	return false


func get_default() -> int:
	return 0


func get_built_in_type() -> Variant.Type:
	return TYPE_INT


func get_type_name() -> StringName:
	return &"int_range"
