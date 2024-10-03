# Copyright (c) 2024 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends HSplitContainer


signal database_changed(database: Dictionary[StringName, Variant])
signal table_changed(table: Dictionary[StringName, Variant])


const DictionaryDB: GDScript = preload("res://scripts/dictionary_database.gd")

const DataTableView: GDScript = preload("res://scripts/data_table_view.gd")
const RecordRenameDialog: GDScript = preload("res://scripts/record_rename_dialog.gd")
const TableCreateDialog: GDScript = preload("res://scripts/table_create_dialog.gd")
const TableDeleteDialog: GDScript = preload("res://scripts/table_delete_dialog.gd")
const TableEditDialog: GDScript = preload("res://scripts/table_edit_dialog.gd")
const TableRenameDialog: GDScript = preload("res://scripts/table_rename_dialog.gd")


enum TabContextMenu {
	NEW,
	EDIT,
	RENAME,
	DELETE,
}


var _left_vbox: VBoxContainer = null

var _tab_hbox: HBoxContainer = null
var _tab_bar: TabBar = null
var _new_tab: Button = null

var _data_view_panel: PanelContainer = null
var _data_view: DataTableView = null
var _table_view: TableView = null

var _inspector_container: TabContainer = null
var _inspector: Inspector = null

var _record_rename_dialog: RecordRenameDialog = null

var _database := DictionaryDB.NULL_DATABASE


func _init() -> void:
	_left_vbox = VBoxContainer.new()
	_left_vbox.add_theme_constant_override(&"separation", 0)
	_left_vbox.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	self.add_child(_left_vbox)

	_tab_hbox = HBoxContainer.new()
	_left_vbox.add_child(_tab_hbox)

	_tab_bar = TabBar.new()
	_tab_bar.set_auto_translate_mode(Node.AUTO_TRANSLATE_MODE_DISABLED)
	_tab_bar.add_tab("<empty>")
	_tab_bar.set_tab_disabled(0, true)
	_tab_bar.set_select_with_rmb(true)
	_tab_bar.set_max_tab_width(256)
	_tab_bar.set_theme_type_variation(&"TabContainer")
	_tab_bar.set_tab_close_display_policy(TabBar.CLOSE_BUTTON_SHOW_ACTIVE_ONLY)
	_tab_bar.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	_tab_bar.tab_selected.connect(_on_tab_changed)
	_tab_bar.tab_rmb_clicked.connect(_on_tab_rmb_clicked)
	_tab_bar.tab_close_pressed.connect(_on_tab_close_pressed)
	_tab_hbox.add_child(_tab_bar)

	_new_tab = Button.new()
	_new_tab.set_flat(true)
	_new_tab.set_tooltip_text("Create a new table")
	_new_tab.set_disabled(true)
	_new_tab.pressed.connect(show_create_table_dialog)
	_tab_hbox.add_child(_new_tab)

	_data_view_panel = PanelContainer.new()
	_data_view_panel.set_v_size_flags(Control.SIZE_EXPAND_FILL)
	_left_vbox.add_child(_data_view_panel)

	_data_view = DataTableView.new()
	_data_view.set_theme(preload("res://addons/table-view/resources/table_view.tres"))
	_data_view.call_deferred(&"update_table")
	_data_view_panel.add_child(_data_view)

	_table_view = _data_view.get_table_view()
	_table_view.row_selected.connect(_on_table_view_row_selected)

	_inspector_container = TabContainer.new()
	_inspector_container.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	_inspector_container.set_stretch_ratio(0.25)
	self.add_child(_inspector_container)

	_inspector = Inspector.new()
	_inspector.set_custom_minimum_size(Vector2(210.0, 210.0))
	_inspector_container.add_child(_inspector)
	_inspector_container.set_tab_title(0, "Inspector")

	self.database_changed.connect(_on_database_changed)


func _enter_tree() -> void:
	_new_tab.set_button_icon(get_theme_icon(&"add"))
	_data_view_panel.add_theme_stylebox_override(&"panel", get_theme_stylebox(&"panel", &"TabContainer"))


func update_tabs(deselect: bool = true) -> void:
	var tables: Array[Dictionary] = DictionaryDB.database_get_tables(_database)

	if tables.is_empty():
		_tab_bar.set_tab_count(1)
		_tab_bar.set_tab_title(0, "<empty>")
		_tab_bar.set_tab_disabled(0, true)
		_tab_bar.set_tab_metadata(0, DictionaryDB.NULL_TABLE)
	else:
		_tab_bar.set_tab_count(tables.size())

		for i: int in tables.size():
			_tab_bar.set_tab_title(i, DictionaryDB.table_get_id(tables[i]))
			_tab_bar.set_tab_disabled(i, false)
			_tab_bar.set_tab_metadata(i, tables[i])

	if deselect:
		_tab_bar.set_current_tab(0)

func update_table() -> void:
	_data_view.update_table()



func set_database(database: Dictionary[StringName, Variant]) -> void:
	if is_same(_database, database):
		return

	_database = database
	database_changed.emit(database)

func get_database() -> Dictionary:
	return _database


func show_create_table_dialog() -> void:
	var create_table: TableCreateDialog = TableCreateDialog.new(_database)
	create_table.table_created.connect(update_tabs)
	self.add_child(create_table)

	create_table.popup_centered(Vector2i(300, 50))


