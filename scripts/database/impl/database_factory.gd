# Copyright (c) 2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

# Concrete implementation of the DatabaseFactory interface.
# This follows the Factory Pattern for better dependency management and testability.

extends AbstractDatabaseFactory


# Preload all concrete implementations
const Column: GDScript = preload("column.gd")
const Database: GDScript = preload("database.gd")
const Row: GDScript = preload("row.gd")
const Table: GDScript = preload("table.gd")


func create_database(name: StringName) -> AbstractDatabase:
	return Database.new(name)


func create_column(name: StringName, data_type: AbstractDataType) -> AbstractColumn:
	return Column.new(name, data_type)


func create_row(table: AbstractTable) -> AbstractRow:
	return Row.new(table)


func create_data_type(type: Variant.Type) -> AbstractDataType:
	const BoolType: GDScript = preload("data_types/bool_data_type.gd")
	const FloatType: GDScript = preload("data_types/float_data_type.gd")
	const IntType: GDScript = preload("data_types/int_data_type.gd")
	const StringType: GDScript = preload("data_types/string_data_type.gd")

	var data_type: AbstractDataType = null

	match type:
		TYPE_BOOL:
			data_type = BoolType.new()
		TYPE_INT:
			data_type = IntType.new()
		TYPE_FLOAT:
			data_type = FloatType.new()
		TYPE_STRING:
			data_type = StringType.new()
		_:
			push_error("%s type is not supported!" % type_string(type))

	return data_type


func create_table(name: StringName) -> AbstractTable:
	return Table.new(name)
