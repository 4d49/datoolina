# Copyright (c) 2024-2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

## Abstract base class defining the interface for data types in the database system.
##
## This abstract class specifies the contract that all concrete data type implementations
## must follow, ensuring consistent validation, default value handling, and type information
## across different column types in the schema.

@abstract
class_name AbstractDataType
extends RefCounted


enum Hint {
	NONE = PROPERTY_HINT_NONE,
	RANGE = PROPERTY_HINT_RANGE,
	ENUM = PROPERTY_HINT_ENUM,
}


## Validates if a given value conforms to the constraints of this data type.
## Returns true if the value is valid according to the type's rules (e.g., correct type, range, format), false otherwise.
## see get_default() for default value constraints
## see get_built_in_type() to check expected type
@abstract func validate(value: Variant) -> bool

## Sets the default value for this data type.
## Implementations should ideally validate the value using [method validate] before applying it.
@abstract func set_default(value: Variant) -> void

## Returns the default value for this data type.
## This is the value that should be used when no explicit value is provided.
@abstract func get_default() -> Variant

## Returns the built-in Godot type that this data type represents.
## For example, returns Variant.Type.INT for integer types, Variant.Type.STRING for strings, etc.
@abstract func get_built_in_type() -> Variant.Type

@abstract func get_type_hint() -> Hint

## Returns a human-readable name for this data type.
## This is useful for debugging, error messages, and user interfaces.
@abstract func get_type_name() -> StringName
