# Copyright (c) 2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends AbstractDataType


const MIN_VALUE: float = -3.4028235e+38
const MAX_VALUE: float =  3.4028235e+38


var _min_value: float = MIN_VALUE
var _max_value: float = MAX_VALUE


func validate(value: Variant) -> bool:
	if value is float:
		return value >= _min_value and value <= _max_value

	return false


func get_default() -> Variant:
	return 0.0


func get_built_in_type() -> Variant.Type:
	return TYPE_FLOAT


func get_type_name() -> StringName:
	return &"float"


func set_min_value(value: float) -> void:
	_min_value = maxf(value, MIN_VALUE)

func get_min_value() -> float:
	return _min_value


func set_max_value(value: float) -> void:
	_max_value = minf(value, MAX_VALUE)

func get_max_value() -> float:
	return _max_value
