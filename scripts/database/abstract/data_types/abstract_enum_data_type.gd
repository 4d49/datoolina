# Copyright (c) 2024-2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

## Abstract base class representing a data type that functions as an enumeration.
##
## This class defines the contract for data types that consist of a fixed set
## of allowed values. Implementations of this class must provide a way to
## map human-readable names (keys) to their underlying data values.
##
## This is useful for creating dropdown menus in UIs and ensuring that
## data adheres to a predefined set of valid options.

@abstract
class_name AbstractEnumDataType
extends AbstractDataType


## Returns the complete mapping of the enumeration.
## The dictionary keys should be StringName (human-readable labels)
## and the values should be the actual data values (int, String, etc.).
@abstract func get_options() -> Dictionary[StringName, Variant]

## Returns an array of all human-readable names (keys) in the enumeration.
## This is primarily used for populating UI elements like Dropdown menus.
@abstract func get_enum_names() -> Array[StringName]


func get_type_hint() -> Hint:
	return Hint.ENUM
