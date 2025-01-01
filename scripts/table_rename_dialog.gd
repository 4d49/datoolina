# Copyright (c) 2024-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends ConfirmationDialog


signal table_renamed


const DictionaryDB: GDScript = preload("res://scripts/dictionary_database.gd")


var _line_edit: LineEdit = null

var _database: Dictionary[StringName, Variant] = DictionaryDB.NULL_DATABASE
var _table: Dictionary[StringName, Variant] = DictionaryDB.NULL_TABLE


func _init(database: Dictionary, table: Dictionary) -> void:
	_database = database
	_table = table

	self.set_title("Create Table")
	self.set_flag(Window.FLAG_RESIZE_DISABLED, true)

	var ok_button := get_ok_button()
	ok_button.set_text("Rename")
	ok_button.set_disabled(true)

	_line_edit = LineEdit.new()
	_line_edit.set_text(DictionaryDB.table_get_id(table))
	_line_edit.set_clear_button_enabled(true)
	_line_edit.text_changed.connect(_on_id_changed)
	self.add_child(_line_edit)

	confirmed.connect(_on_confirmed)
	canceled.connect(queue_free)


func is_valid_id(id: StringName) -> bool:
	return DictionaryDB.is_valid_id(id)

func has_table_id(id: StringName) -> bool:
	return DictionaryDB.database_has_table_id(_database, id)


func _on_id_changed(id: StringName) -> void:
	get_ok_button().set_disabled(not is_valid_id(id) or has_table_id(id))

func _on_confirmed() -> void:
	if DictionaryDB.table_set_id(_table, _line_edit.get_text()):
		table_renamed.emit()
