# Copyright (c) 2024-2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends AbstractDataTypeEditor


var _line_edit: LineEdit


static func can_handle(data_type: AbstractDataType) -> bool:
	return data_type.get_built_in_type() == TYPE_STRING or data_type.get_built_in_type() == TYPE_STRING_NAME


func _init(data_type: AbstractDataType) -> void:
	_line_edit = LineEdit.new()
	_line_edit.set_text(data_type.get_default())
	if data_type.get_built_in_type() == TYPE_STRING_NAME:
		_line_edit.set_placeholder("StringName")
	_line_edit.text_changed.connect(data_type.set_default)
	add_row("Default Value", _line_edit)
