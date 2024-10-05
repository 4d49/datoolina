# Copyright (c) 2024 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends ConfirmationDialog


signal table_created


const DictionaryDB: GDScript = preload("res://scripts/dictionary_database.gd")


var _line_edit: LineEdit = null

var _database: Dictionary[StringName, Variant] = DictionaryDB.NULL_DATABASE


func _init(database: Dictionary[StringName, Variant]) -> void:
	_database = database

	self.set_title("Create Table")
	self.set_flag(Window.FLAG_RESIZE_DISABLED, true)

	var ok_button := get_ok_button()
	ok_button.set_text("Create")
	ok_button.set_disabled(has_table("new_table"))

	_line_edit = LineEdit.new()
	_line_edit.set_text("new_table")
	_line_edit.select_all()
	_line_edit.set_placeholder("Table ID")
	_line_edit.set_clear_button_enabled(true)
	_line_edit.call_deferred(&"grab_focus")
	_line_edit.text_changed.connect(_on_line_edit_id_changed)
	self.register_text_enter(_line_edit)
	self.add_child(_line_edit)

	self.confirmed.connect(_on_confirmed)


func is_valid_id(id: StringName) -> bool:
	return DictionaryDB.is_valid_id(id)

func has_table(id: StringName) -> bool:
	return DictionaryDB.database_has_table_id(_database, id)


func _on_line_edit_id_changed(id: StringName) -> void:
	get_ok_button().set_disabled(not is_valid_id(id) or has_table(id))

func _on_confirmed() -> void:
	if DictionaryDB.database_create_table(_database, _line_edit.get_text()).is_read_only():
		return

	table_created.emit()
