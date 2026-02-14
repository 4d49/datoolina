# Copyright (c) 2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

## Abstract base class representing a record of data in a database table.
##
## This abstract class defines the interface for record implementations that
## store and manage data values for a specific schema. Records contain
## column-value pairs that represent individual records within a table,
## with validation and access methods to ensure data integrity.

@abstract
class_name AbstractRecord
extends RefCounted


## Returns the table associated with this record.
@abstract func get_table() -> AbstractTable

## Checks if a column has a value set.
## Returns true if the column has a value, false otherwise.
@abstract func has_value(column_name: StringName) -> bool

## Inserts a new value for a column.
## Returns true if the value was successfully inserted, false if the column does not exist.
@abstract func insert_value(column_name: StringName, value: Variant) -> bool

## Sets the value of a column by its name.
## Returns true if the value was successfully set, false if the column does not exist or the value is invalid.
@abstract func set_value(column_name: StringName, value: Variant) -> bool

## Retrieves the value of a column by its name.
## Returns the value associated with the given column name, or Variant() if the column does not exist.
@abstract func get_value(column_name: StringName) -> Variant

## Erases a value for a column.
## Returns true if the value was successfully erased, false if the column does not exist.
@abstract func erase_value(column_name: StringName) -> bool

## Validates the integrity of the record data.
## Returns true if all values are valid and consistent with the record's constraints, false otherwise.
## This method uses the schema to validate against column constraints.
@abstract func validate() -> bool
