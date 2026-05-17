# Copyright (c) 2024-2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends ConfirmationDialog


signal create_requsted(column_name: StringName)


var _line_edit: LineEdit
var _table: AbstractTable


func _init(table: AbstractTable) -> void:
	self.set_title("Create Column")
	self.set_flag(Window.FLAG_RESIZE_DISABLED, true)
	self.reset_size()

	_table = table

	var ok_button := get_ok_button()
	ok_button.set_text("Create")
	ok_button.set_disabled(true)

	_line_edit = LineEdit.new()
	_line_edit.set_placeholder("Column Name")
	_line_edit.set_clear_button_enabled(true)
	_line_edit.ready.connect(_line_edit.grab_focus)
	_line_edit.text_changed.connect(_on_text_changed)
	self.add_child(_line_edit)

	self.reset_size()

	canceled.connect(queue_free)
	confirmed.connect(_on_confirmed)


func is_valid_id(id: StringName) -> bool:
	return id.is_valid_ascii_identifier()

func has_column(column_name: StringName) -> bool:
	return _table.has_column(column_name)

func can_create_column(column_name: StringName) -> bool:
	return is_valid_id(column_name) and not has_column(column_name)


func _on_text_changed(text: StringName) -> void:
	get_ok_button().set_disabled(not can_create_column(text))

func _on_confirmed() -> void:
	create_requsted.emit(_line_edit.get_text())
