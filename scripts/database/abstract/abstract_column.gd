# Copyright (c) 2024-2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

## Abstract base class representing a column in a database schema.
##
## Defines the structure and constraints for a single data field within a table.
## Each column has a name, data type, default value, and validation rules.
##
## This abstract class provides the interface for column implementations
## that define specific data types and validation behaviors.

@abstract
class_name AbstractColumn
extends RefCounted


## Sets the name for this column.
@abstract func set_name(name: StringName) -> void

## Returns the column's name (e.g., "name", "age")
@abstract func get_name() -> StringName


## Sets the description for this column.
@abstract func set_description(description: String) -> void

## Gets the description of this column.
@abstract func get_description() -> String


## Sets the data type for this column
@abstract func set_data_type(data_type: AbstractDataType) -> void

## Returns the data type of this column (e.g., BoolDataType, StringDataType)
@abstract func get_data_type() -> AbstractDataType


## Returns the built-in variant type (e.g., Variant.Type.STRING, Variant.Type.INT)
func get_built_in_type() -> Variant.Type:
	return get_data_type().get_built_in_type()

## Returns the string name of the column's data type.
func get_data_type_name() -> StringName:
	return get_data_type().get_type_name()

## Validates a value against this column's data type and constraints
@abstract func validate(value: Variant) -> bool


## Sets the default value for this column
@abstract func set_default(default_value: Variant) -> void

## Returns the default value for this column
@abstract func get_default() -> Variant


## Clears all data and internal structures of this column.
## This method provides a way to reset the column state, clearing all references
## to data type and default value. It serves as a cleanup mechanism that allows for
## guaranteed memory deallocation in concrete implementations.
## The behavior is similar to the built-in `free` method, but with the guarantee
## that internal structures will be properly cleared and memory will be released
## in concrete implementations after this method is called.
@abstract func clear() -> void
