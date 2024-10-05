# Copyright (c) 2024 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends VBoxContainer


const DictionaryDB: GDScript = preload("res://scripts/dictionary_database.gd")

const ColumnRemoveDialog: GDScript = preload("res://scripts/column_remove_dialog.gd")
const ColumnRenameDialog: GDScript = preload("res://scripts/column_rename_dialog.gd")


enum Type {
	BOOL = TYPE_BOOL,
	INT = TYPE_INT,
	FLOAT = TYPE_FLOAT,
	STRING = TYPE_STRING,
	COLOR = TYPE_COLOR,
	STRING_NAME = TYPE_STRING_NAME,
}
enum ColumnContextMenu {
	RENAME,
	DELETE,
}

enum {
	COLUMN_ID,
	COLUMN_TYPE,
	COLUMN_VALUE,
	COLUMN_HINT,
	COLUMN_HINT_STRING,
	COLUMN_MAX,
}
enum {
	FLAG_NONE = 0,
	FLAG_CHANGE_ID = 1 << 1,
	FLAG_CHANGE_VALUE = 1 << 2,
	FLAG_CHANGE_TYPE = 1 << 3,
	FLAG_CREATED = 1 << 4,
	FLAG_REMOVED = 1 << 5,
}


var _filter_line: LineEdit = null
var _table_view: TableView = null
var _column_context_menu: PopupMenu = null

var _column_rename_dialog: ColumnRenameDialog = null
var _column_remove_dialog: ColumnRemoveDialog = null

var _bottom_hbox: HBoxContainer = null
var _column_id: LineEdit = null
var _create_column: Button = null

var _table: Dictionary[StringName, Variant] = DictionaryDB.NULL_TABLE
var _edit_buffer: Array[Dictionary] = []


func _init(table: Dictionary[StringName, Variant]) -> void:
	_table = table
	update_temp_params(table)

	_filter_line = LineEdit.new()
	_filter_line.set_placeholder("Filter Columns")
	_filter_line.set_clear_button_enabled(true)
	_filter_line.text_changed.connect(_on_filter_line_text_changed)
	self.add_child(_filter_line)

	_table_view = TableView.new()
	_table_view.set_theme(preload("res://addons/table-view/resources/table_view.tres"))
	_table_view.set_v_size_flags(Control.SIZE_EXPAND_FILL)
	_table_view.row_rmb_clicked.connect(_on_row_rmb_clicked)
	_table_view.cell_value_changed.connect(_on_table_cell_value_changed)
	_table_view.cell_double_clicked.connect(_on_cell_double_clicked)
	self.add_child(_table_view)

	_bottom_hbox = HBoxContainer.new()
	self.add_child(_bottom_hbox)

	_column_id = LineEdit.new()
	_column_id.set_placeholder("Column ID")
	_column_id.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	_column_id.text_changed.connect(_on_column_id_changed)
	_bottom_hbox.add_child(_column_id)

	_create_column = Button.new()
	_create_column.set_text("Create")
	_create_column.set_tooltip_text("Create a new column")
	_create_column.set_disabled(true)
	_create_column.pressed.connect(_on_create_column_pressed)
	_bottom_hbox.add_child(_create_column)

	update_table()


func _enter_tree() -> void:
	_filter_line.set_right_icon(get_theme_icon(&"search", &"Control"))
	_create_column.set_button_icon(get_theme_icon(&"add", &"Control"))


func is_valid_id(id: StringName) -> bool:
	return DictionaryDB.is_valid_id(id)

func has_column_id(id: StringName) -> bool:
	return DictionaryDB.table_has_column_id(_table, id)


static func create_edit_buffer(
		id: StringName,
		type: int,
		value: Variant,
		hint: int = PROPERTY_HINT_NONE,
		hint_string: String = "",
	) -> Dictionary[StringName, Variant]:

	return {
		&"id": id,
		&"type": type,
		&"value": value,
		&"hint": hint,
		&"hint_string": hint_string,
		&"flag": FLAG_NONE,
	}

