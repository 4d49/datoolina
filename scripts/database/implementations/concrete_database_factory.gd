# Copyright (c) 2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

# Concrete implementation of the DatabaseFactory interface.
# This follows the Factory Pattern for better dependency management and testability.

extends AbstractDatabaseFactory


# Preload all concrete implementations
const ConcreteColumn: GDScript = preload("concrete_column.gd")
const ConcreteDatabase: GDScript = preload("concrete_database.gd")
const ConcreteRow: GDScript = preload("concrete_row.gd")
const ConcreteSchema: GDScript = preload("concrete_schema.gd")
const ConcreteTable: GDScript = preload("concrete_table.gd")


func create_schema() -> AbstractSchema:
	return ConcreteSchema.new()


func create_database(name: StringName) -> AbstractDatabase:
	return ConcreteDatabase.new(name)


func create_column(name: StringName, data_type: AbstractDataType) -> AbstractColumn:
	# Note: Primary key handling is managed at the schema level, not in the column itself
	return ConcreteColumn.new(name, data_type, null)


func create_row(schema: AbstractSchema) -> AbstractRow:
	return ConcreteRow.new(schema)


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


func create_table(name: StringName, schema: AbstractSchema) -> AbstractTable:
	return ConcreteTable.new(name, schema)
