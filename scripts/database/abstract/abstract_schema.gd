# Copyright (c) 2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

## Abstract base class defining the structure and constraints of a database table.
##
## This abstract class specifies the schema interface that defines column
## structures, data types, and validation rules for database tables. It serves
## as the blueprint for table organization and ensures data consistency
## across all rows within a table.

@abstract
class_name AbstractSchema
extends RefCounted

## Adds a new column to the schema with the specified column definition.
## Returns true if the column was successfully added, false if the name already exists.
@abstract func add_column(column: AbstractColumn) -> bool

## Removes a column from the schema by its name.
## Returns true if the column was successfully removed, false if the column does not exist.
@abstract func remove_column(name: StringName) -> bool

## Retrieves a column from the schema by its index.
## Returns the AbstractColumn at the given column index, or null if the index is out of bounds.
@abstract func get_column(index: int) -> AbstractColumn

## Finds and returns a column from the schema by its name.
## Returns the AbstractColumn associated with the given column name, or null if the column does not exist.
@abstract func find_column(name: StringName) -> AbstractColumn

## Returns an array of all column names defined in the schema.
@abstract func get_column_names() -> Array[StringName]

## Returns an array of all columns defined in the schema.
@abstract func get_columns() -> Array[AbstractColumn]

## Checks if a column with the given name exists in the schema.
## Returns true if the column exists, false otherwise.
@abstract func has_column(name: StringName) -> bool

## Validates a row against the schema constraints.
## Returns true if the row contains valid data according to the schema (e.g., correct types, required fields), false otherwise.
@abstract func validate_row(row: AbstractRow) -> bool

## Checks if the schema has a primary key defined.
## Returns true if a primary key is defined, false otherwise.
@abstract func has_primary_key() -> bool

## Retrieves the primary key column from the schema.
## Returns the AbstractColumn representing the primary key, or null if no primary key is defined.
@abstract func get_primary_key() -> AbstractColumn


## Sets the description for this schema.
@abstract func set_description(description: String) -> void

## Gets the description of this schema.
@abstract func get_description() -> String


## Returns the total number of columns in the schema.
@abstract func get_column_count() -> int
