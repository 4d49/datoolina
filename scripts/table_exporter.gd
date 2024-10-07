# Copyright (c) 2024 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends RefCounted


const DictionaryDB: GDScript = preload("res://scripts/dictionary_database.gd")


static var _formats: Array[Dictionary] = []


static func _static_init() -> void:
	add_format_exporter("cfg", "Config File", _table_export_cfg)
	add_format_exporter("json", "JSON File", _table_export_json)


static func default_handler(extension: String) -> Callable:
	return func(path: String) -> bool:
		return path.get_extension() == extension

static func add_format_exporter(extension: String, name: String, exporter: Callable, handler: Callable = default_handler(extension)) -> void:
	if not exporter.is_valid() or not handler.is_valid():
		return

	var format: Dictionary[StringName, Variant] = {
		&"name": name,
		&"handler": handler,
		&"exporter": exporter,
		&"extension": extension,
	}
	_formats.push_back(format)


static func get_support_file_extension() -> PackedStringArray:
	var support_extension := PackedStringArray()

	for i: int in _formats.size():
		var format: Dictionary = _formats[i]
		if not format.exporter.is_valid():
			continue

		if format.name.is_empty():
			support_extension.push_back("*." + format.extension)
		else:
			support_extension.push_back("*." + format.extension + ";" + format.name)

	return support_extension


static func export_table(table: Dictionary[StringName, Variant], path: String) -> Error:
	for format: Dictionary in _formats:
		if not format.handler.call(path):
			continue

		return format.exporter.call(table, path)

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
	}
static func _serialize_columns(columns: Array[Dictionary]) -> Array:
	var serialized: Array = []
	serialized.resize(columns.size())

	for i: int in columns.size():
		serialized[i] = _serialize_column(columns[i])

	return serialized


static func serialize_dictionary_table(table: Dictionary[StringName, Variant]) -> Dictionary:
	return {
		"id": DictionaryDB.table_get_id(table),
		"columns": _serialize_columns(DictionaryDB.table_get_columns(table)),
		"records": _serialize_records(DictionaryDB.table_get_records(table)),
	}

static func _table_export_cfg(table: Dictionary[StringName, Variant], path: String) -> Error:
	var serialized: Dictionary = serialize_dictionary_table(table)

	var config := ConfigFile.new()
	config.set_value("", "table", serialized)

	return config.save(path)


static func _table_export_json(table: Dictionary[StringName, Variant], path: String) -> Error:
	var serialized: Dictionary = serialize_dictionary_table(table)

	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		printerr(error_string(FileAccess.get_open_error()))
		return FileAccess.get_open_error()

	file.store_string(JSON.stringify(serialized, "\t"))
	file.close()

	return OK
