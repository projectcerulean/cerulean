# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Node

@export var settings_resource: SettingsResource
@export var settings_file_path: String = "user://settings.json"


func _ready() -> void:
	Signals.request_setting_update.connect(self._on_request_setting_update)
	Signals.request_settings_save.connect(self._on_request_settings_save)
	assert(settings_resource != null, Errors.NULL_RESOURCE)
	assert(settings_resource.settings.size() == Settings.SETTINGS.size(), Errors.CONSISTENCY_ERROR)
	for i in range(settings_resource.settings.size()):
		assert(settings_resource.settings.keys()[i] == Settings.SETTINGS.keys()[i], Errors.CONSISTENCY_ERROR)

	for key in settings_resource.settings:
		assert(Settings.SETTINGS[key].VALUES.size() == Settings.SETTINGS[key].VALUE_NAMES.size(), Errors.CONSISTENCY_ERROR)
		var n_options: int = len(Settings.SETTINGS[key][Settings.VALUE_NAMES])
		var value_index: int = settings_resource.settings[key]
		assert(value_index >= 0 and value_index < n_options, Errors.CONSISTENCY_ERROR)

	var file: FileAccess = FileAccess.open(settings_file_path, FileAccess.READ)
	if file != null:
		var settings_load_data: Variant = JSON.parse_string(file.get_as_text())
		if settings_load_data is Dictionary:
			var settings_load_dict: Dictionary = settings_load_data as Dictionary
			for key in settings_load_dict:
				if key in settings_resource.settings:
					var value_index: int = get_settings_value_index(key, settings_load_dict[key])
					if value_index != -1:
						settings_resource.settings[key] = value_index
					else:
						push_warning("Ignoring invalid value '", settings_load_dict[key], "' for setting '", key, "'.")
				else:
					push_warning("Ignoring invalid setting '", key, "'.")
		else:
			push_warning("Failed to parse config file, using default settings.")
	else:
		push_warning("Failed to open config file, using default settings.")


func _on_request_setting_update(_sender: Node, key: StringName, value_index: int) -> void:
	var n_options: int = len(Settings.SETTINGS[key][Settings.VALUE_NAMES])
	assert(value_index >= 0 and value_index < n_options, Errors.INVALID_ARGUMENT)
	settings_resource.settings[key] = value_index
	Signals.emit_setting_updated(self, key)


func _on_request_settings_save(_sender: Node) -> void:
	var settings_save_dict: Dictionary = {}
	for key in settings_resource.settings:
		var value_name: String = get_settings_value_name(key, settings_resource.settings[key])
		if value_name:
			settings_save_dict[key] = value_name
		else:
			push_warning("Ignoring invalid index '", settings_resource.settings[key], "' for setting '", key, "'.")
	var file: FileAccess = FileAccess.open(settings_file_path, FileAccess.WRITE)
	if file != null:
		file.store_string("%s\n" % JSON.stringify(settings_save_dict, " ".repeat(2)))
	else:
		push_warning("Failed to save config file.")


func get_settings_value_index(setting_key: String, setting_value_name: String) -> int:
	var n_options: int = len(Settings.SETTINGS[setting_key][Settings.VALUE_NAMES])
	for i in range(n_options):
		if Settings.SETTINGS[setting_key][Settings.VALUE_NAMES][i] == setting_value_name:
			return i
	return -1


func get_settings_value_name(setting_key: String, setting_value_index: int) -> String:
	var n_options: int = len(Settings.SETTINGS[setting_key][Settings.VALUE_NAMES])
	if setting_value_index >= 0 and setting_value_index < n_options:
		return Settings.SETTINGS[setting_key][Settings.VALUE_NAMES][setting_value_index]
	return String()
