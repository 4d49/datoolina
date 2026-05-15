# Copyright (c) 2024-2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

## Centralized registry and factory for all data type implementations.
##
## By design, this class serves as the single source of truth and the
## exclusive entry point for instantiating and configuring data types
## within the system.

@abstract
class_name DataTypeRegistry
extends Object


static var _registry: Dictionary[StringName, Callable] = {}


static func _static_init() -> void:
	register(&"bool",          load("impl/data_types/bool_data_type.gd").new)
	register(&"float",         load("impl/data_types/float_data_type.gd").new)
	register(&"float_range",   load("impl/data_types/float_range_data_type.gd").new)
	register(&"int",           load("impl/data_types/int_data_type.gd").new)
	register(&"int_enum",      load("impl/data_types/int_enum_data_type.gd").new)
	register(&"int_range",     load("impl/data_types/int_range_data_type.gd").new)
	register(&"string",        load("impl/data_types/string_data_type.gd").new)
	register(&"string_enum",   load("impl/data_types/string_enum_data_type.gd").new)
	register(&"string_name",   load("impl/data_types/string_name_data_type.gd").new)

## Registers a new data type.
## [param type_name] Unique identifier.
## [param constructor] Callable returning a new instance.
static func register(type_name: StringName, constructor: Callable) -> void:
	assert(constructor.is_valid(), "Invalid constructor Callable!")
	if not constructor.is_valid():
		return

	_registry[type_name] = constructor

## Creates a data type instance and applies [param config] (e.g., min, max, options, default).
## [param type_name] Registered type identifier.
static func create(type_name: StringName, config: Dictionary = {}) -> AbstractDataType:
	assert(_registry.has(type_name), "Type '%s' is not registered!" % type_name)
	if not _registry.has(type_name):
		return null

	var constructor: Callable = _registry[type_name]
	assert(constructor.is_valid(), "Invalid DataType constructor!")
	if not constructor.is_valid():
		return null

	var instance: AbstractDataType = constructor.call()
	assert(is_instance_valid(instance), "Invalid AbstractDataType instance!")

	if config.has(&"default"):
		instance.set_default(config.default)

	if instance is AbstractRangeDataType:
		if config.has(&"min"):
			instance.set_min(config.min)
		if config.has(&"max"):
			instance.set_max(config.max)

	elif instance is AbstractEnumDataType:
		if config.has(&"options"):
			instance.set_options(config.options)

	return instance

## Returns an array of all registered type names.
static func get_registered_types() -> Array[StringName]:
	return _registry.keys()
