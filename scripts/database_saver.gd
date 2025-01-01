# Copyright (c) 2024 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends RefCounted


const DictionaryDB: GDScript = preload("res://scripts/dictionary_database.gd")


static var _format_handlers: Array[Dictionary] = []


static func _static_init() -> void:
	add_format_saver("cfg", "Config File", _database_save_cfg)
	add_format_saver("json", "JSON File", _database_save_json)


static func default_handler(extension: String) -> Callable:
	return func(path: String) -> bool:
		return path.get_extension() == extension

static func add_format_saver(extension: String, name: String, file_saver: Callable, handler: Callable = default_handler(extension)) -> void:
	if not file_saver.is_valid() or not handler.is_valid():
		return

	var format: Dictionary[StringName, Variant] = {
		&"name": name,
		&"handler": handler,
		&"extension": extension,
		&"file_saver": file_saver,
	}
	_format_handlers.push_back(format)


static func get_support_file_extension() -> PackedStringArray:
	var support_extension := PackedStringArray()
	support_extension.resize(_format_handlers.size())

	for i: int in _format_handlers.size():
		var handler: Dictionary = _format_handlers[i]
		if not handler.file_saver.is_valid():
			continue

		if handler.name.is_empty():
			support_extension[i] = "*." + handler.extension
		else:
			support_extension[i] = "*." + handler.extension + ";" + handler.name

	return support_extension


static func save_database(database: Dictionary[StringName, Variant], path: String) -> Error:
	for format: Dictionary in _format_handlers:
		if not format.handler.call(path):
			continue

		return format.file_saver.call(database, path)

	return FAILED




static func _serialize_record(record: Dictionary[StringName, Variant]) -> Dictionary:
	var serialized: Dictionary = {}

	for key: String in record:
		serialized[key] = record[key]

	return serialized
static func _serialize_records(records: Array[Dictionary]) -> Array:
	var serialized: Array = []
	serialized.resize(records.size())

	for i: int in records.size():
		serialized[i] = _serialize_record(records[i])

	return serialized

static func _serialize_column(column: Dictionary[StringName, Variant]) -> Dictionary:
	return {
		"id": DictionaryDB.column_get_id(column),
		"type": DictionaryDB.column_get_type(column),
		"value": DictionaryDB.column_get_default_value(column),
		"hint": DictionaryDB.column_get_hint(column),
		"hint_string": DictionaryDB.column_get_hint_string(column),
		"description": DictionaryDB.column_get_description(column),
	}
static func _serialize_columns(columns: Array[Dictionary]) -> Array:
	var serialized: Array = []
	serialized.resize(columns.size())

	for i: int in columns.size():
		serialized[i] = _serialize_column(columns[i])

	return serialized

static func _serialize_table(table: Dictionary) -> Dictionary:
	return {
		"id": DictionaryDB.table_get_id(table),
		"columns": _serialize_columns(DictionaryDB.table_get_columns(table)),
		"records": _serialize_records(DictionaryDB.table_get_records(table)),
	}
static func _serialize_tables(tables: Array[Dictionary]) -> Array:
	var serialized: Array = []
	serialized.resize(tables.size())

	for i: int in tables.size():
		serialized[i] = _serialize_table(tables[i])

	return serialized

static func _serialize_database(database: Dictionary) -> Dictionary:
	return {
		"id": DictionaryDB.database_get_id(database),
		"tables": _serialize_tables(DictionaryDB.database_get_tables(database)),
	}

static func _database_save_cfg(database: Dictionary, path: String) -> Error:
	var serialized: Dictionary = _serialize_database(database)

	var config := ConfigFile.new()
	config.set_value("", "database", serialized)

	return config.save(path)


static func _database_save_json(database: Dictionary, path: String) -> Error:
	var serialized: Dictionary = _serialize_database(database)

	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()

	file.store_string(JSON.stringify(serialized, "\t"))
	file.close()

	return OK
