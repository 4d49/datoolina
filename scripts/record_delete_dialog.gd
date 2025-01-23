# Copyright (c) 2024-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends ConfirmationDialog


const DB: GDScript = preload("res://scripts/database.gd")


signal record_deleted


var _table: Dictionary = DB.NULL_TABLE
var _record: Dictionary = DB.NULL_RECORD


func _init(table: Dictionary, record: Dictionary) -> void:
	_table = table
	_record = record

	self.set_title("Delete Record")
	self.set_flag(Window.FLAG_RESIZE_DISABLED, true)
	self.set_text("Are you sure you want to delete this record?")
	self.set_ok_button_text("Delete")
	self.set_cancel_button_text("Cancel")

	confirmed.connect(_on_confirmed)
	canceled.connect(queue_free)
	close_requested.connect(queue_free)


func _on_confirmed() -> void:
	if DB.table_erase_record(_table, _record):
		record_deleted.emit()
