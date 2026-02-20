# Copyright (c) 2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

## Abstract base class for database serialization implementations.
##
## This abstract class defines the interface for saving and loading database
## instances to/from various file formats. Implementations should provide
## concrete methods for serializing database structures and data to storage,
## as well as deserializing from stored formats back into database objects.
##
## Serialization is typically used for persisting databases to disk in formats
## like JSON or configuration files.

@abstract
class_name AbstractDatabaseSerializer
extends RefCounted


## Get the name of the serializer.
## Returns a human-readable name for this serializer.
@abstract func get_name() -> String

## Get the file extension for the serialized format.
## Returns the file extension (without the dot) that this serializer uses.
@abstract func get_extension() -> String

## Get the description of the serializer.
## Returns a human-readable description of what this serializer does.
@abstract func get_description() -> String

## Save the database to a file.
## Saves the given database to the specified file path.
## Returns an error code indicating success or failure of the operation.
@abstract func save(database: AbstractDatabase, path: String) -> Error

## Load a database from a file.
## Loads and deserializes a database from the specified file path.
## Returns the loaded database instance, or null if loading failed.
@abstract func load(path: String) -> AbstractDatabase
