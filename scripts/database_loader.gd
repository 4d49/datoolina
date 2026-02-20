# Copyright (c) 2024-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends RefCounted


static var _format_handlers: Array[Dictionary] = []


static func _static_init() -> void:
	add_format_loader("cfg", "Config File", _database_load_cfg)
	add_format_loader("json", "JSON File", _database_load_json)


static func default_handler(extension: String) -> Callable:
	return func(path: String) -> bool:
		return path.get_extension() == extension

static func add_format_loader(extension: String, name: String, file_loader: Callable, handler: Callable = default_handler(extension)) -> void:
	if not file_loader.is_valid() or not handler.is_valid():
		return

	var format: Dictionary[StringName, Variant] = {
		&"name": name,
		&"handler": handler,
		&"extension": extension,
		&"file_loader": file_loader,
	}
	_format_handlers.push_back(format)


static func get_support_file_extension() -> PackedStringArray:
	var support_extension := PackedStringArray()
	support_extension.resize(_format_handlers.size())

	for i: int in _format_handlers.size():
		var handler: Dictionary = _format_handlers[i]
		if not handler.file_loader.is_valid():
			continue

		if handler.name.is_empty():
			support_extension[i] = "*." + handler.extension
		else:
			support_extension[i] = "*." + handler.extension + ";" + handler.name

	return support_extension


static func load_database(path: String) -> AbstractDatabase:
	for format: Dictionary in _format_handlers:
		if not format.handler.call(path):
			continue

		return format.file_loader.call(path)

	return null




static func _deserialize_database(data: Dictionary) -> AbstractDatabase:
	var database: AbstractDatabase = DatabaseFactory.create_database(data.id)

	for t: Dictionary in data.tables:
		var table: AbstractTable = DatabaseFactory.create_table(t.id)
		table.set_description(t.description)

		for c: Dictionary in t.columns:
			var data_type: AbstractDataType = DatabaseFactory.create_data_type(c.type)
			var column: AbstractColumn = DatabaseFactory.create_column(c.id, data_type)
			column.set_description(c.description)
			column.set_data_type(data_type)
			column.set_default(c.value)
			table.add_column(column)

		for r: Dictionary in t.records:
			var record: AbstractRecord = DatabaseFactory.create_record(r.id, table)
			table.add_record(record)

			for key: StringName in r:
				record.set_value(key, r[key])

		database.add_table(table)

	return database


static func _database_load_cfg(path: String) -> AbstractDatabase:
	var config := ConfigFile.new()
	if config.load(path):
		return null

	var data: Variant = config.get_value("", "database", null)
	if data is Dictionary:
		return _deserialize_database(data)

	return null


static func _database_load_json(path: String) -> AbstractDatabase:
	var file_as_string: String = FileAccess.get_file_as_string(path)
	if file_as_string.is_empty():
		return null

	var data: Variant = JSON.parse_string(file_as_string)
	if data is Dictionary:
		return _deserialize_database(data)

	return null
