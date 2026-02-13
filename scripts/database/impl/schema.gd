# Copyright (c) 2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

# Concrete implementation of a database schema.
# Stores column definitions with their data types and provides schema validation.

extends AbstractSchema


var _columns: Array[AbstractColumn] = []
var _column_map: Dictionary[StringName, AbstractColumn] = {}

# Reference to the primary key column
var _primary_key: AbstractColumn = null
# Schema description
var _description: String = ""


func add_column(column: AbstractColumn) -> bool:
	# Check if column with this name already exists
	var name: StringName = column.get_name()
	if has_column(name):
		return false

	if _column_map.set(name, column) and _columns:
		_columns = []

	# Check if this column should be the primary key (if no primary key exists yet)
	# Note: The primary key flag is managed at the schema level, not within the column itself
	if not is_instance_valid(_primary_key):
		# This is a simplified approach - in a real implementation,
		# we might need to track this information differently
		_primary_key = column

	return true


func remove_column(name: StringName) -> bool:
	# Check if column exists
	if not has_column(name):
		return false

	# Get the column to check if it was a primary key
	if _column_map.erase(name) and _columns:
		_columns = []

	return true


func get_column(index: int) -> AbstractColumn:
	return _columns.get(index)


func find_column(name: StringName) -> AbstractColumn:
	return _column_map.get(name)


func get_columns() -> Array[AbstractColumn]:
	if _columns.is_empty():
		_columns = _column_map.values()
		_columns.make_read_only()

	return _columns


func get_column_names() -> Array[StringName]:
	return _column_map.keys()


func has_column(name: StringName) -> bool:
	return _column_map.has(name)


func validate_row(row: AbstractRow) -> bool:
	for column_name: StringName in _column_map:
		if row.has_value(column_name):
			continue

		var defualt_value: Variant = _column_map[column_name].get_default()
		row.insert_value(column_name, defualt_value)

	return true


func get_column_count() -> int:
	return _columns.size()


func has_primary_key() -> bool:
	return is_instance_valid(_primary_key)


func get_primary_key() -> AbstractColumn:
	return _primary_key


func set_description(description: String) -> void:
	_description = description


func get_description() -> String:
	return _description
