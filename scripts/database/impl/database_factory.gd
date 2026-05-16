# Copyright (c) 2024-2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

# Concrete implementation of the DatabaseFactory interface.
# This follows the Factory Pattern for better dependency management and testability.

extends AbstractDatabaseFactory


# Preload all concrete implementations
const Column: GDScript = preload("column.gd")
const Database: GDScript = preload("database.gd")
const Record: GDScript = preload("record.gd")
const Table: GDScript = preload("table.gd")


func create_database(name: StringName) -> AbstractDatabase:
	return Database.new(name)


func create_column(name: StringName, data_type: AbstractDataType) -> AbstractColumn:
	return Column.new(name, data_type)


func create_record(table: AbstractTable) -> AbstractRecord:
	return Record.new(table)


func create_data_type(type: StringName, config: Dictionary) -> AbstractDataType:
	return DataTypeRegistry.create(type, config)


func create_table(name: StringName) -> AbstractTable:
	return Table.new(name)
