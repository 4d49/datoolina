# Copyright (c) 2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends AbstractDataType


func validate(value: Variant) -> bool:
	return value is bool


func get_default() -> Variant:
	return false


func get_built_in_type() -> Variant.Type:
	return TYPE_BOOL


func get_type_name() -> StringName:
	return &"bool"
