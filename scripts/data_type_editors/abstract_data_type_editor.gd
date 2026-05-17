# Copyright (c) 2024-2026 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

@abstract
@warning_ignore_start("shadowed_global_identifier", "shadowed_variable_base_class")

## Abstract base for [AbstractDataType] editors.
## Requires [method setup] implementation.

class_name AbstractDataTypeEditor
extends VBoxContainer


## Returns a [Label] with text clipping enabled.
func create_label(text: String) -> Label:
	var label := Label.new()
	label.set_clip_text(true)
	label.set_text(text)

	return label

## Creates a SpinBox with specified parameters.
func create_spin_box(value: float, min: float, max: float, step: float, rounded: bool = false) -> SpinBox:
	var spin_box := SpinBox.new()
	spin_box.set_min(min)
	spin_box.set_max(max)
	spin_box.set_step(step)
	spin_box.set_use_rounded_values(rounded)
	spin_box.set_value_no_signal(value)

	return spin_box

## Wraps a [Control] with a title label.
func create_labeled_container(title: String, control: Control, vertical: bool = false) -> BoxContainer:
	var container := BoxContainer.new()
	container.set_vertical(vertical)

	if title:
		var label := create_label(title)
		label.set_h_size_flags(SIZE_EXPAND_FILL)
		label.set_stretch_ratio(0.75)
		container.add_child(label)

	if is_instance_valid(control):
		control.set_h_size_flags(SIZE_EXPAND_FILL)
		control.set_v_size_flags(SIZE_EXPAND_FILL)
		container.add_child(control)

	return container

## Adds a labeled row to this editor.
func add_row(title: String, control: Control, vertical: bool = false) -> void:
	var labeled_container := create_labeled_container(title, control, vertical)
	self.add_child(labeled_container)
