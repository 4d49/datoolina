# Copyright (c) 2024 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

## This class provides a lightweight interface that mimics database operations.
## It is not a real database; all interactions are internally managed using arrays and dictionaries.
extends RefCounted


enum Type {
	NIL = TYPE_NIL,
	BOOL = TYPE_BOOL,
	INT = TYPE_INT,
	FLOAT = TYPE_FLOAT,
	STRING = TYPE_STRING,
	COLOR = TYPE_COLOR,
	STRING_NAME = TYPE_STRING_NAME,
}
enum Hint {
	NONE = PROPERTY_HINT_NONE,
	RANGE = PROPERTY_HINT_RANGE,
	ENUM = PROPERTY_HINT_ENUM,
	MULTILINE_TEXT = PROPERTY_HINT_MULTILINE_TEXT,
	COLOR_NO_ALPHA = PROPERTY_HINT_COLOR_NO_ALPHA,
}


const COLUMNS: StringName = &"columns"
const DEFAULT_VALUE: StringName = &"default_value"
const HINT_STRING: StringName = &"hint_string"
const HINT: StringName = &"hint"
const ID: StringName = &"id"
const RECORDS: StringName = &"records"
const TABLES: StringName = &"tables"
const TYPE: StringName = &"type"
const VALIDATOR: StringName = &"validator"

const NULL_TABLES: Array[Dictionary] = []
const NULL_DATABASE: Dictionary[StringName, Variant] = {
	ID: &"null",
	TABLES: NULL_TABLES,
}

const NULL_COLUMNS: Array[Dictionary] = []
const NULL_RECORDS: Array[Dictionary] = []
const NULL_TABLE: Dictionary[StringName, Variant] = {
	ID: &"null",
	COLUMNS: NULL_COLUMNS,
	RECORDS: NULL_RECORDS,
}

const NULL_COLUMN: Dictionary[StringName, Variant] = {
	ID: &"null",
	TYPE: Type.NIL,
	DEFAULT_VALUE: null,
	HINT: PROPERTY_HINT_NONE,
	HINT_STRING: "",
	VALIDATOR: Callable(),
}
const NULL_RECORD: Dictionary[StringName, Variant] = {
	ID: &"null",
}


static func is_valid_id(id: StringName) -> bool:
#	if id.is_empty() or id == ID:
#		return false
#
#	for c: String in String(id):
#		if (c == "_") or (c >= "0" and c <= "9") or (c >= "a" and c <= "z"):
#			continue
#		else:
#			return false
#
#	return true
	return id != ID and id.is_valid_ascii_identifier()


static func create_database(database_id: StringName) -> Dictionary[StringName, Variant]:
	if not is_valid_id(database_id):
		return NULL_DATABASE

	var tables: Array[Dictionary] = []

	return {
		ID: database_id,
		TABLES: tables,
	}


static func database_set_id(database: Dictionary, new_database_id: StringName) -> bool:
	if database[ID] == new_database_id:
		return false

	database[ID] = new_database_id
	return true

static func database_get_id(database: Dictionary) -> StringName:
	return database[ID]


static func database_get_tables(database: Dictionary) -> Array[Dictionary]:
	return database[TABLES]



static func tables_has_id(tables: Array[Dictionary], table_id: StringName) -> bool:
	for table: Dictionary in tables:
		if table_get_id(table) == table_id:
			return true

	return false


static func database_has_table_id(database: Dictionary, table_id: StringName) -> bool:
	return tables_has_id(database_get_tables(database), table_id)


static func create_table(table_id: StringName) -> Dictionary[StringName, Variant]:
	var columns: Array[Dictionary] = []
	var records: Array[Dictionary] = []

	return {
		ID: table_id,
		COLUMNS: columns,
		RECORDS: records,
	}


static func database_create_table(database: Dictionary, table_id: StringName) -> Dictionary[StringName, Variant]:
	var tables := database_get_tables(database)
	if tables_has_id(tables, table_id):
		return NULL_TABLE

	var table := create_table(table_id)
	tables.push_back(table)

	return table


static func database_remove_table_at(database: Dictionary, table_index: int) -> bool:
	var tables := database_get_tables(database)

	if tables.size() < table_index:
		return false

	tables.remove_at(table_index)
	return true

static func database_remove_table_by_id(database: Dictionary, table_id: StringName) -> bool:
	var tables := database_get_tables(database)

	for i: int in tables.size():
		if table_get_id(tables[i]) == table_id:
			tables.remove_at(i)
			return true

	return false


static func database_erase_table(database: Dictionary, table: Dictionary) -> bool:
	return database_remove_table_by_id(database, table_get_id(table))



static func database_get_table_at(database: Dictionary, table_index: int) -> Dictionary[StringName, Variant]:
	return database_get_tables(database)[table_index]

static func database_get_table_by_id(database: Dictionary, table_id: StringName) -> Dictionary[StringName, Variant]:
	for table: Dictionary in database_get_tables(database):
		if table_get_id(table) == table_id:
			return table

	return NULL_TABLE




