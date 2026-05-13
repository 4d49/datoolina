# Copyright (c) 2024-2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

## Abstract base class defining the interface for data types in the database system.
##
## This abstract class specifies the contract that all concrete data type implementations
## must follow, ensuring consistent validation, default value handling, and type information
## across different column types in the schema.

@abstract
class_name AbstractRangeDataType
extends AbstractDataType


@abstract func set_min(min: Variant) -> void

@abstract func get_min() -> Variant


@abstract func set_max(max: Variant) -> void

@abstract func get_max() -> Variant


func get_type_hint() -> Hint:
	return Hint.RANGE
