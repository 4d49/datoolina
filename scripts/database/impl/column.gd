# Copyright (c) 2024-2026 Mansur Isaev and contributors - MIT License

# Concrete implementation of a database column.
# Stores column metadata including name, data type, default value, and constraints.

extends AbstractColumn


var _name: StringName = &""
var _description: String = ""

var _data_type: AbstractDataType = null
var _default_value: Variant = null


func _init(name: StringName, data_type: AbstractDataType) -> void:
	_name = name
	_data_type = data_type
	_default_value = data_type.get_default()


func set_name(name: StringName) -> void:
	_name = name

func get_name() -> StringName:
	return _name


func set_description(description: String) -> void:
	_description = description

func get_description() -> String:
	return _description


func set_data_type(data_type: AbstractDataType) -> void:
	assert(is_instance_valid(data_type), "Data type must be a valid instance")

	_data_type = data_type
	_default_value = data_type.get_default()

func get_data_type() -> AbstractDataType:
	return _data_type


func validate(value: Variant) -> bool:
	return _data_type.validate(value)


func get_default() -> Variant:
	return _default_value


func set_default(default_value: Variant) -> void:
	assert(_data_type.validate(default_value), "Default value does not conform to the column's data type")
	_default_value = default_value


func get_built_in_type() -> Variant.Type:
	return _data_type.get_built_in_type()


func clear() -> void:
	_data_type = null
	_default_value = null
