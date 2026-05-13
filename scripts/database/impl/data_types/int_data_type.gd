# Copyright (c) 2024-2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends "abstract_int_data_type.gd"


func validate(value: Variant) -> bool:
	return value is int or value is float


func get_type_hint() -> Hint:
	return Hint.NONE


func get_type_name() -> StringName:
	return &"int"
