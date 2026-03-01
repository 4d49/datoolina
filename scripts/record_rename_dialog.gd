# Copyright (c) 2024-2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends ConfirmationDialog


signal record_renamed(id: StringName)


var _line_edit: LineEdit = null

var _table: AbstractTable = null
var _record: AbstractRecord = null


func _init(table: AbstractTable, record: AbstractRecord) -> void:
	self.set_title("Rename Record")
	self.set_flag(Window.FLAG_RESIZE_DISABLED, true)

	_table = table
	_record = record

	var ok_button := get_ok_button()
	ok_button.set_text("Rename")
	ok_button.set_disabled(true)

	_line_edit = LineEdit.new()
	_line_edit.set_text(record.get_id())
	_line_edit.set_placeholder("Record ID")
	_line_edit.set_clear_button_enabled(true)
	_line_edit.text_changed.connect(_on_id_changed)
	self.add_child(_line_edit)

	confirmed.connect(_on_confirmed)


func is_valid_id(id: StringName) -> bool:
	return id.is_valid_ascii_identifier()


func has_record(id: StringName) -> bool:
	return _table.has_record(id)


func _on_id_changed(id: StringName) -> void:
	get_ok_button().set_disabled(not is_valid_id(id) or has_record(id))


func _on_confirmed() -> void:
	# TODO: Perhaps in the future it would be better to move this to a dedicated Utils class.
	var old_id: StringName = _record.get_id()
	_table.erase_record(old_id)

	var new_id: StringName = _line_edit.get_text()
	_record.set_id(new_id)
	_table.add_record(_record)

	record_renamed.emit(new_id)