static func table_set_id(table: Dictionary, new_id: StringName) -> bool:
	if table[ID] == new_id:
		return false

	table[ID] = new_id
	return true

static func table_get_id(table: Dictionary) -> StringName:
	return table[ID]


static func range_to_hint_string(min: float, max: float, step: float = 0.0) -> String:
	if step > 0.0:
		return String.num(min, 3) + "," + String.num(max, 3) + "," + String.num(step, 3)

	return String.num(min, 3) + "," + String.num(max, 3)

static func hint_string_to_range(hint_string: String) -> PackedFloat32Array:
	const NUM_MIN: int = -2147483648
	const NUM_MAX: int =  2147483647

	var split: PackedStringArray = hint_string.split(",")
	if split.size() > 2:
		return [
			split[0].to_float() if split[0].is_valid_float() else NUM_MIN,
			split[1].to_float() if split[1].is_valid_float() else NUM_MAX,
			split[2].to_float() if split[2].is_valid_float() else 0.001,
		]

	return [
		split[0].to_float() if split.size() > 0 and split[0].is_valid_float() else NUM_MIN,
		split[1].to_float() if split.size() > 1 and split[1].is_valid_float() else NUM_MAX,
	]


static func default_validator(type: Type, hint: Hint, hint_string: String) -> Callable:
	match type:
		Type.INT when hint == Hint.RANGE:
			var range: PackedFloat32Array = hint_string_to_range(hint_string)

			var min: int = range[0]
			var max: int = range[1]

			if range.size() > 2:
				var step: int = maxf(1.0, range[2])

				return func(value) -> int:
					return snappedi(clampi(value, min, max), step)

			return clampi.bind(min, max)

		Type.FLOAT when hint == Hint.RANGE:
			var range: PackedFloat32Array = hint_string_to_range(hint_string)

			var min: float = range[0]
			var max: float = range[1]

			if range.size() > 2:
				var step: float = range[2]

				return func(value) -> float:
					return snappedf(clampf(value, min, max), step)

			return clampf.bind(min, max)

		Type.COLOR when hint == Hint.COLOR_NO_ALPHA:
			return func(value) -> Color:
				return Color(value, 1.0)

	return type_convert.bind(type)

static func create_column(
		id: StringName,
		type: Type,
		default_value: Variant,
		hint: Hint,
		hint_string: String,
		validator: Callable,
	) -> Dictionary[StringName, Variant]:

	return {
		ID: id,
		TYPE: type,
		DEFAULT_VALUE: default_value,
		HINT: hint,
		HINT_STRING: hint_string,
		VALIDATOR: validator,
	}


static func column_set_id(column: Dictionary, new_id: StringName) -> bool:
	if column[ID] == new_id or not is_valid_id(new_id):
		return false

	column[ID] = new_id
	return true

static func column_get_id(column: Dictionary) -> StringName:
	return column[ID]


static func column_set_type(
		column: Dictionary,
		type: Type,
		hint: Hint = Hint.NONE,
		hint_string: String = "",
		validator: Callable = default_validator(type, hint, hint_string),
	) -> bool:

	if column[TYPE] == type and column[HINT] == hint and column[HINT_STRING] == hint_string:
		return false

	column[TYPE] = type
	column[HINT] = hint
	column[HINT_STRING] = hint_string
	# Required to call the `column_set_validator` function in the future.
	column[DEFAULT_VALUE] = type_convert(column[DEFAULT_VALUE], type)

	return column_set_validator(column, validator)

static func column_get_type(column: Dictionary) -> Type:
	return column[TYPE]

static func column_get_hint(column: Dictionary) -> Hint:
	return column[HINT]

static func column_get_hint_string(column: Dictionary) -> String:
	return column[HINT_STRING]


static func column_set_validator(column: Dictionary, validator: Callable) -> bool:
#	if not validator.is_valid() or column[VALIDATOR] == validator:
#		return false

	column[VALIDATOR] = validator
	column[DEFAULT_VALUE] = validator.call(column[DEFAULT_VALUE])

	return true

static func column_get_validator(column: Dictionary) -> Callable:
	return column[VALIDATOR]

static func column_validate_value(column: Dictionary, value: Variant) -> Variant:
	var validator := column_get_validator(column)
	if validator.is_valid():
		return validator.call(value)

	return value


static func column_set_default_value(column: Dictionary, default_value: Variant) -> bool:
	var validator := column_get_validator(column)
	if validator.is_valid():
		default_value = validator.call(default_value)

	if is_same(column[DEFAULT_VALUE], default_value):
		return false

	column[DEFAULT_VALUE] = default_value
	return true

static func column_get_default_value(column: Dictionary) -> Variant:
	return column[DEFAULT_VALUE]



static func table_get_columns(table: Dictionary) -> Array[Dictionary]:
	return table[COLUMNS]


