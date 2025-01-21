# Copyright (c) 2024-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.

extends AcceptDialog


func _init() -> void:
	self.set_title("About Datoolina")
	self.set_flag(Window.FLAG_RESIZE_DISABLED, true)

	var vbox := VBoxContainer.new()

	var icon := TextureRect.new()
	icon.set_expand_mode(TextureRect.EXPAND_IGNORE_SIZE)
	icon.set_h_size_flags(Control.SIZE_SHRINK_CENTER)
	icon.set_custom_minimum_size(Vector2(96, 96))
	icon.set_texture(load("res://icon.svg"))
	vbox.add_child(icon)

	var rich_text := RichTextLabel.new()
	rich_text.set_autowrap_mode(TextServer.AUTOWRAP_OFF)
	rich_text.set_fit_content(true)
	rich_text.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER)
	rich_text.set_selection_enabled(true)
	rich_text.set_v_size_flags(Control.SIZE_EXPAND_FILL)
	rich_text.append_text(get_about_text())
	rich_text.meta_clicked.connect(OS.shell_open)
	vbox.add_child(rich_text)

	self.add_child(vbox)

	self.close_requested.connect(queue_free)
	self.confirmed.connect(queue_free)


static func get_about_text() -> String:
	var text: String = "Version: %s\n" % ProjectSettings.get_setting("application/config/version")
	text += "Godot: {major}.{minor}.{patch}-{status}\n".format(Engine.get_version_info())
	text += "OS: %s\n" % OS.get_version()

	return text
