# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name PauseMenuOption
extends HBoxContainer

@export var is_settings_option: bool
@export var is_level_option: bool
@export var key_string: StringName
@export var text_color_normal: Color
@export var text_color_highlight: Color
@export var settings_resource: SettingsResource
@export var scene_info_resource: SceneInfoResource

@onready var key_node: Label = get_node("Key") as Label
@onready var value_node: Label = get_node("Value") as Label


func _ready() -> void:
	Signals.setting_updated.connect(self._on_setting_updated)
	Signals.scene_changed.connect(self._on_scene_changed)

	assert(str(key_string), Errors.INVALID_ARGUMENT)
	assert(key_node != null, Errors.NULL_NODE)
	assert(value_node != null, Errors.NULL_NODE)
	assert(settings_resource != null, Errors.NULL_RESOURCE)

	value_node.text = ""

	if is_settings_option:
		key_node.text = Settings.SETTINGS[key_string][Settings.OPTION_NAME]
		value_node.text = Settings.SETTINGS[key_string][Settings.VALUE_NAMES][settings_resource.settings[key_string]]
	elif is_level_option:
		key_node.text = Levels.LEVELS[key_string][Levels.LEVEL_NAME]
	else:
		key_node.text = key_string


func set_highlight(highlight: bool) -> void:
	var text_color: Color = text_color_normal
	if highlight:
		text_color = text_color_highlight
	key_node.set("theme_override_colors/font_color", text_color)
	value_node.set("theme_override_colors/font_color", text_color)


func adjust_option(delta: int) -> void:
	if is_settings_option:
		var n_options: int = len(Settings.SETTINGS[key_string][Settings.VALUES])
		var value_new: int = posmod(settings_resource.settings[key_string] + delta, n_options)
		Signals.emit_request_setting_update(self, key_string, value_new)


func _on_setting_updated(_sender: NodePath, _key: StringName) -> void:
	if is_settings_option:
		value_node.text = Settings.SETTINGS[key_string][Settings.VALUE_NAMES][settings_resource.settings[key_string]]


func _on_scene_changed(_sender: NodePath) -> void:
	if is_level_option:
		if Levels.LEVELS[key_string][Levels.LEVEL_PATH] == scene_info_resource.scene_path:
			value_node.text = "(Current)"
		else:
			value_node.text = ""


func _on_mouse_entered() -> void:
	Signals.emit_mouse_entered_control(self)
