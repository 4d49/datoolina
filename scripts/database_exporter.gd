# Copyright (c) 2024-2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends RefCounted


static var _formats: Array[Dictionary] = []


static func _static_init() -> void:
	add_format_exporter("json", "JSON File", _database_export_json)


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
	format.make_read_only()

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


static func export_database(database: AbstractDatabase, path: String) -> Error:
	for format: Dictionary in _formats:
		if not format.handler.call(path):
			continue

		return format.exporter.call(database, path)

	return FAILED



# FIXME: Требуется новая реализация!
static func _serialize_record(record: AbstractRecord) -> Dictionary:
	return {}

static func _serialize_table(table: AbstractTable) -> Dictionary:
	var primary_key: StringName = table.get_schema().get_primary_key().get_name()

	var serialized: Dictionary = {}

	for record: AbstractRecord in table.get_records():
		serialized[record.get_value(primary_key)] = _serialize_record(record)

	return serialized

static func _serialize_database(database: AbstractDatabase) -> Dictionary:
	var serialized: Dictionary = {}

	for table: AbstractTable in database.get_tables():
		serialized[table.get_name()] = _serialize_table(table)

	return serialized

static func _database_export_json(database: AbstractDatabase, path: String) -> Error:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		printerr(error_string(FileAccess.get_open_error()))
		return FileAccess.get_open_error()

	file.store_string(JSON.stringify(_serialize_database(database), "\t"))
	file.close()

	return OK
