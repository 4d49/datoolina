# Copyright (c) 2024-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends ConfirmationDialog


signal column_renamed(id: StringName)


const DB: GDScript = preload("res://scripts/database.gd")


var _line_edit: LineEdit = null

var _table: Dictionary[StringName, Variant] = DB.NULL_TABLE


func _init(table: Dictionary[StringName, Variant], current_column_id: String) -> void:
	self.set_title("Rename Column")
	self.set_flag(Window.FLAG_RESIZE_DISABLED, true)

	_table = table

	var ok_button := get_ok_button()
	ok_button.set_text("Rename")
	ok_button.set_disabled(true)

	_line_edit = LineEdit.new()
	_line_edit.set_text(current_column_id)
	_line_edit.set_placeholder("Column ID")
	_line_edit.set_clear_button_enabled(true)
	_line_edit.text_changed.connect(_on_id_changed)
	self.add_child(_line_edit)

	confirmed.connect(_on_confirmed)


func is_valid_id(id: StringName) -> bool:
	return DB.is_valid_id(id)

func has_column(id: StringName) -> bool:
	return DB.table_has_column_id(_table, id)


func _on_id_changed(id: StringName) -> void:
	get_ok_button().set_disabled(not is_valid_id(id) or has_column(id))

func _on_confirmed() -> void:
	column_renamed.emit(_line_edit.get_text())
