# Copyright (c) 2024-2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends AbstractDataTypeEditor


const MIN_VALUE: int = -0x80000000
const MAX_VALUE: int =  0x7FFFFFFF


var _spin_min: SpinBox
var _spin_max: SpinBox
var _spin_default: SpinBox


static func can_handle(data_type: AbstractDataType) -> bool:
	return data_type.get_built_in_type() == TYPE_INT or data_type.get_built_in_type() == TYPE_FLOAT


func _init(data_type: AbstractDataType) -> void:
	var is_int: bool = data_type.get_built_in_type() == TYPE_INT
	var step: float = 1.0 if is_int else 0.001

	_spin_default = create_spin_box(data_type.get_default(), MIN_VALUE, MAX_VALUE, step, is_int)
	_spin_default.value_changed.connect(data_type.set_default)
	add_row("Value Default", _spin_default)

	if data_type is AbstractRangeDataType:
		_spin_min = create_spin_box(data_type.get_min(), MIN_VALUE, MAX_VALUE, step, is_int)
		_spin_min.value_changed.connect(data_type.set_min)
		_spin_min.value_changed.connect(_spin_default.set_min)
		add_row("Value Min", _spin_min)

		_spin_max = create_spin_box(data_type.get_max(), MIN_VALUE, MAX_VALUE, step, is_int)
		_spin_max.value_changed.connect(data_type.set_max)
		_spin_max.value_changed.connect(_spin_default.set_max)
		add_row("Value Max", _spin_max)
