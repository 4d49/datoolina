# Copyright (c) 2024-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends ConfirmationDialog


signal table_changed


const DictionaryDB: GDScript = preload("res://scripts/dictionary_database.gd")


var _vbox: VBoxContainer = null

var _id_hbox: VBoxContainer = null
var _id_lable: Label = null
var _id_edit: LineEdit = null

var _description_vbox: VBoxContainer = null
var _description_label: Label = null
var _description_edit: TextEdit = null

var _database: Dictionary[StringName, Variant] = DictionaryDB.NULL_DATABASE
var _table: Dictionary[StringName, Variant] = DictionaryDB.NULL_TABLE

var _original_id: StringName = &""
var _original_description: String = ""


func _init(database: Dictionary, table: Dictionary) -> void:
	_database = database
	_table = table

	_original_id = DictionaryDB.table_get_id(table)
	_original_description = DictionaryDB.table_get_description(table)

	self.set_title("Rename Table")

	var ok_button := get_ok_button()
	ok_button.set_text("Apply")
	ok_button.set_disabled(true)
	ok_button.set_tooltip_text("Save changes to the table id and/or description.\nThe button will be enabled when valid changes are detected.")

	_vbox = VBoxContainer.new()

	_id_hbox = VBoxContainer.new()
	_id_lable = Label.new()
	_id_lable.set_text("Table ID:")
	_id_hbox.add_child(_id_lable)

	_id_edit = LineEdit.new()
	_id_edit.set_text(DictionaryDB.table_get_id(table))
	_id_edit.set_clear_button_enabled(true)
	_id_edit.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	_id_edit.text_changed.connect(_on_id_changed)
	_id_edit.call_deferred(&"grab_focus")
	_id_hbox.add_child(_id_edit)
	_vbox.add_child(_id_hbox)
	self.register_text_enter(_id_edit)

	_description_vbox = VBoxContainer.new()
	_description_vbox.set_v_size_flags(Control.SIZE_EXPAND_FILL)

	_description_label = Label.new()
	_description_label.set_text("Table Description:")
	_description_vbox.add_child(_description_label)

	_description_edit = TextEdit.new()
	_description_edit.set_text(DictionaryDB.table_get_description(table))
	_description_edit.set_v_size_flags(Control.SIZE_EXPAND_FILL)
	_description_edit.set_custom_minimum_size(Vector2(350, 75))
	_description_edit.text_changed.connect(_validate_changes)
	_description_vbox.add_child(_description_edit)

	_vbox.add_child(_description_vbox)

	self.add_child(_vbox)

	confirmed.connect(_on_confirmed)
	canceled.connect(queue_free)


func is_available_table_id(id: StringName) -> bool:
	return DictionaryDB.is_valid_id(id) and not DictionaryDB.database_has_table_id(_database, id)


func _validate_changes() -> void:
	var new_id: StringName = _id_edit.get_text()
	if _original_id != new_id and not is_available_table_id(new_id):
		get_ok_button().set_disabled(true)
	else:
		var new_description: String = _description_edit.get_text()
		get_ok_button().set_disabled(not (_original_id != new_id or _original_description != new_description))


func _on_id_changed(_id: String) -> void:
	_validate_changes()


func _on_confirmed() -> void:
	var new_id: StringName = _id_edit.get_text()
	var new_description: String = _description_edit.get_text()

	var changed: bool = false
	if _original_id != new_id and DictionaryDB.table_set_id(_table, new_id):
		changed = true
	if _original_description != new_description and DictionaryDB.table_set_description(_table, new_description):
		changed = true

	if changed:
		table_changed.emit()