static func create_edit_buffer_from_column(column: Dictionary) -> Dictionary[StringName, Variant]:
	return create_edit_buffer(
		DictionaryDB.column_get_id(column),
		DictionaryDB.column_get_type(column),
		DictionaryDB.column_get_default_value(column),
		DictionaryDB.column_get_hint(column),
		DictionaryDB.column_get_hint_string(column),
	)


func update_temp_params(table: Dictionary[StringName, Variant]) -> void:
	var columns: Array[Dictionary] = DictionaryDB.table_get_columns(table)
	_edit_buffer.resize(columns.size())

	for i: int in _edit_buffer.size():
		_edit_buffer[i] = create_edit_buffer_from_column(columns[i])


func update_row(row_idx: int, buffer: Dictionary) -> void:
	_table_view.set_cell_value_no_signal(row_idx, COLUMN_ID, buffer.id)
	_table_view.set_cell_value_no_signal(row_idx, COLUMN_TYPE, buffer.type)

	_table_view.set_cell_custom_type(row_idx, COLUMN_VALUE, buffer.type, buffer.hint, buffer.hint_string)
	_table_view.set_cell_value_no_signal(row_idx, COLUMN_VALUE, buffer.value)

	_table_view.set_cell_value_no_signal(row_idx, COLUMN_HINT, buffer.hint)
	_table_view.set_cell_value_no_signal(row_idx, COLUMN_HINT_STRING, buffer.hint_string)

	_table_view.set_row_metadata(row_idx, buffer)
	_table_view.set_row_visible(row_idx, ~buffer.flag & FLAG_REMOVED)

func update_table_rows() -> void:
	_table_view.set_row_count(_edit_buffer.size())

	for i: int in _edit_buffer.size():
		update_row(i, _edit_buffer[i])

func update_table() -> void:
	_table_view.set_column_count(COLUMN_MAX)
	_table_view.set_column_title(COLUMN_ID, "ID")
	_table_view.set_column_type(COLUMN_ID, TableView.Type.STRING_NAME, TableView.Hint.NONE, "", str, Callable())

	_table_view.set_column_title(COLUMN_TYPE, "Type")
	_table_view.set_column_type(COLUMN_TYPE, TableView.Type.INT, TableView.Hint.ENUM, TableView.enum_to_hint_string(Type))

	_table_view.set_column_title(COLUMN_VALUE, "Value")
	_table_view.set_column_comparator(COLUMN_VALUE, Callable())

	_table_view.set_column_title(COLUMN_HINT, "Hint")
	_table_view.set_column_type(COLUMN_HINT, TableView.Type.INT, TableView.Hint.ENUM, TableView.enum_to_hint_string(DictionaryDB.Hint))

	_table_view.set_column_title(COLUMN_HINT_STRING, "Hint String")
	_table_view.set_column_type(COLUMN_HINT_STRING, TableView.Type.STRING)

	update_table_rows()


func show_column_rename_dialog(row_idx: int, buffer: Dictionary[StringName, Variant]) -> void:
	if is_instance_valid(_column_rename_dialog):
		_column_rename_dialog.queue_free()

	_column_rename_dialog = ColumnRenameDialog.new(_table, buffer.id)
	_column_rename_dialog.column_renamed.connect(func on_column_renamed(id: StringName) -> void:
		buffer.id = id
		buffer.flag |= FLAG_CHANGE_ID

		_table_view.set_cell_value_no_signal(row_idx, COLUMN_ID, id)
	)
	self.add_child(_column_rename_dialog)

	_column_rename_dialog.popup_centered(Vector2i(300, 50))

func show_column_remove_dialog() -> ColumnRemoveDialog:
	if is_instance_valid(_column_remove_dialog):
		_column_remove_dialog.queue_free()

	_column_remove_dialog = ColumnRemoveDialog.new()
	self.add_child(_column_remove_dialog)

	_column_remove_dialog.popup_centered(Vector2i(300, 50))
	return _column_remove_dialog


