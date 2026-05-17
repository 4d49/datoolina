
@abstract
class_name DataTypeEditorFactory
extends Object


const BoolDataTypeEditor:   GDScript = preload("data_type_editors/bool_data_type_editor.gd")
const ColorDataTypeEditor:  GDScript = preload("data_type_editors/color_data_type_editor.gd")
const NumberDataTypeEditor: GDScript = preload("data_type_editors/number_data_type_editor.gd")
const StringDataTypeEditor: GDScript = preload("data_type_editors/string_data_type_editor.gd")


static var _registry: Array[Dictionary] = []


static func _static_init() -> void:
	register(ColorDataTypeEditor.can_handle,  ColorDataTypeEditor.new)
	register(StringDataTypeEditor.can_handle, StringDataTypeEditor.new)
	register(BoolDataTypeEditor.can_handle,   BoolDataTypeEditor.new)
	register(NumberDataTypeEditor.can_handle, NumberDataTypeEditor.new)


static func register(predicate: Callable, constructor: Callable) -> void:
	var entry: Dictionary[StringName, Variant] = {
		&"predicate": predicate,
		&"constructor": constructor
	}
	entry.make_read_only()

	_registry.push_back(entry)


static func can_create(data_type: AbstractDataType) -> bool:
	for entry: Dictionary in _registry:
		var predicate: Callable = entry.predicate
		if predicate.is_valid() and predicate.call(data_type):
			return true

	return false


static func create_editor(data_type: AbstractDataType) -> AbstractDataTypeEditor:
	for entry: Dictionary in _registry:
		var constructor: Callable = entry.constructor
		if not constructor.is_valid():
			continue

		return constructor.call(data_type)

	return null
