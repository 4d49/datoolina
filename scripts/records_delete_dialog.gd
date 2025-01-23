# Copyright (c) 2024-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends ConfirmationDialog


const DB: GDScript = preload("res://scripts/database.gd")


signal records_deleted


var _vbox: VBoxContainer = null
var _label: Label = null
var _tree: Tree = null

var _table: Dictionary = DB.NULL_TABLE
var _records: Array = DB.NULL_RECORDS


func _init(table: Dictionary, records: Array[Dictionary]) -> void:
	_table = table
	_records = records

	self.set_title("Delete Records")
	self.set_flag(Window.FLAG_RESIZE_DISABLED, false)
	self.set_ok_button_text("Delete")
	self.set_cancel_button_text("Cancel")

	_vbox = VBoxContainer.new()
	self.add_child(_vbox)

	_label = Label.new()
	_label.set_text("Are you sure you want to delete this records?")
	_vbox.add_child(_label)

	_tree = Tree.new()
	_tree.set_hide_root(true)
	_tree.set_auto_translate_mode(Node.AUTO_TRANSLATE_MODE_DISABLED)
	_tree.set_v_size_flags(Control.SIZE_EXPAND_FILL)

	var root: TreeItem = _tree.create_item()
	for record: Dictionary in _records:
		var item: TreeItem = root.create_child()
		item.set_text(0, DB.record_get_id(record))

	_vbox.add_child(_tree)

	confirmed.connect(_on_confirmed)
	canceled.connect(queue_free)
	close_requested.connect(queue_free)


func _on_confirmed() -> void:
	for record: Dictionary in _records:
		DB.table_erase_record(_table, record)

	records_deleted.emit()
