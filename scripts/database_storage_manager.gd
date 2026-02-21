# Copyright (c) 2024-2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

## DatabaseStorageManager provides serialization capabilities for AbstractDatabase instances.
##
## This class implements the AbstractDatabaseSerializer system, allowing
## databases to be saved in various formats by delegating to concrete
## serializer implementations. It maintains backward compatibility with
## existing code that uses database saving functionality.

extends RefCounted


static var _serializers: Array[AbstractDatabaseSerializer] = []


## Initializes the DatabaseSaver with available serializers.
static func _static_init() -> void:
	_serializers.push_back(preload("database/impl/json_database_serializer.gd").new())


## Gets the list of supported file extensions for database serialization.
##
## Returns an array of strings in the format "*.extension;Description"
## that can be used for file dialog filters.
static func get_support_file_extension() -> PackedStringArray:
	var support_extensions := PackedStringArray()
	for serializer: AbstractDatabaseSerializer in _serializers:
		support_extensions.push_back("*." + serializer.get_extension() + ";" + serializer.get_name())

	return support_extensions


## Saves a database to the specified file path.
## Returns error code indicating success or failure of the operation.
static func save_database(database: AbstractDatabase, path: String) -> Error:
	var extension: String = path.get_extension()

	for serializer: AbstractDatabaseSerializer in _serializers:
		if serializer.get_extension() == extension:
			return serializer.save(database, path)

	return FAILED


## Loads a database from the specified file path.
## Returns the loaded database instance, or null if loading failed.
static func load_database(path: String) -> AbstractDatabase:
	var extension: String = path.get_extension()

	for serializer: AbstractDatabaseSerializer in _serializers:
		if serializer.get_extension() == extension:
			return serializer.load(path)

	return null
