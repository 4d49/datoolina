# Copyright (c) 2024 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends RefCounted


const DictionaryDB: GDScript = preload("res://scripts/dictionary_database.gd")


static var _format_handlers: Array[Dictionary] = []


static func _static_init() -> void:
	add_format_loader("cfg", "Config File", _database_load_cfg)


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


static func load_database(path: String) -> Dictionary[StringName, Variant]:
	for format: Dictionary in _format_handlers:
		if not format.handler.call(path):
			continue

		return format.file_loader.call(path)

	return DictionaryDB.NULL_DATABASE




static func _database_load_cfg(path: String) -> Dictionary[StringName, Variant]:
	var config := ConfigFile.new()
	if config.load(path):
		return DictionaryDB.NULL_DATABASE

	var data: Dictionary = config.get_value("", "database", DictionaryDB.NULL_DATABASE)

	var database: Dictionary[StringName, Variant] = DictionaryDB.create_database(data.id)

	for t: Dictionary in data.tables:
		var table: Dictionary[StringName, Variant] = DictionaryDB.database_create_table(database, t.id)

		for c: Dictionary in t.columns:
			var column: Dictionary[StringName, Variant] = DictionaryDB.table_create_column(table, c.id, c.type, c.value, c.hint, c.hint_string)

		for r: Dictionary in t.records:
			var record: Dictionary[StringName, Variant] = DictionaryDB.table_create_record(table, r.id)
			# HACK: In the future, it should be removed.
			for key: StringName in r:
				record[key] = r[key]

	return database
