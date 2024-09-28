# Copyright (c) 2024 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends FileDialog


signal database_loaded(database: Dictionary[StringName, Variant])


const DictionaryDB: GDScript = preload("res://scripts/dictionary_database.gd")
const DatabaseLoader: GDScript = preload("res://scripts/database_loader.gd")


var _database: Dictionary[StringName, Variant] = DictionaryDB.NULL_DATABASE


func _init(database: Dictionary[StringName, Variant]) -> void:
	_database = database

	self.set_title("Open Database")
	self.set_min_size(Vector2i(500, 300))
	self.set_access(FileDialog.ACCESS_FILESYSTEM)
	self.set_file_mode(FileDialog.FILE_MODE_OPEN_FILE)
	self.set_ok_button_text("Load")
	self.set_filters(get_support_file_extension())

	self.close_requested.connect(queue_free)
	self.file_selected.connect(_on_file_selected)
	self.canceled.connect(queue_free)


func get_support_file_extension() -> PackedStringArray:
	return DatabaseLoader.get_support_file_extension()


func _on_file_selected(path: String) -> void:
	var database: Dictionary[StringName, Variant] = DatabaseLoader.load_database(path)
	database_loaded.emit(database)

	queue_free()
