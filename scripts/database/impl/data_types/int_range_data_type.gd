# Copyright (c) 2024-2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends AbstractRangeDataType


# 32-bit signed integer limits
const MIN_VALUE: int = -0x80000000
const MAX_VALUE: int =  0x7FFFFFFF


var _default: int = 0
var _min_value: int = MIN_VALUE
var _max_value: int = MAX_VALUE


func set_min(value: Variant) -> void:
	_min_value = maxi(value, MIN_VALUE)

func get_min() -> int:
	return _min_value


func set_max(value: Variant) -> void:
	_max_value = mini(value, MAX_VALUE)

func get_max() -> int:
	return _max_value


func validate(value: Variant) -> bool:
	if value is int or value is float:
		return value >= get_min() and value <= get_max()

	return false


func set_default(value: Variant) -> void:
	if validate(value):
		_default = value

func get_default() -> int:
	return _default


func get_built_in_type() -> Variant.Type:
	return TYPE_INT


func get_type_name() -> StringName:
	return &"int_range"
