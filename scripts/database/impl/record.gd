# Copyright (c) 2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends AbstractRecord


var _table: AbstractTable = null
var _values: Dictionary[StringName, Variant] = {}


func _init(table: AbstractTable) -> void:
	_table = table


func get_table() -> AbstractTable:
	return _table


func has_value(column_name: StringName) -> bool:
	return _values.has(column_name)


func insert_value(column_name: StringName, value: Variant) -> bool:
	return _values.set(column_name, value)


func set_value(column_name: StringName, value: Variant) -> bool:
	if _table.has_column(column_name):
		return _values.set(column_name, value)

	return false


func get_value(column_name: StringName) -> Variant:
	return _values.get(column_name)


func erase_value(column_name: StringName) -> bool:
	return _values.erase(column_name)


func validate() -> bool:
	# FIXME: Реализовать валидацию.
#	for column_name: StringName in _values:
#		if not _schema.has_column(column_name):
#			return false
#
#		var column = _schema.find_column(column_name)
#		if not is_instance_valid(column):
#			return false
#
#		var value: Variant = _values[column_name]
#		if not column.validate(value):
#			return false

	return true
