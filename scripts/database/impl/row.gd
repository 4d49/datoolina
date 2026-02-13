# Copyright (c) 2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends AbstractRow


var _schema: AbstractSchema = null
var _values: Dictionary[StringName, Variant] = {}


func _init(schema: AbstractSchema) -> void:
	_schema = schema


func get_schema() -> AbstractSchema:
	return _schema


func has_value(column_name: StringName) -> bool:
	return _values.has(column_name)


func insert_value(column_name: StringName, value: Variant) -> bool:
	return _values.set(column_name, value)


func set_value(column_name: StringName, value: Variant) -> bool:
	if not _schema.has_column(column_name):
		return false

	return _values.set(column_name, value)


func get_value(column_name: StringName) -> Variant:
	return _values.get(column_name)


func erase_value(column_name: StringName) -> bool:
	return _values.erase(column_name)


func validate() -> bool:
	for column_name: StringName in _values:
		if not _schema.has_column(column_name):
			return false

		var column = _schema.find_column(column_name)
		if not is_instance_valid(column):
			return false

		var value: Variant = _values[column_name]
		if not column.validate(value):
			return false

	return true
