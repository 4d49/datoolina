# Copyright (c) 2024-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends ConfirmationDialog


signal record_renamed(id: StringName)


const DB: GDScript = preload("res://scripts/database.gd")


var _line_edit: LineEdit = null

var _table: Dictionary[StringName, Variant] = DB.NULL_TABLE
var _record: Dictionary[StringName, Variant] = DB.NULL_RECORD


func _init(table: Dictionary[StringName, Variant], record: Dictionary[StringName, Variant]) -> void:
	self.set_title("Rename Record")
	self.set_flag(Window.FLAG_RESIZE_DISABLED, true)

	_table = table
	_record = record

	var ok_button := get_ok_button()
	ok_button.set_text("Rename")
	ok_button.set_disabled(true)

	_line_edit = LineEdit.new()
	_line_edit.set_text(DB.record_get_id(record))
	_line_edit.set_placeholder("Record ID")
	_line_edit.set_clear_button_enabled(true)
	_line_edit.text_changed.connect(_on_id_changed)
	self.add_child(_line_edit)

	confirmed.connect(_on_confirmed)


func is_valid_id(id: StringName) -> bool:
	return DB.is_valid_id(id)

func has_record(id: StringName) -> bool:
	return DB.table_has_record_id(_table, id)


func _on_id_changed(id: StringName) -> void:
	get_ok_button().set_disabled(not is_valid_id(id) or has_record(id))

func _on_confirmed() -> void:
	if DB.record_set_id(_record, _line_edit.get_text()):
		record_renamed.emit(_line_edit.get_text())
