# Copyright (c) 2024-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends ConfirmationDialog


signal table_created


var _vbox: VBoxContainer = null

var _id_hbox: VBoxContainer = null
var _id_lable: Label = null
var _id_edit: LineEdit = null

var _description_vbox: VBoxContainer = null
var _description_label: Label = null
var _description_edit: TextEdit = null

var _database: AbstractDatabase = null


func _init(database: AbstractDatabase) -> void:
	_database = database

	self.set_title("Create Table")

	var ok_button := get_ok_button()
	ok_button.set_text("Create")
	ok_button.set_disabled(has_table("new_table"))

	_vbox = VBoxContainer.new()

	_id_hbox = VBoxContainer.new()
	_id_lable = Label.new()
	_id_lable.set_text("Table ID:")
	_id_hbox.add_child(_id_lable)

	_id_edit = LineEdit.new()
	_id_edit.set_text("new_table")
	_id_edit.select_all()
	_id_edit.set_clear_button_enabled(true)
	_id_edit.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	_id_edit.call_deferred(&"grab_focus")
	_id_edit.text_changed.connect(_on_line_edit_id_changed)
	_id_hbox.add_child(_id_edit)
	_vbox.add_child(_id_hbox)
	self.register_text_enter(_id_edit)

	_description_vbox = VBoxContainer.new()
	_description_vbox.set_v_size_flags(Control.SIZE_EXPAND_FILL)

	_description_label = Label.new()
	_description_label.set_text("Table Description:")
	_description_vbox.add_child(_description_label)

	_description_edit = TextEdit.new()
#	_description_edit.set_fit_content_width_enabled(true)
#	_description_edit.set_fit_content_height_enabled(true)
	_description_edit.select_all()
	_description_edit.set_v_size_flags(Control.SIZE_EXPAND_FILL)
	_description_edit.set_custom_minimum_size(Vector2(350, 75))
	_description_vbox.add_child(_description_edit)

	_vbox.add_child(_description_vbox)

	self.add_child(_vbox)

	self.confirmed.connect(_on_confirmed)


func is_valid_id(id: StringName) -> bool:
	return id.is_valid_ascii_identifier()

func has_table(table_name: StringName) -> bool:
	return _database.has_table(table_name)


func _on_line_edit_id_changed(id: StringName) -> void:
	get_ok_button().set_disabled(not is_valid_id(id) or has_table(id))


func _on_confirmed() -> void:
	var table_name: StringName = _id_edit.get_text()
	var description: String = _description_edit.get_text()

	# FIXME: Требуется исправление!
	var schema: AbstractSchema = null
	var table: AbstractTable = DatabaseFactory.create_table(table_name, schema)
	if not is_instance_valid(table):
		return

	table.set_description(description)
	_database.add_table(table)

	table_created.emit()
