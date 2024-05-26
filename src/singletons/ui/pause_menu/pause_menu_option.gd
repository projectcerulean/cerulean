# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
@tool
class_name PauseMenuOption
extends HBoxContainer

@export var key_string: StringName:
	set(value):
		if value != key_string:
			key_string = value
			if is_node_ready():
				set_label_texts()
				update_configuration_warnings()
@export var is_settings_option: bool
@export var is_level_option: bool
@export var text_color_normal: Color
@export var text_color_highlight: Color
@export var settings_resource: SettingsResource
@export var scene_info_resource: SceneInfoResource

@onready var key_node: Label = get_node("Key") as Label
@onready var value_node: Label = get_node("Value") as Label


func _ready() -> void:
	assert(settings_resource != null, Errors.NULL_RESOURCE)
	assert(key_node != null, Errors.NULL_NODE)
	assert(value_node != null, Errors.NULL_NODE)
	set_label_texts()
	update_configuration_warnings()

	if not Engine.is_editor_hint():
		Signals.setting_updated.connect(self._on_setting_updated)
		Signals.scene_changed.connect(self._on_scene_changed)


func set_label_texts() -> void:
	key_node.text = ""
	value_node.text = ""

	if is_settings_option:
		key_node.text = Settings.SETTINGS[key_string][Settings.OPTION_NAME]
		if Engine.is_editor_hint():
			# Why is the godot editor not able to read settings_resource.settings?
			value_node.text = Settings.SETTINGS[key_string][Settings.VALUE_NAMES][Settings.SETTINGS[key_string].DEFAULT_VALUE_INDEX]
		else:
			value_node.text = Settings.SETTINGS[key_string][Settings.VALUE_NAMES][settings_resource.settings[key_string]]
	elif is_level_option:
		key_node.text = Levels.LEVELS[key_string][Levels.LEVEL_NAME]
	else:
		key_node.text = key_string


func set_highlight(highlight: bool) -> void:
	if not Engine.is_editor_hint():
		var text_color: Color = text_color_normal
		if highlight:
			text_color = text_color_highlight
		key_node.set("theme_override_colors/font_color", text_color)
		value_node.set("theme_override_colors/font_color", text_color)


func adjust_option(delta: int) -> void:
	if not Engine.is_editor_hint():
		if is_settings_option:
			var n_options: int = len(Settings.SETTINGS[key_string][Settings.VALUES])
			var value_new: int = posmod(settings_resource.settings[key_string] + delta, n_options)
			Signals.emit_request_setting_update(self, key_string, value_new)


func _on_setting_updated(_sender: NodePath, _key: StringName) -> void:
	if not Engine.is_editor_hint():
		if is_settings_option:
			value_node.text = Settings.SETTINGS[key_string][Settings.VALUE_NAMES][settings_resource.settings[key_string]]


func _on_scene_changed(_sender: NodePath) -> void:
	if not Engine.is_editor_hint():
		if is_level_option:
			if Levels.LEVELS[key_string][Levels.LEVEL_PATH] == scene_info_resource.get_scene_path():
				value_node.text = "(Current)"
			else:
				value_node.text = ""


func _on_mouse_entered() -> void:
	if not Engine.is_editor_hint():
		Signals.emit_mouse_entered_control(self)


func _get_configuration_warnings() -> PackedStringArray:
	var key_text: String
	if is_settings_option:
		if Settings.SETTINGS.has(key_string):
			key_text = Settings.SETTINGS[key_string][Settings.OPTION_NAME]
	elif is_level_option:
		if Levels.LEVELS.has(key_string):
			key_text = Levels.LEVELS[key_string][Levels.LEVEL_NAME]
	else:
		key_text = key_string

	var warnings: PackedStringArray = []
	if not key_text:
		warnings.append("Invalid key string set")
	return warnings
