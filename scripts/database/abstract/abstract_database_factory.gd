# Copyright (c) 2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

## Abstract base class for database object factory implementations.
##
## This abstract class defines the interface for creating database components
## such as schemas, tables, columns, rows, and data types. It provides a
## standardized way to instantiate database objects, allowing for flexible
## implementation of different database backends or storage mechanisms.

@abstract
class_name AbstractDatabaseFactory
extends RefCounted

## Creates a new AbstractSchema instance.
@abstract func create_schema() -> AbstractSchema

## Creates a new AbstractDatabase instance.
@abstract func create_database(name: StringName) -> AbstractDatabase

## Creates a new AbstractColumn instance with the specified properties.
@abstract func create_column(name: StringName, data_type: AbstractDataType) -> AbstractColumn

## Creates a new AbstractRow instance.
@abstract func create_row(schema: AbstractSchema) -> AbstractRow

## Creates a new AbstractDataType instance of the specified type.
@abstract func create_data_type(type: Variant.Type) -> AbstractDataType

## Creates a new table and adds it to the database.
@abstract func create_table(name: StringName, schema: AbstractSchema) -> AbstractTable
