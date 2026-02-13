# Copyright (c) 2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends AbstractDatabase


var _tables: Array[AbstractTable] = []
var _table_map: Dictionary[StringName, AbstractTable] = {}

var _name: StringName = &""
var _description: String = ""


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


func can_add_table(table: AbstractTable) -> bool:
	if not is_instance_valid(table):
		return false

	return not has_table(table.get_name())

func add_table(table: AbstractTable) -> bool:
	if not can_add_table(table):
		return false

	if _table_map.set(table.get_name(), table) and _tables:
		_tables = []

	return true


func get_table(name: StringName) -> AbstractTable:
	return _table_map.get(name)


func has_table(name: StringName) -> bool:
	return _table_map.has(name)


func remove_table(name: StringName) -> bool:
	if _table_map.erase(name) and _tables:
		_tables = []

	return true


func get_tables() -> Array[AbstractTable]:
	if _tables.is_empty():
		_tables = _table_map.values()
		_tables.make_read_only()

	return _tables


func get_table_names() -> Array[StringName]:
	return _table_map.keys()
