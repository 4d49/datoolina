# Copyright (c) 2024-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends ConfirmationDialog


signal table_deleted


const DB: GDScript = preload("res://scripts/database.gd")


var _database: Dictionary = DB.NULL_DATABASE
var _table: Dictionary = DB.NULL_TABLE


func _init(database: Dictionary, table: Dictionary) -> void:
	_database = database
	_table = table

	self.set_title("Delete Table")
	self.set_flag(Window.FLAG_RESIZE_DISABLED, true)
	self.set_text("Are you sure you want to delete this table?")
	self.set_ok_button_text("Delete")
	self.set_cancel_button_text("Cancel")

	confirmed.connect(_on_confirmed)
	visibility_changed.connect(_on_visibility_changed)


func _on_confirmed() -> void:
	if DB.database_erase_table(_database, _table):
		table_deleted.emit()

func _on_visibility_changed() -> void:
	if not is_visible():
		queue_free()
