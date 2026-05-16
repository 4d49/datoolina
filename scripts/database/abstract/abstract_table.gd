# Copyright (c) 2024-2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

## Abstract base class representing a database table.
##
## This abstract class defines the interface for table implementations that
## organize data into records and columns. Tables contain schemas that define
## column structures, and provide methods to manage records, including adding,
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

## Erases a column from the table's schema by name.
## Returns true if the column was successfully erased, false if it didn't exist.
@abstract func erase_column(column_name: StringName) -> bool

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

## Validates a record against the table's schema constraints.
## Returns true if the record contains valid data according to the schema (e.g., correct types, required fields), false otherwise.
@abstract func validate_record(record: AbstractRecord) -> bool

## Checks if a record exists with the specified primary key value.
## Returns true if a record with the given primary key exists, false otherwise.
@abstract func has_record(primary_key: Variant) -> bool

## Adds a new record to the table.
## Validates the record against the table's schema before insertion.
## Returns true if the record was successfully added, false if validation failed or insertion failed.
@abstract func add_record(record: AbstractRecord) -> bool

## Removes a record from the table.
## Returns true if the record was successfully removed, false if the record was not found.
@abstract func remove_record(record: AbstractRecord) -> bool

## Erases a record from the table by its primary key.
## Returns true if the record was successfully erased, false if the record was not found.
@abstract func erase_record(primary_key: Variant) -> bool

## Retrieves a record by its primary key value.
## Returns the record with the specified primary key value, or null if not found.
@abstract func find_record(primary_key: Variant) -> AbstractRecord

## Retrieves a record by its index (0-based).
## Returns the record at the specified index, or null if the index is out of bounds.
@abstract func get_record(index: int) -> AbstractRecord

## Returns the total number of records in the table.
@abstract func get_record_count() -> int

## Returns an array of all records in the table.
## The returned array is NOT GUARANTEED to be modifiable.
@abstract func get_records() -> Array[AbstractRecord]

## Clears all data and internal structures of this table.
## This method provides a way to reset the table state, clearing all columns
## and their associated records. It serves as a cleanup mechanism that allows for
## guaranteed memory deallocation in concrete implementations.
## The behavior is similar to the built-in `free` method, but with the guarantee
## that internal structures will be properly cleared and memory will be released
## in concrete implementations after this method is called.
@abstract func clear() -> void




## Checks if a column can be renamed from the old name to the new name.
## Returns true if the old column exists and the new name is not already taken.
func can_rename_column(old_name: StringName, new_name: StringName) -> bool:
	return has_column(old_name) and not has_column(new_name)

## Renames a column in the table schema and updates all existing records.
## This operation migrates data from the old column name to the new one in every record.
## Throws an assertion error if the rename is invalid.
func rename_column(old_name: StringName, new_name: StringName) -> void:
	var column: AbstractColumn = find_column(old_name)
	assert(is_instance_valid(column), "Column `%s` not found!" % old_name)
	assert(not has_column(new_name), "Column `%s` already exists!" % new_name)

	column.set_name(new_name)

	for record: AbstractRecord in get_records():
		var value: Variant = record.get_value(old_name)
		record.erase_value(old_name)
		record.insert_value(new_name, value)
