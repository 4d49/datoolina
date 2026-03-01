# Copyright (c) 2024-2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends AbstractDataType


func validate(value: Variant) -> bool:
	return value is StringName or value is String


func get_default() -> StringName:
	return &""


func get_built_in_type() -> Variant.Type:
	return TYPE_STRING_NAME


func get_type_name() -> StringName:
	return &"StringName"
