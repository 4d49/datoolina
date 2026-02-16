# Copyright (c) 2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

## Abstract base class representing a database container.
##
## This abstract class defines the interface for database implementations,
## providing methods to manage tables, schemas, and overall database structure.
## It serves as the central hub for organizing and accessing database objects.

@abstract
class_name AbstractDatabase
extends RefCounted

## Sets the name for this database.
## The name is used to identify the database instance.
@abstract func set_name(name: StringName) -> void
## Gets the name of this database.
@abstract func get_name() -> StringName

## Sets the description for this database.
@abstract func set_description(description: String) -> void
## Gets the description of this database.
@abstract func get_description() -> String

## Adds a new table to the database.
## Returns true if the table was successfully added, false if a table with that name already exists.
@abstract func add_table(table: AbstractTable) -> bool

## Returns a table by its index in the internal array.
## Returns the table if it exists, or null if the index is out of bounds.
@abstract func get_table(index: int) -> AbstractTable

## Retrieves a table by its name.
## Returns the table if it exists, or null if not found.
@abstract func find_table(name: StringName) -> AbstractTable

## Checks if a table with the given name exists.
## Returns true if the table exists, false otherwise.
@abstract func has_table(name: StringName) -> bool

## Removes a table by its name.
## Returns true if the table was successfully removed, false if it didn't exist.
@abstract func remove_table(name: StringName) -> bool

## Returns an array of all tables in the database.
## The returned array is not guaranteed to be modifiable.
@abstract func get_tables() -> Array[AbstractTable]

## Returns an array of all table names in the database.
@abstract func get_table_names() -> Array[StringName]
