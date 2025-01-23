# Copyright (c) 2024-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends FileDialog


const DB: GDScript = preload("res://scripts/database.gd")
const TableExporter: GDScript = preload("res://scripts/table_exporter.gd")


var _table: Dictionary[StringName, Variant] = DB.NULL_TABLE


func _init(table: Dictionary[StringName, Variant]) -> void:
	_table = table

	self.set_title("Export Table As...")
	self.set_min_size(Vector2i(500, 300))
	self.set_access(FileDialog.ACCESS_FILESYSTEM)
	self.set_file_mode(FileDialog.FILE_MODE_SAVE_FILE)
	self.set_ok_button_text("Export")
	self.set_filters(get_support_file_extension())

	self.file_selected.connect(_on_file_selected)

	self.close_requested.connect(queue_free)
	self.canceled.connect(queue_free)


func get_support_file_extension() -> PackedStringArray:
	return TableExporter.get_support_file_extension()


func _on_file_selected(path: String) -> void:
	var error: Error = TableExporter.export_table(_table, path)
	if error:
		printerr(error_string(error))

	queue_free()
