# Copyright (c) 2024-2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends ConfirmationDialog


signal rename_requested(old_name: StringName, new_name: StringName)


var _line_edit: LineEdit = null

var _table: AbstractTable = null
var _current_name: StringName


func _init(table: AbstractTable, current_name: StringName) -> void:
	self.set_title("Rename Column")
	self.set_flag(Window.FLAG_RESIZE_DISABLED, true)

	_table = table
	_current_name = current_name

	var ok_button := get_ok_button()
	ok_button.set_text("Rename")
	ok_button.set_disabled(true)

	_line_edit = LineEdit.new()
	_line_edit.set_text(current_name)
	_line_edit.set_placeholder("Column Name")
	_line_edit.set_clear_button_enabled(true)
	_line_edit.text_changed.connect(_on_text_changed)
	self.add_child(_line_edit)

	self.reset_size()

	canceled.connect(queue_free)
	confirmed.connect(_on_confirmed)


func is_valid_id(id: StringName) -> bool:
	return id.is_valid_ascii_identifier()


func has_column(column_name: StringName) -> bool:
	return _table.has_column(column_name)


func can_rename_column_to(column_name: StringName) -> bool:
	return is_valid_id(column_name) and not has_column(column_name)


func _on_text_changed(text: StringName) -> void:
	get_ok_button().set_disabled(not can_rename_column_to(text))


func _on_confirmed() -> void:
	rename_requested.emit(_current_name, _line_edit.get_text())
