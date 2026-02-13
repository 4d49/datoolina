# Copyright (c) 2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

# Concrete implementation of a database table.
# Stores schema and a collection of rows with validation.

extends AbstractTable


var _name: StringName = &""
var _description: String = ""

# Reference to the table's schema
var _schema: AbstractSchema = null

var _rows: Array[AbstractRow] = []
var _row_map: Dictionary[Variant, AbstractRow] = {}


func _init(name: StringName, schema: AbstractSchema) -> void:
	_name = name
	_schema = schema


func set_name(name: StringName) -> void:
	_name = name

func get_name() -> StringName:
	return _name


func set_description(description: String) -> void:
	_description = description

func get_description() -> String:
	return _description


func get_schema() -> AbstractSchema:
	return _schema


func get_column_names() -> Array[StringName]:
	return _schema.get_column_names()


func has_column(name: StringName) -> bool:
	return _schema.has_column(name)


func add_column(column: AbstractColumn) -> bool:
	if not is_instance_valid(column):
		return false

	# Check if column with this name already exists
	var name: StringName = column.get_name()
	if _schema.has_column(name):
		return false

	# Add the column to schema
	if not _schema.add_column(column):
		return false

	# Update all existing rows with default value for new column
	var default_value = column.get_default()
	for row: AbstractRow in _rows:
		row.insert_value(name, default_value)

	return true


func remove_column(column_name: StringName) -> bool:
	if not _schema.has_column(column_name):
		return false

	# Remove the column from schema
	if not _schema.remove_column(column_name):
		return false

	# Remove values for this column from all existing rows
	for row: AbstractRow in _rows:
		row.erase_value(column_name)

	return true


func rename_column(old_name: StringName, new_name: StringName) -> bool:
	# Validate that old column exists and new name is not taken
	if not _schema.has_column(old_name) or _schema.has_column(new_name):
		return false

	var column: AbstractColumn = _schema.find_column(old_name)
	column.set_name(new_name)

	_schema.remove_column(old_name)
	_schema.add_column(column)

	# Update all existing rows to use the new column name
	for row: AbstractRow in _rows:
		var value: Variant = row.get_value(old_name)
		row.erase_value(old_name)
		row.insert_value(new_name, value)

	return true


func has_primary_key_column() -> bool:
	return _schema.has_primary_key()


func get_primary_key_column() -> AbstractColumn:
	return _schema.get_primary_key()


func add_row(row: AbstractRow) -> bool:
	if not _schema.validate_row(row):
		return false

	# Get the primary key column
	var primary_key_column = _schema.get_primary_key()
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
	var primary_key_column = _schema.get_primary_key()
	if not is_instance_valid(primary_key_column):
		# If no primary key, can't remove by primary key
		return false

	# Get the primary key value from the row
	var primary_key_value = row.get_value(primary_key_column.get_name())

	# Remove the row from the table using primary key as key
	if _row_map.erase(primary_key_value) and _rows:
		_rows = []  # Clear the array to be repopulated on next access

	return true


func get_row(index: int) -> AbstractRow:
	return get_rows().get(index)


func find_row(primary_key: Variant) -> AbstractRow:
	return _row_map.get(primary_key, null)


func has_row(primary_key: Variant) -> bool:
	return _row_map.has(primary_key)


func get_rows() -> Array[AbstractRow]:
	if _rows.is_empty():
		_rows = _row_map.values()
		_rows.make_read_only()

	return _rows


func get_row_count() -> int:
	return _row_map.size()
