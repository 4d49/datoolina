# Copyright (c) 2024-2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends AbstractRangeDataType


const MIN_VALUE: float = -3.4028235e+38
const MAX_VALUE: float =  3.4028235e+38


var _default: float = 0.0
var _min_value: float = MIN_VALUE
var _max_value: float = MAX_VALUE


func set_min(value: Variant) -> void:
	_min_value = maxf(value, MIN_VALUE)

func get_min() -> float:
	return _min_value


func set_max(value: Variant) -> void:
	_max_value = minf(value, MAX_VALUE)

func get_max() -> float:
	return _max_value


func validate(value: Variant) -> bool:
	if value is float or value is int:
		return value >= get_min() and value <= get_max()

	return false


func set_default(value: Variant) -> void:
	if validate(value):
		_default = value

func get_default() -> float:
	return _default


func get_built_in_type() -> Variant.Type:
	return TYPE_FLOAT


func get_type_name() -> StringName:
	return &"float_range"
