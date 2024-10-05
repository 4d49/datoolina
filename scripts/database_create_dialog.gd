# Copyright (c) 2024 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends ConfirmationDialog


signal database_created(database: Dictionary)


const DictionaryDB: GDScript = preload("res://scripts/dictionary_database.gd")


var _line_edit: LineEdit = null


func _init() -> void:
	self.set_flag(Window.FLAG_RESIZE_DISABLED, true)
	self.set_title(tr("Create Database"))
	self.set_min_size(Vector2i(300, 0))

	var create := get_ok_button()
	create.set_text("Create")

	_line_edit = LineEdit.new()
	_line_edit.set_text("new_database")
	_line_edit.select_all()
	_line_edit.set_placeholder("Database ID")
	_line_edit.set_clear_button_enabled(true)
	_line_edit.call_deferred(&"grab_focus")
	_line_edit.text_changed.connect(_on_line_edit_text_changed)
	self.register_text_enter(_line_edit)
	self.add_child(_line_edit)

	self.confirmed.connect(_on_confirmed)
	self.confirmed.connect(queue_free, CONNECT_DEFERRED)
	self.canceled.connect(queue_free)
	self.close_requested.connect(queue_free)


func is_valid_id(id: StringName) -> bool:
	return DictionaryDB.is_valid_id(id)


func create_database(id: StringName) -> Dictionary:
	return DictionaryDB.create_database(id)


func _on_line_edit_text_changed(id: StringName) -> void:
	get_ok_button().set_disabled(not is_valid_id(id))


func _on_confirmed() -> void:
	var database := create_database(_line_edit.get_text())
	if database.is_empty():
		return

	database_created.emit(database)
