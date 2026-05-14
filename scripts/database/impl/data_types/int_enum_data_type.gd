# Copyright (c) 2024-2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends AbstractEnumDataType


var _options: Dictionary[StringName, int]
var _option_map: Dictionary[int, StringName]

var _default: int


func get_options() -> Dictionary[StringName, int]:
	return _options


func get_enum_names() -> Array[StringName]:
	return _options.keys()


func validate(value: Variant) -> bool:
	if _option_map.is_empty():
		for name: StringName in _options:
			_option_map[_options[name]] = name

	return _option_map.has(value)


func get_default() -> Variant:
	return _default


func get_built_in_type() -> Variant.Type:
	return TYPE_INT


func get_type_name() -> StringName:
	return &"int_enum"
