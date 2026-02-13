# Copyright (c) 2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

## Abstract base class representing a database table.
##
## This abstract class defines the interface for table implementations that
## organize data into rows and columns. Tables contain schemas that define
## column structures, and provide methods to manage rows, including adding,
## removing, and retrieving data while maintaining schema integrity.

@abstract
class_name AbstractTable
extends RefCounted


## Sets the name of this table
@abstract func set_name(name: StringName) -> void
## Gets the name of this table
@abstract func get_name() -> StringName


## Sets the description for this table.
@abstract func set_description(description: String) -> void
## Gets the description of this table.
@abstract func get_description() -> String


## Returns the schema that defines the structure of this table.
## The schema specifies column names and their data types.
@abstract func get_schema() -> AbstractSchema

## Returns an array of all column names in the table's schema.
@abstract func get_column_names() -> Array[StringName]

## Checks if a column with the given name exists in the table's schema.
## Returns true if the column exists, false otherwise.
@abstract func has_column(name: StringName) -> bool

## Checks if the table has a primary key column.
## Returns true if a primary key column exists, false otherwise.
@abstract func has_primary_key_column() -> bool

## Returns the first primary key column
## Returns the AbstractColumn that is a primary key, or null if no primary key exists
@abstract func get_primary_key_column() -> AbstractColumn


## Checks if a row exists with the specified primary key value.
## Returns true if a row with the given primary key exists, false otherwise.
@abstract func has_row(primary_key: Variant) -> bool

## Adds a new row to the table.
## Validates the row against the table's schema before insertion.
## Returns true if the row was successfully added, false if validation failed or insertion failed.
@abstract func add_row(row: AbstractRow) -> bool

## Removes a row from the table.
## Returns true if the row was successfully removed, false if the row was not found.
@abstract func remove_row(row: AbstractRow) -> bool

## Retrieves a row by its index (0-based).
## Returns the row at the specified index, or null if the index is out of bounds.
@abstract func get_row(index: int) -> AbstractRow

## Retrieves a row by its primary key value.
## Returns the row with the specified primary key value, or null if not found.
@abstract func find_row(primary_key: Variant) -> AbstractRow

## Returns an array of all rows in the table.
## The returned array is NOT GUARANTEED to be modifiable.
@abstract func get_rows() -> Array[AbstractRow]

## Returns the total number of rows in the table.
@abstract func get_row_count() -> int
