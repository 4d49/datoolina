# Copyright (c) 2024 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends ConfirmationDialog


signal record_renamed(id: StringName)


const DictionaryDB: GDScript = preload("res://scripts/dictionary_database.gd")


var _line_edit: LineEdit = null

var _table: Dictionary[StringName, Variant] = DictionaryDB.NULL_TABLE
var _record: Dictionary[StringName, Variant] = DictionaryDB.NULL_RECORD


func _init(table: Dictionary[StringName, Variant], record: Dictionary[StringName, Variant]) -> void:
	self.set_title("Rename Record")
	self.set_flag(Window.FLAG_RESIZE_DISABLED, true)

	_table = table
	_record = record

	var ok_button := get_ok_button()
	ok_button.set_text("Rename")
	ok_button.set_disabled(true)

	_line_edit = LineEdit.new()
	_line_edit.set_text(DictionaryDB.record_get_id(record))
	_line_edit.set_placeholder("Column ID")
	_line_edit.text_changed.connect(_on_id_changed)
	self.add_child(_line_edit)

	confirmed.connect(_on_confirmed)


func is_valid_id(id: StringName) -> bool:
	return DictionaryDB.is_valid_id(id)

func has_record(id: StringName) -> bool:
	return DictionaryDB.table_has_record_id(_table, id)


func _on_id_changed(id: StringName) -> void:
	get_ok_button().set_disabled(not is_valid_id(id) or has_record(id))

func _on_confirmed() -> void:
	if DictionaryDB.record_set_id(_record, _line_edit.get_text()):
		record_renamed.emit(_line_edit.get_text())