func show_edit_table_dialog(table: Dictionary[StringName, Variant]) -> void:
	var table_edit: TableEditDialog = TableEditDialog.new(table)
	table_edit.confirmed.connect(update_table)
	self.add_child(table_edit)

	table_edit.popup_centered(Vector2i(500, 300))

	table_edit.set_transient(true)
	table_edit.set_transient_to_focused(true)


func show_rename_table_dialog(table: Dictionary[StringName, Variant]) -> void:
	var rename_table: TableRenameDialog = TableRenameDialog.new(_database, table)
	rename_table.table_renamed.connect(update_tabs.bind(false))
	self.add_child(rename_table)

	rename_table.popup_centered(Vector2i(300, 50))

func show_delete_table_dialog(table: Dictionary[StringName, Variant]) -> void:
	var delete_table: TableDeleteDialog = TableDeleteDialog.new(_database, table)
	delete_table.table_deleted.connect(update_tabs)
	self.add_child(delete_table)

	delete_table.popup_centered(Vector2i(300, 50))


func show_record_rename_dialog(record: Dictionary[StringName, Variant]) -> RecordRenameDialog:
	if is_instance_valid(_record_rename_dialog):
		_record_rename_dialog.queue_free()

	if record.is_read_only():
		return

	_record_rename_dialog = RecordRenameDialog.new(_data_view.get_table(), record)
	self.add_child(_record_rename_dialog)

	_record_rename_dialog.popup_centered(Vector2i(300, 50))
	return _record_rename_dialog


func _on_database_changed(database: Dictionary[StringName, Variant]) -> void:
	_new_tab.set_disabled(database.is_read_only())

	update_tabs()


func _on_tab_changed(tab_idx: int) -> void:
	_inspector.clear()

	var metadata = _tab_bar.get_tab_metadata(tab_idx)
	if metadata is Dictionary:
		_data_view.set_table(metadata)
		table_changed.emit(metadata)

func _on_tab_rmb_clicked(tab_idx: int) -> void:
	var popup := PopupMenu.new()
	popup.add_item("New Table", TabContextMenu.NEW)
	popup.add_separator()
	popup.add_item("Edit Table", TabContextMenu.EDIT)
	popup.add_separator()
	popup.add_item("Rename Table", TabContextMenu.RENAME)
	popup.add_item("Delete Table", TabContextMenu.DELETE)
	popup.id_pressed.connect(func(option: TabContextMenu) -> void:
		match option:
			TabContextMenu.NEW:
				show_create_table_dialog()
			TabContextMenu.EDIT:
				show_edit_table_dialog(_tab_bar.get_tab_metadata(tab_idx))
			TabContextMenu.RENAME:
				show_rename_table_dialog(_tab_bar.get_tab_metadata(tab_idx))
			TabContextMenu.DELETE:
				show_delete_table_dialog(_tab_bar.get_tab_metadata(tab_idx))
	)
	popup.close_requested.connect(popup.queue_free)
	self.add_child(popup)

	popup.popup(Rect2i(get_screen_transform() * get_local_mouse_position(), Vector2i.ZERO))

func _on_tab_close_pressed(tab_idx: int) -> void:
	show_delete_table_dialog(_tab_bar.get_tab_metadata(tab_idx))



# WARNING: This is a temporary and hacky solution. It should be refactored properly later!
static func create_table_view_cell_setter(table_view: TableView, row_idx: int, column_idx: int) -> Callable:
	var font: Font = table_view._font
	var font_size: int = table_view._font_size

	var row: Dictionary = table_view._rows[row_idx]
	var cell: Dictionary = row[&"cells"][column_idx]

	var text_line: TextLine = cell.text_line

	var stringifier: Callable = cell.type_hint.stringifier
	stringifier = func stringify(value: Variant) -> String:
		if value == null:
			return "<null>"

		return stringifier.call(value)

	return func cell_setter(value: Variant) -> void:
		prints(cell.value, value)
		if is_same(cell.value, value):
			return

		text_line.clear()
		text_line.add_string(stringifier.call(value), font, font_size)

		cell.value = value
		table_view.cell_value_changed.emit(row_idx, column_idx, value)

		table_view.queue_redraw()

func _on_table_view_row_selected(row_idx: int) -> void:
	var record: Dictionary = _table_view.get_row_metadata(row_idx)

	var property_helper := PropertyHelper.new()

	property_helper.add_category("Record Editor")
	property_helper.add_property(
		"id",
		TYPE_STRING_NAME,
		Callable(),
		func get_id() -> StringName: return record.id,
		PROPERTY_HINT_NONE,
		"",
		PROPERTY_USAGE_DEFAULT + PROPERTY_USAGE_SCRIPT_VARIABLE + PROPERTY_USAGE_READ_ONLY,
	)

	var column_idx: int = 1 # Plus ID column offset.
	for column: Dictionary in DictionaryDB.table_get_columns(_data_view.get_table()):
		var id: StringName = DictionaryDB.column_get_id(column)
		var validator: Callable = DictionaryDB.column_get_validator(column)

		var setter_cell: Callable = create_table_view_cell_setter(_table_view, row_idx, column_idx)

		var setter: Callable = func(value: Variant) -> bool:
			value = validator.call(value)

			if is_same(record[id], value):
				return false

			record[id] = value
			setter_cell.call(value)

			return true
		var getter: Callable = func() -> Variant:
			return record[id]

		property_helper.add_property(id, column.type, setter, getter, column.hint, column.hint_string)

		column_idx += 1

	_inspector.set_object(property_helper)
