# Copyright (c) 2024-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends ConfirmationDialog


signal database_created(database: AbstractDatabase)


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
	_line_edit.set_placeholder("Database Name")
	_line_edit.set_clear_button_enabled(true)
	_line_edit.call_deferred(&"grab_focus")
	_line_edit.text_changed.connect(_on_line_edit_text_changed)
	self.register_text_enter(_line_edit)
	self.add_child(_line_edit)

	self.confirmed.connect(_on_confirmed)
	self.confirmed.connect(queue_free, CONNECT_DEFERRED)
	self.canceled.connect(queue_free)
	self.close_requested.connect(queue_free)


func is_valid_database_name(db_name: StringName) -> bool:
	return db_name.is_valid_ascii_identifier()


func create_database(db_name: StringName) -> AbstractDatabase:
	if is_valid_database_name(db_name):
		return null

	return DatabaseFactory.create_database(db_name)


func _on_line_edit_text_changed(text: StringName) -> void:
	get_ok_button().set_disabled(not is_valid_database_name(text))


func _on_confirmed() -> void:
	var db_name := _line_edit.get_text()
	if not is_valid_database_name(db_name):
		return

	var db := create_database(db_name)
	if is_instance_valid(db):
		database_created.emit(db)
		queue_free()
	else:
		printerr("Failed to create database with name: ", db_name)
