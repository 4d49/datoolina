# Copyright (c) 2024-2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends AbstractDataTypeEditor


var _color_button: ColorPickerButton


static func can_handle(data_type: AbstractDataType) -> bool:
	return data_type.get_built_in_type() == TYPE_COLOR


func _init(data_type: AbstractDataType) -> void:
	_color_button = ColorPickerButton.new()
	_color_button.set_pick_color(data_type.get_default())
	_color_button.color_changed.connect(data_type.set_default)
	add_row("Default Value", _color_button)
