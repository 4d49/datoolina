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




## Checks if a column with the given name exists in the table's schema.
## Returns true if the column exists, false otherwise.
@abstract func has_column(column_name: StringName) -> bool

## Adds a new column to the table's schema.
## Returns true if the column was successfully added, false if a column with that name already exists.
@abstract func add_column(column: AbstractColumn) -> bool

## Removes a column from the table's schema.
## Returns true if the column was successfully removed, false if it didn't exist.
@abstract func remove_column(column: AbstractColumn) -> bool

## Returns the total number of columns in the table's schema.
@abstract func get_column_count() -> int

## Returns an array of all column names in the table's schema.
@abstract func get_column_names() -> Array[StringName]

## Returns a column by its index (0-based).
## Returns the column at the specified index, or null if the index is out of bounds.
@abstract func get_column(index: int) -> AbstractColumn

## Finds a column by its name.
## Returns the AbstractColumn with the specified name, or null if not found.
@abstract func find_column(column_name: StringName) -> AbstractColumn

## Returns an array of all columns defined in the table's schema.
## The returned array is NOT GUARANTEED to be modifiable.
@abstract func get_columns() -> Array[AbstractColumn]




## Checks if the table has a primary key defined.
## Returns true if a primary key is defined, false otherwise.
@abstract func has_primary_key() -> bool

## Retrieves the primary key column from the table's schema.
## Returns the AbstractColumn representing the primary key, or null if no primary key is defined.
@abstract func get_primary_key() -> AbstractColumn

## Checks if the table has a primary key column.
## Returns true if a primary key column exists, false otherwise.
@abstract func has_primary_key_column() -> bool

## Returns the first primary key column.
## Returns the AbstractColumn that is a primary key, or null if no primary key exists.
@abstract func get_primary_key_column() -> AbstractColumn




## Validates a row against the table's schema constraints.
## Returns true if the row contains valid data according to the schema (e.g., correct types, required fields), false otherwise.
@abstract func validate_row(row: AbstractRow) -> bool





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

## Retrieves a row by its primary key value.
## Returns the row with the specified primary key value, or null if not found.
@abstract func find_row(primary_key: Variant) -> AbstractRow

## Retrieves a row by its index (0-based).
## Returns the row at the specified index, or null if the index is out of bounds.
@abstract func get_row(index: int) -> AbstractRow

## Returns the total number of rows in the table.
@abstract func get_row_count() -> int

## Returns an array of all rows in the table.
## The returned array is NOT GUARANTEED to be modifiable.
@abstract func get_rows() -> Array[AbstractRow]
