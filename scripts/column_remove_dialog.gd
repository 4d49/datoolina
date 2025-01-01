# Copyright (c) 2024-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends ConfirmationDialog


signal column_removed


func _init() -> void:
	self.set_title("Remove Column")
	self.set_flag(Window.FLAG_RESIZE_DISABLED, true)
	self.set_text("Are you sure you want to delete this column?")

	self.confirmed.connect(column_removed.emit)

	self.canceled.connect(queue_free)
	self.close_requested.connect(queue_free)
