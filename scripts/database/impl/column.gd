# Copyright (c) 2026 Mansur Isaev and contributors - MIT License

# Concrete implementation of a database column.
# Stores column metadata including name, data type, default value, and constraints.

extends AbstractColumn


# The name of this column
var _name: StringName = &""
# The data type definition for this column
var _data_type: AbstractDataType = null
# The default value for this column (can be null if no default is set)
var _default_value: Variant = null
# Column description
var _description: String = ""


func _init(name: StringName, data_type: AbstractDataType) -> void:
	_name = name
	_data_type = data_type
	_default_value = data_type.get_default()


func set_name(name: StringName) -> void:
	_name = name

func get_name() -> StringName:
	return _name


func get_data_type() -> AbstractDataType:
	return _data_type


func validate(value: Variant) -> bool:
	return _data_type.validate(value)


func get_default() -> Variant:
	return _default_value


func get_built_in_type() -> Variant.Type:
	return _data_type.get_built_in_type()


func set_description(description: String) -> void:
	_description = description

func get_description() -> String:
	return _description
