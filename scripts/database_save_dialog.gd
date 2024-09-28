# Copyright (c) 2024 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends FileDialog


const DictionaryDB: GDScript = preload("res://scripts/dictionary_database.gd")
const DatabaseSaver: GDScript = preload("res://scripts/database_saver.gd")


var _database: Dictionary[StringName, Variant] = DictionaryDB.NULL_DATABASE


func _init(database: Dictionary[StringName, Variant]) -> void:
	_database = database

	self.set_title("Save Database As...")
	self.set_min_size(Vector2i(500, 300))
	self.set_access(FileDialog.ACCESS_FILESYSTEM)
	self.set_file_mode(FileDialog.FILE_MODE_SAVE_FILE)
	self.set_ok_button_text("Save")
	self.set_filters(get_support_file_extension())

	self.close_requested.connect(queue_free)
	self.file_selected.connect(_on_file_selected)
	self.canceled.connect(queue_free)


func get_support_file_extension() -> PackedStringArray:
	return DatabaseSaver.get_support_file_extension()


func _on_file_selected(path: String) -> void:
	var error: Error = DatabaseSaver.save_database(_database, path)
	if error:
		printerr(error_string(error))

	queue_free()
