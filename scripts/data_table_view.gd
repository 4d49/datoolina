# Copyright (c) 2024-2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends VBoxContainer


const RecordDeleteDialog: GDScript = preload("res://scripts/record_delete_dialog.gd")
const RecordRenameDialog: GDScript = preload("res://scripts/record_rename_dialog.gd")
const RecordsDeleteDialog: GDScript = preload("res://scripts/records_delete_dialog.gd")


signal table_modified
signal table_changed(table: AbstractTable)


enum RowContextMenu {
	RENAME,
	DELETE,
}


var _filter_line: LineEdit = null
var _table_view: TableView = null

var _bottom_container: HBoxContainer = null
var _record_id: LineEdit = null
var _create_btn: Button = null

var _record_delete_dialog: RecordDeleteDialog = null
var _record_rename_dialog: RecordRenameDialog = null
var _records_delete_dialog: RecordsDeleteDialog = null

var _table: AbstractTable = null


func _init() -> void:
	_filter_line = LineEdit.new()
	_filter_line.set_placeholder("Filter Records")
	_filter_line.set_clear_button_enabled(true)
	_filter_line.text_changed.connect(_on_filter_line_text_changed)
	self.add_child(_filter_line)

	_table_view = TableView.new()
	_table_view.set_editable(false)
	_table_view.set_select_mode(TableView.SelectMode.MULTI_ROW)
	_table_view.set_v_size_flags(Control.SIZE_EXPAND_FILL)
	_table_view.get_or_create_column_context_menu()
	_table_view.add_user_signal(&"table_changed")
	_table_view.row_rmb_clicked.connect(_on_row_rmb_clicked)
	self.add_child(_table_view)

	_bottom_container = HBoxContainer.new()
	self.add_child(_bottom_container)

	_record_id = LineEdit.new()
	_record_id.set_editable(false)
	_record_id.set_placeholder("Record ID")
	_record_id.set_clear_button_enabled(true)
	_record_id.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	_record_id.text_changed.connect(_on_record_id_text_changed)
	_bottom_container.add_child(_record_id)

	_create_btn = Button.new()
	_create_btn.set_text("Create")
	_create_btn.set_disabled(true)
	_create_btn.pressed.connect(_on_create_pressed)
	_bottom_container.add_child(_create_btn)


func _enter_tree() -> void:
	_filter_line.set_right_icon(get_theme_icon(&"search"))
	_create_btn.set_button_icon(get_theme_icon(&"add"))


func get_table_view() -> TableView:
	return _table_view


func update_table() -> void:
	# Check table validity
	if not is_instance_valid(_table):
		return

	# Get table schema and columns
	var columns: Array[AbstractColumn] = _table.get_columns()
	_table_view.set_column_count(columns.size())

	# Setup columns
	for i: int in columns.size():
		var column: AbstractColumn = columns[i]
		_table_view.set_column_metadata(i, column)
		_table_view.set_column_title(i, column.get_name())
		_table_view.set_column_tooltip(i, column.get_description())

		# FIXME: need to properly implement type hint creation for TableView.
#		var hint: Dictionary = TypeHintUtils.table_view_hint(column.hint, column.hint_string)
#		_table_view.set_column_type(i, column.type, hint)
#		_table_view.set_column_comparator(i, TableView.default_comparator(column.type, hint))
		_table_view.set_column_type(i, column.get_built_in_type() as int)

	# Get table records
	var records: Array[AbstractRecord] = _table.get_records()
	_table_view.set_row_count(records.size())

	# Get column names information
	var column_names: Array[StringName] = _table.get_column_names()

	# Populate row data
	for i: int in records.size():
		var record: AbstractRecord = records[i]
		_table_view.set_row_metadata(i, record)

		for j: int in column_names.size():
			_table_view.set_cell_value_no_signal(i, j, record.get_value(column_names[j]))

	# Update table display
	_table_view.update_table()
	_table_view.emit_signal(&"table_changed")


func set_table(table: AbstractTable) -> void:
	if is_same(table, _table):
		return

	_table = table
	_record_id.set_editable(is_instance_valid(table))

	update_table()

func get_table() -> AbstractTable:
	return _table


