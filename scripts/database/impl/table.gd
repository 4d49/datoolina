# Copyright (c) 2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

# Concrete implementation of a database table.
# Stores column definitions and provides schema validation.

extends AbstractTable


var _name: StringName = &""
var _description: String = ""

var _columns: Array[AbstractColumn] = []
var _column_map: Dictionary[StringName, AbstractColumn] = {}

var _primary_key: AbstractColumn = null

var _rows: Array[AbstractRow] = []
var _row_map: Dictionary[Variant, AbstractRow] = {}


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

	# Check if this column should be the primary key (if no primary key exists yet)
	# Note: The primary key flag is managed at the schema level, not within the column itself
	if not is_instance_valid(_primary_key):
		# This is a simplified approach - in a real implementation,
		# we might need to track this information differently
		_primary_key = column

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




func has_primary_key() -> bool:
	return is_instance_valid(_primary_key)


func get_primary_key() -> AbstractColumn:
	return _primary_key


func has_primary_key_column() -> bool:
	return has_primary_key()


func get_primary_key_column() -> AbstractColumn:
	return get_primary_key()




func validate_row(row: AbstractRow) -> bool:
	for column_name: StringName in _column_map:
		if row.has_value(column_name):
			continue

		var defualt_value: Variant = _column_map[column_name].get_default()
		row.insert_value(column_name, defualt_value)

	return true




func has_row(primary_key: Variant) -> bool:
	return _row_map.has(primary_key)


func add_row(row: AbstractRow) -> bool:
	if not validate_row(row):
		return false

	# Get the primary key column
	var primary_key_column = get_primary_key()
	if not is_instance_valid(primary_key_column):
		return false

	# Get the primary key value from the row
	var primary_key_value = row.get_value(primary_key_column.get_name())

	# Check if a row with this primary key already exists
	if _row_map.has(primary_key_value):
		return false

	# Add the row to the table using primary key as key
	if _row_map.set(primary_key_value, row) and _rows:
		_rows = []  # Clear the array to be repopulated on next access

	return true


func remove_row(row: AbstractRow) -> bool:
	# Get the primary key column
	var primary_key_column = get_primary_key()
	if not is_instance_valid(primary_key_column):
		# If no primary key, can't remove by primary key
		return false

	# Get the primary key value from the row
	var primary_key_value = row.get_value(primary_key_column.get_name())

	# Remove the row from the table using primary key as key
	if _row_map.erase(primary_key_value) and _rows:
		_rows = []  # Clear the array to be repopulated on next access

	return true


func find_row(primary_key: Variant) -> AbstractRow:
	return _row_map.get(primary_key, null)


func get_row(index: int) -> AbstractRow:
	return get_rows().get(index)


func get_row_count() -> int:
	return _row_map.size()


func get_rows() -> Array[AbstractRow]:
	if _rows.is_empty():
		_rows = _row_map.values()
		_rows.make_read_only()

	return _rows
