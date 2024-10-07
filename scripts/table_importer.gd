# Copyright (c) 2024 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends RefCounted


const DictionaryDB: GDScript = preload("res://scripts/dictionary_database.gd")


static var _formats: Array[Dictionary] = []


static func _static_init() -> void:
	add_format_importer("cfg", "Config File", _table_import_cfg)
	add_format_importer("json", "JSON File", _table_import_json)


static func default_handler(extension: String) -> Callable:
	return func(path: String) -> bool:
		return path.get_extension() == extension

static func add_format_importer(extension: String, name: String, importer: Callable, handler: Callable = default_handler(extension)) -> void:
	if not importer.is_valid() or not handler.is_valid():
		return

	var format: Dictionary[StringName, Variant] = {
		&"name": name,
		&"handler": handler,
		&"importer": importer,
		&"extension": extension,
	}
	_formats.push_back(format)


static func get_support_file_extension() -> PackedStringArray:
	var support_extension := PackedStringArray()

	for i: int in _formats.size():
		var format: Dictionary = _formats[i]
		if not format.importer.is_valid():
			continue

		if format.name.is_empty():
			support_extension.push_back("*." + format.extension)
		else:
			support_extension.push_back("*." + format.extension + ";" + format.name)

	return support_extension


static func import_table(path: String) -> Dictionary[StringName, Variant]:
	for format: Dictionary in _formats:
		if not format.handler.call(path):
			continue

		return format.importer.call(path)

	return DictionaryDB.NULL_TABLE




static func deserialize_dictionary_table(data: Dictionary) -> Dictionary[StringName, Variant]:
	var table: Dictionary[StringName, Variant] = DictionaryDB.create_table(data.id)

	for c: Dictionary in data.columns:
		var column: Dictionary[StringName, Variant] = DictionaryDB.table_create_column(table, c.id, c.type, c.value, c.hint, c.hint_string)

	for r: Dictionary in data.records:
		var record: Dictionary[StringName, Variant] = DictionaryDB.table_create_record(table, r.id)
		# HACK: In the future, it should be removed.
		for key: StringName in r:
			record[key] = r[key]

	return table


static func _table_import_cfg(path: String) -> Dictionary[StringName, Variant]:
	var config := ConfigFile.new()

	var error: Error = config.load(path)
	if error:
		printerr(error_string(error))
		return DictionaryDB.NULL_TABLE

	var data: Dictionary = config.get_value("", "table", DictionaryDB.NULL_TABLE)
	return deserialize_dictionary_table(data)


static func _table_import_json(path: String) -> Dictionary[StringName, Variant]:
	var file_as_string: String = FileAccess.get_file_as_string(path)
	if file_as_string.is_empty():
		return DictionaryDB.NULL_DATABASE

	var json := JSON.new()

	var data: Variant = json.parse_string(file_as_string)
	if data == null:
		return DictionaryDB.NULL_DATABASE

	return deserialize_dictionary_table(data)
