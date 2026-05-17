# Copyright (c) 2024-2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends AbstractDataTypeEditor


var _check_box: CheckBox


static func can_handle(data_type: AbstractDataType) -> bool:
	return data_type.get_built_in_type() == TYPE_BOOL


func _init(data_type: AbstractDataType) -> void:
	_check_box = CheckBox.new()
	_check_box.set_pressed(data_type.get_default())
	_check_box.toggled.connect(data_type.set_default)
	add_row("Default Value", _check_box)