static func columns_has_id(columns: Array[Dictionary], column_id: StringName) -> bool:
	for column: Dictionary in columns:
		if column_get_id(column) == column_id:
			return true

	return false


static func table_has_column_id(table: Dictionary, column_id: StringName) -> bool:
	return columns_has_id(table_get_columns(table), column_id)


static func table_create_column(
		table: Dictionary,
		column_id: StringName,
		type: Type,
		default_value: Variant,
		hint: Hint = Hint.NONE,
		hint_string: String = "",
		validator: Callable = default_validator(type, hint, hint_string),
	) -> Dictionary[StringName, Variant]:

	var columns := table_get_columns(table)
	if columns_has_id(columns, column_id):
		return NULL_COLUMN

	if validator.is_valid():
		default_value = validator.call(default_value)

	var column := create_column(column_id, type, default_value, hint, hint_string, validator)
	for record: Dictionary in table_get_records(table):
		record[column_id] = default_value

	columns.push_back(column)
	return column

static func table_remove_column_at(table: Dictionary, column_index: int) -> bool:
	var columns := table_get_columns(table)
	if column_index > columns.size():
		return false

	columns.remove_at(column_index)
	return true

static func table_remove_column_by_id(table: Dictionary, column_id: StringName) -> bool:
	var columns := table_get_columns(table)

	for i: int in columns.size():
		if column_get_id(columns[i]) == column_id:
			columns.remove_at(i)
			return true

	return false


static func table_get_column_at(table: Dictionary, column_index: int) -> Dictionary[StringName, Variant]:
	return table_get_columns(table)[column_index]

static func table_get_column_by_id(table: Dictionary, column_id: StringName) -> Dictionary[StringName, Variant]:
	for column: Dictionary in table_get_columns(table):
		if column_get_id(column) == column_id:
			return column

	return NULL_COLUMN


static func table_get_records(table: Dictionary) -> Array[Dictionary]:
	return table[RECORDS]


static func table_set_column_id(table: Dictionary, column_index: int, new_column_id: StringName) -> bool:
	var columns := table_get_columns(table)
	if columns_has_id(columns, new_column_id):
		return false

	var old_id: StringName = column_get_id(columns[column_index])
	if not column_set_id(columns[column_index], new_column_id):
		return false

	for record: Dictionary in table_get_records(table):
		var value: Variant = record[old_id]
		if record.erase(old_id):
			record[new_column_id] = value

	return true

static func table_set_column_type(
		table: Dictionary,
		column_index: int,
		type: Type,
		hint: Hint,
		hint_string: String,
		validator: Callable = default_validator(type, hint, hint_string),
	) -> bool:

	var column := table_get_column_at(table, column_index)
	if not column_set_type(column, type, hint, hint_string, validator):
		return false

	var column_id := column_get_id(column)
	for record: Dictionary in table_get_records(table):
		record_set_value(record, column_id, validator.call(type_convert(record_get_value(record, column_id), type)))

	return true



static func create_record(id: StringName, columns: Array[Dictionary]) -> Dictionary[StringName, Variant]:
	var record: Dictionary[StringName, Variant] = {ID: id}
	for column: Dictionary in columns:
		record[column_get_id(column)] = column_get_default_value(column)

	return record


static func record_set_id(record: Dictionary, new_id: StringName) -> bool:
	if record[ID] == new_id:
		return false

	record[ID] = new_id
	return true

static func record_get_id(record: Dictionary) -> StringName:
	return record[ID]


static func record_set_value(record: Dictionary, column_id: StringName, value: Variant) -> bool:
	if not record.has(column_id):
		return false

	record[column_id] = value
	return true

static func record_get_value(record: Dictionary, column_id: StringName) -> Variant:
	return record[column_id]



static func records_has_id(records: Array[Dictionary], record_id: StringName) -> bool:
	for record: Dictionary in records:
		if record_get_id(record) == record_id:
			return true

	return false


static func table_create_record(table: Dictionary, record_id: StringName) -> Dictionary[StringName, Variant]:
	if not is_valid_id(record_id):
		return NULL_RECORD

	var records := table_get_records(table)
	if records_has_id(records, record_id):
		return NULL_RECORD

	var record := create_record(record_id, table_get_columns(table))
	records.push_back(record)

	return record


static func table_remove_record_at(table: Dictionary, record_index: int) -> bool:
	var records := table_get_records(table)

	if record_index < 0 or record_index > records.size():
		return false

	records.remove_at(record_index)
	return true

static func table_remove_record_by_id(table: Dictionary, record_id: StringName) -> bool:
	var records := table_get_records(table)

	for i: int in records.size():
		if record_get_id(records[i]) == record_id:
			records.remove_at(i)
			return true

	return false


static func table_erase_record(table: Dictionary, record: Dictionary) -> bool:
	return table_remove_record_by_id(table, record_get_id(record))


static func table_has_record_id(table: Dictionary, record_id: StringName) -> bool:
	return records_has_id(table_get_records(table), record_id)
