# Copyright (c) 2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

# Concrete implementation of a database table.
# Stores column definitions and provides schema validation.

extends AbstractTable


var _name: StringName = &""
var _description: String = ""

var _columns: Array[AbstractColumn] = []
var _column_map: Dictionary[StringName, AbstractColumn] = {}

var _records: Array[AbstractRecord] = []
var _record_map: Dictionary[StringName, AbstractRecord] = {}


func _init(name: StringName) -> void:
	_name = name


func set_name(name: StringName) -> void:
	_name = name

func get_name() -> StringName:
	return _name


func set_description(description: String) -> void:
	_description = description

func get_description() -> String:
	return _description




func has_column(column_name: StringName) -> bool:
	return _column_map.has(column_name)


func add_column(column: AbstractColumn) -> bool:
	if not is_instance_valid(column):
		return false

	# Check if column with this name already exists
	var name: StringName = column.get_name()
	if has_column(name):
		return false

	# Add the column to internal storage
	if _column_map.set(name, column) and _columns:
		_columns = []

	return true


func remove_column(column: AbstractColumn) -> bool:
	if not is_instance_valid(column):
		return false

	if not is_same(column, find_column(column.get_name())):
		return false

	# Get the column to check if it was a primary key
	if _column_map.erase(column.get_name()) and _columns:
		_columns = []

	return true


func get_column_count() -> int:
	return _columns.size()


func get_column_names() -> Array[StringName]:
	return _column_map.keys()


func get_column(index: int) -> AbstractColumn:
	return _columns.get(index)


func find_column(column_name: StringName) -> AbstractColumn:
	return _column_map.get(column_name)


func get_columns() -> Array[AbstractColumn]:
	if _columns.is_empty():
		_columns = _column_map.values()
		_columns.make_read_only()

	return _columns


func validate_record(record: AbstractRecord) -> bool:
	for column_name: StringName in _column_map:
		if record.has_value(column_name):
			continue

		var defualt_value: Variant = _column_map[column_name].get_default()
		record.insert_value(column_name, defualt_value)

	return true


func has_record(primary_key: Variant) -> bool:
	return _record_map.has(primary_key)


func add_record(record: AbstractRecord) -> bool:
	if not validate_record(record):
		return false

	# Check if a record with this primary key already exists
	if _record_map.has(record.get_id()):
		return false

	# Add the record to the table using primary key as key
	if _record_map.set(record.get_id(), record) and _records:
		_records = []  # Clear the array to be repopulated on next access

	return true


func remove_record(record: AbstractRecord) -> bool:
	if not is_instance_valid(record):
		return false

	# Remove the record from the table using primary key as key
	if _record_map.erase(record.get_id()) and _records:
		_records = []  # Clear the array to be repopulated on next access

	return true


func find_record(record_id: Variant) -> AbstractRecord:
	return _record_map.get(record_id, null)


func get_record(record_idx: int) -> AbstractRecord:
	return get_records().get(record_idx)


func get_record_count() -> int:
	return _record_map.size()


func get_records() -> Array[AbstractRecord]:
	if _records.is_empty():
		_records = _record_map.values()
		_records.make_read_only()

	return _records
