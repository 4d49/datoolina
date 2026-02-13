# Copyright (c) 2026 Mansur Isaev and contributors - MIT License
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

## Returns the column's name (e.g., "name", "age")
@abstract func get_name() -> StringName

## Returns the data type of this column (e.g., BoolDataType, StringDataType)
@abstract func get_data_type() -> AbstractDataType

## Validates a value against this column's data type and constraints
@abstract func validate(value: Variant) -> bool

## Returns the default value for this column
@abstract func get_default() -> Variant

## Returns the built-in variant type (e.g., Variant.Type.STRING, Variant.Type.INT)
@abstract func get_built_in_type() -> Variant.Type

## Sets the description for this column.
@abstract func set_description(description: String) -> void

## Gets the description of this column.
@abstract func get_description() -> String
