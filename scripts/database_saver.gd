# Copyright (c) 2024-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

# FIXME: Фактически нужна новая реализация класса!
extends RefCounted


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


static func save_database(database: AbstractDatabase, path: String) -> Error:
	for format: Dictionary in _format_handlers:
		if not format.handler.call(path):
			continue

		return format.file_saver.call(database, path)

	return FAILED


static func _serialize_record(record: AbstractRecord, columns: Array[StringName]) -> Dictionary:
	var serialized: Dictionary = {}

	for key: String in columns:
		serialized[key] = record.get_value(key)

	return serialized


static func _serialize_records(table: AbstractTable) -> Array:
	var records: Array[AbstractRecord] = table.get_records()
	var columns: Array[StringName] = table.get_column_names()

	var serialized: Array[Dictionary] = []
	serialized.resize(records.size())

	for i: int in records.size():
		serialized[i] = _serialize_record(records[i], columns)

	return serialized


static func _serialize_column(column: AbstractColumn) -> Dictionary:
	return {
		"id": column.get_name(),
		"type": column.get_built_in_type(),
		"value": column.get_default(),
		"hint": PROPERTY_HINT_NONE,
		"hint_string": "",
		"description": column.get_description(),
	}


static func _serialize_columns(columns: Array[AbstractColumn]) -> Array:
	var serialized: Array[Dictionary] = []
	serialized.resize(columns.size())

	for i: int in columns.size():
		serialized[i] = _serialize_column(columns[i])

	return serialized


static func _serialize_table(table: AbstractTable) -> Dictionary:
	return {
		"id": table.get_name(),
		"columns": _serialize_columns(table.get_columns()),
		"records": _serialize_records(table),
		"description": table.get_description(),
	}


static func _serialize_tables(tables: Array[AbstractTable]) -> Array:
	var serialized: Array[Dictionary] = []
	serialized.resize(tables.size())

	for i: int in tables.size():
		serialized[i] = _serialize_table(tables[i])

	return serialized


static func _serialize_database(database: AbstractDatabase) -> Dictionary:
	return {
		"id": database.get_name(),
		"tables": _serialize_tables(database.get_tables()),
	}


static func _database_save_cfg(database: AbstractDatabase, path: String) -> Error:
	var serialized: Dictionary = _serialize_database(database)

	var config := ConfigFile.new()
	config.set_value("", "database", serialized)

	return config.save(path)


static func _database_save_json(database: AbstractDatabase, path: String) -> Error:
	var serialized: Dictionary = _serialize_database(database)

	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()

	file.store_string(JSON.stringify(serialized, "\t", false))
	file.close()

	return OK
