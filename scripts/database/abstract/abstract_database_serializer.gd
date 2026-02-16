# Copyright (c) 2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

@abstract
class_name AbstractDatabaseSerializer
extends RefCounted

## Serialize the entire database to a file
@abstract func serialize_database(database: AbstractDatabase, path: String, options: Dictionary = {}) -> Error
