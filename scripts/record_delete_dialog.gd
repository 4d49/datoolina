# Copyright (c) 2024-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends ConfirmationDialog


signal record_deleted


var _table: AbstractTable = null
var _record: AbstractRow = null


func _init(table: AbstractTable, record: AbstractRow) -> void:
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
	if _table.remove_row(_record):
		record_deleted.emit()
