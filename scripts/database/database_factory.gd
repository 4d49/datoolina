# Copyright (c) 2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

## DatabaseFactory provides a centralized way to create instances of database objects.
## This follows the Factory Pattern for better dependency management, testability,
## and clean separation between object creation and usage logic.
##
## This implementation follows the Singleton pattern, ensuring there is only one
## instance of the factory throughout the application. The singleton instance can
## be customized using the set_instance() method, allowing for dependency injection
## and easier testing with mock implementations.

class_name DatabaseFactory
extends RefCounted


# Store the factory instance - initially null
static var _instance: AbstractDatabaseFactory = null


## Sets the singleton instance of the database factory.
## This allows for custom factory implementations to be used instead of the default one.
## If no instance is set, the factory will create a default ConcreteDatabaseFactory instance.
static func set_instance(factory: AbstractDatabaseFactory) -> void:
	_instance = factory

## Gets the singleton instance of the database factory.
## Returns the currently set factory instance.
static func get_instance() -> AbstractDatabaseFactory:
	return _instance


## Creates a new AbstractSchema instance.
## Returns a new AbstractSchema instance with default configuration.
static func create_schema() -> AbstractSchema:
	return get_instance().create_schema()


## Creates a new AbstractDatabase instance.
## Returns a new AbstractDatabase instance with default configuration.
static func create_database(name: StringName) -> AbstractDatabase:
	return get_instance().create_database(name)


## Creates a new AbstractColumn instance with the specified properties.
## The column will have the provided name and data type.
## Returns a new AbstractColumn instance.
static func create_column(name: StringName, data_type: AbstractDataType) -> AbstractColumn:
	return get_instance().create_column(name, data_type)


## Creates a new AbstractRow instance.
## The row will be created according to the provided schema structure.
## Returns a new AbstractRow instance.
static func create_row(schema: AbstractSchema) -> AbstractRow:
	return get_instance().create_row(schema)


## Creates a new AbstractDataType instance of the specified type.
## The data type will be created based on the provided Variant.Type.
## Returns a new AbstractDataType instance.
## Warning: This is a simplified implementation. You may want to expand this
## with more data type factories based on your specific needs.
static func create_data_type(type: Variant.Type) -> AbstractDataType:
	return get_instance().create_data_type(type)


## Creates a table and adds it to the database.
## The table will be created with the provided name and schema.
## Returns the newly created AbstractTable instance if successful, null otherwise.
static func create_table(name: StringName, schema: AbstractSchema) -> AbstractTable:
	return get_instance().create_table(name, schema)
