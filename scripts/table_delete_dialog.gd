# Copyright (c) 2024-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends ConfirmationDialog


signal table_deleted


var _database: AbstractDatabase = null
var _table: AbstractTable = null


func _init(database: AbstractDatabase, table: AbstractTable) -> void:
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
	if _database.remove_table(_table.get_name()):
		table_deleted.emit()

func _on_visibility_changed() -> void:
	if not is_visible():
		queue_free()
