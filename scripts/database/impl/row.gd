# Copyright (c) 2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends AbstractRow


# Dictionary storing column values
var _values: Dictionary[StringName, Variant] = {}
# Reference to the schema for validation
var _schema: AbstractSchema = null

# Constructor that initializes the row with a schema
func _init(schema: AbstractSchema) -> void:
	_schema = schema

# Gets the value of a column by its name
func get_value(column_name: StringName) -> Variant:
	return _values.get(column_name)

# Sets the value of a column by its name
# Returns true if the column exists in the schema and the value was set, false otherwise
func set_value(column_name: StringName, value: Variant) -> bool:
	# Check if column exists in schema
	if not _schema.has_column(column_name):
		return false
	# Set the value
	return _values.set(column_name, value)

# Checks if a column with the given name exists in the row
func has_column(column_name: StringName) -> bool:
	return _values.has(column_name)

# Returns an array of all column names present in the row
func get_column_names() -> Array[StringName]:
	return _values.keys()

# Validates the integrity of the row data against the schema
func validate() -> bool:
	var column_names = get_column_names()
	for column_name in column_names:
		if not _schema.has_column(column_name):
			return false

		var column = _schema.get_column(column_name)
		if column == null:
			return false

		var value = _values[column_name]
		if not column.validate(value):
			return false

	return true
