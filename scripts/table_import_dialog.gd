# Copyright (c) 2024-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends FileDialog


signal table_imported(table: Dictionary[StringName, Variant])


const DictionaryDB: GDScript = preload("res://scripts/dictionary_database.gd")
const TableImporter: GDScript = preload("res://scripts/table_importer.gd")


func _init() -> void:
	self.set_min_size(Vector2i(500, 300))
	self.set_access(FileDialog.ACCESS_FILESYSTEM)
	self.set_file_mode(FileDialog.FILE_MODE_OPEN_FILE)
	self.set_ok_button_text("Import")
	self.set_filters(get_support_file_extension())
	self.set_title("Import Table...")

	self.file_selected.connect(_on_file_selected)
	self.confirmed.connect(queue_free)

	self.close_requested.connect(queue_free)
	self.canceled.connect(queue_free)


func get_support_file_extension() -> PackedStringArray:
	return TableImporter.get_support_file_extension()


func _on_file_selected(path: String) -> void:
	var table: Dictionary[StringName, Variant] = TableImporter.import_table(path)
	if table.is_read_only():
		return printerr("Table import failed.")

	table_imported.emit(table)
