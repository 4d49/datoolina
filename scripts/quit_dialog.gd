# Copyright (c) 2024 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends ConfirmationDialog


signal save_requested
signal discard_requested
signal cancel_requested


func _init() -> void:
	self.set_title("Unsaved Changes")
	self.set_text("You have unsaved changes or the file has never been saved.\nDo you want to save your changes before exiting?")
	self.set_flag(Window.FLAG_RESIZE_DISABLED, true)

	var save := get_ok_button()
	save.set_text("Save & Close")
	save.pressed.connect(save_requested.emit)

	var discard := add_button("Don't Save", true)
	discard.pressed.connect(discard_requested.emit)

	var cancel := get_cancel_button()
	cancel.set_text("Cancel")
	cancel.pressed.connect(cancel_requested.emit)
