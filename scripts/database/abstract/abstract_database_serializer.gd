# Copyright (c) 2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

@abstract
class_name AbstractDatabaseSerializer
extends RefCounted

## Serialize the entire database to a file
@abstract func serialize_database(database: AbstractDatabase, path: String, options: Dictionary = {}) -> Error

## Serialize a table to a file
@abstract func serialize_table(table: AbstractTable, path: String, options: Dictionary = {}) -> Error

## Serialize a row to a file
@abstract func serialize_row(row: AbstractRow, path: String, options: Dictionary = {}) -> Error

## Serialize the database schema to a file
@abstract func serialize_schema(schema: AbstractSchema, path: String, options: Dictionary = {}) -> Error

## Serialize a data type to a file
@abstract func serialize_data_type(data_type: AbstractDataType, path: String, options: Dictionary = {}) -> Error
