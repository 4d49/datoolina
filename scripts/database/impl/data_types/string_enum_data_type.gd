# Copyright (c) 2024-2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends AbstractEnumDataType


var _options: Dictionary[StringName, StringName]
var _option_map: Dictionary[StringName, StringName]

var _default: StringName = &""


func get_options() -> Dictionary[StringName, StringName]:
	return _options


func get_enum_names() -> Array[StringName]:
	return _options.keys()


func validate(value: Variant) -> bool:
	if _option_map.is_empty():
		for name: StringName in _options:
			_option_map[_options[name]] = name

	return _option_map.has(value)


func set_default(value: Variant) -> void:
	if validate(value):
		_default = value

func get_default() -> StringName:
	return _default


func get_built_in_type() -> Variant.Type:
	return TYPE_STRING


func get_type_name() -> StringName:
	return "string_enum"
