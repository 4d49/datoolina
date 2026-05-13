# Copyright (c) 2024-2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

@abstract
extends AbstractDataType


func get_default() -> int:
	return 0


func get_built_in_type() -> Variant.Type:
	return TYPE_INT
