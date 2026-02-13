# Copyright (c) 2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

## Abstract base class representing a row of data in a database table.
##
## This abstract class defines the interface for row implementations that
## store and manage data values for a specific schema. Rows contain
## column-value pairs that represent individual records within a table,
## with validation and access methods to ensure data integrity.

@abstract
class_name AbstractRow
extends RefCounted

## Retrieves the value of a column by its name.
## Returns the value associated with the given column name, or Variant() if the column does not exist.
@abstract func get_value(column_name: StringName) -> Variant

## Sets the value of a column by its name.
## Returns true if the value was successfully set, false if the column does not exist or the value is invalid.
@abstract func set_value(column_name: StringName, value: Variant) -> bool

## Checks if a column with the given name exists in the row.
## Returns true if the column exists, false otherwise.
@abstract func has_column(column_name: StringName) -> bool

## Returns an array of all column names present in the row.
@abstract func get_column_names() -> Array[StringName]

## Validates the integrity of the row data.
## Returns true if all values are valid and consistent with the row's constraints, false otherwise.
@abstract func validate() -> bool