func apply_changed() -> void:
	var table: Dictionary[StringName, Variant] = _table
	var columns: Array[Dictionary] = DictionaryDB.table_get_columns(table)

	var queue_buffer: Array[Dictionary] = _edit_buffer

	for i: int in queue_buffer.size():
		var buffer: Dictionary = queue_buffer[i]

		if buffer.flag & FLAG_REMOVED:
			DictionaryDB.table_remove_column_at(table, i)
			continue
		elif buffer.flag & FLAG_CREATED:
			var column: Dictionary = DictionaryDB.table_create_column(table, buffer.id, buffer.type, buffer.value, buffer.hint, buffer.hint_string)
			continue

		if buffer.flag & FLAG_CHANGE_ID:
			DictionaryDB.table_set_column_id(table, i, buffer.id)

		if buffer.flag & FLAG_CHANGE_TYPE:
			DictionaryDB.table_set_column_type(table, i, buffer.type, buffer.hint, buffer.hint_string)

		if buffer.flag & FLAG_CHANGE_VALUE:
			DictionaryDB.column_set_default_value(columns[i], buffer.value)




func _on_filter_line_text_changed(text: StringName) -> void:
	var callable: Callable = text.is_subsequence_ofn
	_table_view.filter_rows_by_callable(COLUMN_ID, callable)


func _on_column_id_changed(column_id: StringName) -> void:
	_create_column.set_disabled(not is_valid_id(column_id) or has_column_id(column_id))


func _on_create_column_pressed() -> void:
	var buffer: Dictionary[StringName, Variant] = create_edit_buffer(_column_id.get_text(), TYPE_BOOL, false)
	buffer.flag |= FLAG_CREATED

	_edit_buffer.push_back(buffer)
	update_table_rows()

	_create_column.set_disabled(true)


func _on_row_rmb_clicked(row_idx: int) -> void:
	if is_instance_valid(_column_context_menu):
		_column_context_menu.queue_free()

	var buffer: Dictionary = _table_view.get_row_metadata(row_idx)

	_column_context_menu = PopupMenu.new()
	_column_context_menu.add_item("Rename", ColumnContextMenu.RENAME)
	_column_context_menu.add_item("Delete", ColumnContextMenu.DELETE)
	_column_context_menu.id_pressed.connect(func on_id_pressed(option: ColumnContextMenu) -> void:
		if option == ColumnContextMenu.RENAME:
			show_column_rename_dialog(row_idx, buffer)
		else:
			var remove_dialog := show_column_remove_dialog()
			remove_dialog.column_removed.connect(func on_column_removed() -> void:
				buffer.flag = FLAG_REMOVED
				update_table_rows()
			)
	)
	self.add_child(_column_context_menu)

	_column_context_menu.popup(Rect2(get_screen_transform() * get_local_mouse_position(), Vector2.ZERO))


func _on_table_cell_value_changed(row_idx: int, column_idx: int, value: Variant) -> void:
	var buffer: Dictionary = _table_view.get_row_metadata(row_idx)

	match column_idx:
#		COLUMN_ID: For now, we're using a dialog box to do this.
#			buffer.id = value
#			buffer.flag |= FLAG_CHANGE_ID
		COLUMN_VALUE:
			buffer.value = value
			buffer.flag |= FLAG_CHANGE_VALUE

			_table_view.set_cell_value_no_signal(row_idx, COLUMN_VALUE, value)

		COLUMN_TYPE, COLUMN_HINT, COLUMN_HINT_STRING:
			if column_idx == COLUMN_TYPE:
				buffer.type = value
				buffer.value = type_convert(buffer.value, value)
			elif column_idx == COLUMN_HINT:
				buffer.hint = value
			else:
				buffer.hint_string = value

			_table_view.set_cell_value_no_signal(row_idx, COLUMN_VALUE, buffer.value)
			_table_view.set_cell_custom_type(row_idx, COLUMN_VALUE, buffer.type, buffer.hint, buffer.hint_string)

			buffer.flag |= FLAG_CHANGE_TYPE


func _on_cell_double_clicked(row_idx: int, column_idx: int) -> void:
	if column_idx != COLUMN_ID:
		return

	show_column_rename_dialog(row_idx, _table_view.get_row_metadata(row_idx))
