# Copyright (c) 2024-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends ConfirmationDialog


const TableEditor: GDScript = preload("res://scripts/table_editor.gd")


var _table_editor: TableEditor = null


func _init(table: Dictionary[StringName, Variant]) -> void:
	self.set_title("Edit Table")
	self.set_min_size(Vector2i(500, 300))

	var ok_button := get_ok_button()
	ok_button.set_text("Apply")

	_table_editor = TableEditor.new(table)
	self.add_child(_table_editor)

	self.confirmed.connect(_table_editor.apply_changed)
	self.confirmed.connect(queue_free)

	self.close_requested.connect(queue_free)
	self.canceled.connect(queue_free)
