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

## Gets the schema associated with this row.
## Returns the schema that defines the structure of this row.
@abstract func get_schema() -> AbstractSchema

## Sets the value of a column by its name.
## Returns true if the value was successfully set, false if the column does not exist or the value is invalid.
@abstract func set_value(column_name: StringName, value: Variant) -> bool

## Retrieves the value of a column by its name.
## Returns the value associated with the given column name, or Variant() if the column does not exist.
@abstract func get_value(column_name: StringName) -> Variant

## Validates the integrity of the row data.
## Returns true if all values are valid and consistent with the row's constraints, false otherwise.
## This method uses the schema to validate against column constraints.
@abstract func validate() -> bool
