#    Copyright 2021 Sólyom Zoltán
#
#    This file is part of Grab-Scale-Rotate for Godot
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

tool
extends Object

func _ready():
	pass


# Returns a child node of the control node if it matches the class name `childclass`.
# It can return a specific child node with an `index`, of all child nodes with the
# same class name.
static func find_child(control: Node, childclass: String, index: int = 0):
	if control == null:
		return null
		
	for c in control.get_children():
		if c.get_class() == childclass:
			if index == 0:
				return c
			index -= 1
	return null


static func spatial_editor(editor: EditorPlugin):
	var ei = editor.get_editor_interface()
	var vp = ei.get_editor_viewport()
	
	return find_child(vp, "SpatialEditor")


static func spatial_toolbar(editor: EditorPlugin):
	return find_child(spatial_editor(editor), "HBoxContainer")


static func spatial_use_local_toolbutton(editor: EditorPlugin):
	return find_child(spatial_toolbar(editor), "ToolButton", 9)


static func spatial_snap_toolbutton(editor: EditorPlugin):
	return find_child(spatial_toolbar(editor), "ToolButton", 10)


static func get_setting(editor: EditorPlugin, settingname: String):
	var ei: EditorInterface = editor.get_editor_interface()
	var es: EditorSettings = ei.get_editor_settings()
	return es.get_setting(settingname)
	

static func set_setting(editor: EditorPlugin, settingname: String, value):
	var ei: EditorInterface = editor.get_editor_interface()
	var es: EditorSettings = ei.get_editor_settings()
	es.set_setting(settingname, value)


static func is_dark_theme(editor: EditorPlugin) -> bool:
	var es := editor.get_editor_interface().get_editor_settings()
	
	var AUTO_COLOR = 0
	var LIGHT_COLOR = 2
	var base_color: Color = es.get_setting("interface/theme/base_color")
	var icon_font_color_setting = es.get_setting("interface/theme/icon_and_font_color")
	return (icon_font_color_setting == AUTO_COLOR && ((base_color.r + base_color.g + base_color.b) / 3.0) < 0.5) || icon_font_color_setting == LIGHT_COLOR;


static func connect_settings_changed(editor: EditorPlugin, callback: String):
	var es := editor.get_editor_interface().get_editor_settings()
	es.connect("settings_changed", editor, callback)


static func disconnect_settings_changed(editor: EditorPlugin, callback: String):
	var es := editor.get_editor_interface().get_editor_settings()
	es.disconnect("settings_changed", editor, callback)


static func get_config_property(section: String, name: String, default):
	var config = ConfigFile.new()
	if config.load("user://gsr.cfg") != OK:
		return default
	else:
		return config.get_value(section, name, default)
	
	
static func save_config(data):
	print("Saving config")
	var config = ConfigFile.new()
	# We don't care if it didn't load, just want to make sure that we get all
	# the keys if it does load.
	config.load("user://gsr.cfg")
	for key in data.keys():
		if typeof(key) != TYPE_STRING || !(data[key] is Dictionary):
			continue
		for key2 in data[key].keys():
			if typeof(key2) != TYPE_STRING:
				continue
			print("Save value: ")
			config.set_value(key, key2, data[key][key2])
	config.save("user://gsr.cfg")
	print("Config saved")