func is_valid_id(id: StringName) -> bool:
	return id.is_valid_ascii_identifier()


func has_record_id(id: StringName) -> bool:
	return _table.has_record(id)


func show_record_rename_dialog(record: AbstractRecord) -> void:
	if is_instance_valid(_record_rename_dialog):
		_record_rename_dialog.queue_free()

	_record_rename_dialog = RecordRenameDialog.new(_table, record)
	_record_rename_dialog.record_renamed.connect(func on_record_renamed(_id) -> void:
		table_modified.emit()
		update_table()
	)
	self.add_child(_record_rename_dialog)

	_record_rename_dialog.popup_centered(Vector2i(300, 50))


func show_record_delete_dialog(record: AbstractRecord, row_idx: int) -> void:
	if is_instance_valid(_record_delete_dialog):
		_record_delete_dialog.queue_free()

	_record_delete_dialog = RecordDeleteDialog.new(_table, record)
	_record_delete_dialog.record_deleted.connect(func on_record_deleted() -> void:
		_table_view.remove_row(row_idx)
		table_modified.emit()
	)
	self.add_child(_record_delete_dialog)

	_record_delete_dialog.popup_centered(Vector2i(300, 50))

func show_records_delete_dialog(records: Array[AbstractRecord], selected_rows: PackedInt32Array) -> RecordsDeleteDialog:
	if is_instance_valid(_records_delete_dialog):
		_records_delete_dialog.queue_free()

	_records_delete_dialog = RecordsDeleteDialog.new(_table, records)
	_records_delete_dialog.records_deleted.connect(func on_records_deleted() -> void:
		selected_rows.reverse()

		for i: int in selected_rows:
			_table_view.remove_row(i)

		table_modified.emit()
	)
	self.add_child(_records_delete_dialog)

	_records_delete_dialog.popup_centered_ratio(0.25)
	return _records_delete_dialog




func _on_filter_line_text_changed(text: String) -> void:
	var callable: Callable = text.is_subsequence_ofn
	_table_view.filter_rows_by_callable(0, callable)
	_table_view.emit_signal(&"table_changed")


func _on_record_id_text_changed(id: StringName) -> void:
	_create_btn.set_disabled(not is_valid_id(id) or has_record_id(id))


func _on_create_pressed() -> void:
	var id: StringName = _record_id.get_text()
	var record: AbstractRecord = DatabaseFactory.create_record(id, _table)
	_table.add_record(record)

	table_modified.emit()
	update_table()

	_create_btn.set_disabled(true)


func _on_row_rmb_clicked(row_idx: int) -> void:
	var selected_row: PackedInt32Array = _table_view.get_selected_rows()

	if selected_row.is_empty():
		return

	elif selected_row.size() == 1:
		var record: AbstractRecord = _table_view.get_row_metadata(row_idx) as AbstractRecord
		if not is_instance_valid(record):
			return

		var popup := PopupMenu.new()
		popup.add_item("Rename", RowContextMenu.RENAME)
		popup.add_item("Delete", RowContextMenu.DELETE)
		popup.id_pressed.connect(func on_id_pressed(option: RowContextMenu) -> void:
			match option:
				RowContextMenu.RENAME:
					show_record_rename_dialog(record)
				RowContextMenu.DELETE:
					show_record_delete_dialog(record, row_idx)
		)
		popup.focus_exited.connect(popup.queue_free)
		self.add_child(popup)

		popup.popup(Rect2i(get_screen_transform() * get_local_mouse_position(), Vector2i.ZERO))

	else:
		var records: Array[AbstractRecord] = []
		records.resize(selected_row.size())

		for i: int in selected_row.size():
			records[i] = _table_view.get_row_metadata(selected_row[i])

		var popup := PopupMenu.new()
		popup.add_item("Delete", RowContextMenu.DELETE)
		popup.id_pressed.connect(func on_id_pressed(option: RowContextMenu) -> void:
			if option == RowContextMenu.DELETE:
				show_records_delete_dialog(records, selected_row)
		)
		popup.focus_exited.connect(popup.queue_free)
		self.add_child(popup)

		popup.popup(Rect2i(get_screen_transform() * get_local_mouse_position(), Vector2i.ZERO))
