# Copyright (c) 2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

## Abstract base class for deserializing database objects from files.
##
## This abstract class defines the interface for implementing deserialization
## functionality that can reconstruct database components (tables, records, schemas,
## data types) from persisted data formats. Implementations should handle
## loading and parsing of serialized data into their respective object instances.

@abstract
class_name AbstractDatabaseDeserializer
extends RefCounted

## Reconstructs a database object from a file
@abstract func deserialize_database(path: String, options: Dictionary = {}) -> AbstractDatabase
