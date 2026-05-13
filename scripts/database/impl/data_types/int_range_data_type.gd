# Copyright (c) 2024-2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends "abstract_int_data_type.gd"

# 32-bit signed integer limits
const MIN_VALUE: int = -0x80000000
const MAX_VALUE: int =  0x7FFFFFFF


var _min_value: int = MIN_VALUE
var _max_value: int = MAX_VALUE


func validate(value: Variant) -> bool:
	if value is int or value is float:
		return value >= _min_value and value <= _max_value

	return false


func get_type_hint() -> Hint:
	return Hint.RANGE


func get_type_name() -> StringName:
	return &"int_range"


func set_min_value(value: int) -> void:
	_min_value = maxi(value, MIN_VALUE)

func get_min_value() -> int:
	return _min_value


func set_max_value(value: int) -> void:
	_max_value = mini(value, MAX_VALUE)

func get_max_value() -> int:
	return _max_value
