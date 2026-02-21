# Copyright (c) 2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends AbstractDatabaseSerializer


func get_name() -> String:
	return "JSON"


func get_extension() -> String:
	return "json"


func get_description() -> String:
	return "Serializes database to JSON format"


func _serialize_column(column: AbstractColumn) -> Dictionary:
	return {
		"id": column.get_name(),
		"type": column.get_built_in_type(),
		"value": column.get_default(),
		"description": column.get_description()
	}


func _serialize_columns(columns: Array[AbstractColumn]) -> Array:
	var serialized: Array = []
	serialized.resize(columns.size())

	for i in columns.size():
		serialized[i] = _serialize_column(columns[i])

	return serialized


func _serialize_record(record: AbstractRecord) -> Dictionary:
	var serialized: Dictionary = {}

	for key in record.get_keys():
		serialized[key] = record.get_value(key)

	return serialized


func _serialize_records(records: Array[AbstractRecord]) -> Array:
	var serialized: Array = []
	serialized.resize(records.size())

	for i in records.size():
		serialized[i] = _serialize_record(records[i])

	return serialized


func _serialize_table(table: AbstractTable) -> Dictionary:
	return {
		"id": table.get_name(),
		"columns": _serialize_columns(table.get_columns()),
		"records": _serialize_records(table.get_records()),
		"description": table.get_description()
	}


func _serialize_tables(tables: Array[AbstractTable]) -> Array:
	var serialized: Array = []
	serialized.resize(tables.size())

	for i in tables.size():
		serialized[i] = _serialize_table(tables[i])

	return serialized


func _serialize_database(database: AbstractDatabase) -> Dictionary:
	return {
		"id": database.get_name(),
		"tables": _serialize_tables(database.get_tables()),
		"description": database.get_description()
	}


func _deserialize_database(data: Dictionary) -> AbstractDatabase:
	var database: AbstractDatabase = DatabaseFactory.create_database(data.id)
	database.set_description(data.description)

	for table_data in data.tables:
		var table: AbstractTable = DatabaseFactory.create_table(table_data.id)
		table.set_description(table_data.description)

		for column_data in table_data.columns:
			var column: AbstractColumn = DatabaseFactory.create_column(column_data.id, DatabaseFactory.create_data_type(column_data.type))
			column.set_default(column_data.value)
			column.set_description(column_data.description)

			table.add_column(column)

		for record_data in table_data.records:
			var record: AbstractRecord = DatabaseFactory.create_record(record_data.id, table)
			for key in record_data:
				record.set_value(key, record_data[key])

			table.add_record(record)

		database.add_table(table)

	return database


func save(database: AbstractDatabase, path: String) -> Error:
	if not is_instance_valid(database):
		return FAILED

	if path.get_extension() != get_extension():
		return ERR_INVALID_PARAMETER

	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if not is_instance_valid(file):
		return FileAccess.get_open_error()

	file.store_string(JSON.stringify(_serialize_database(database), "\t", false))
	file.close()

	return OK


func load(path: String) -> AbstractDatabase:
	if path.get_extension() != get_extension():
		return null

	var string: String = FileAccess.get_file_as_string(path)
	if string.is_empty():
		return null

	return _deserialize_database(JSON.parse_string(string))
