# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Node

@export var _settings_resource: Resource
@export var settings_file_path: String = "user://settings_resource.cfg"

@onready var settings_resource: SettingsResource = _settings_resource as SettingsResource


func _ready() -> void:
	Signals.request_setting_update.connect(self._on_request_setting_update)
	Signals.request_settings_save.connect(self._on_request_settings_save)
	assert(settings_resource != null, Errors.NULL_RESOURCE)
	assert(settings_resource.settings.size() == Settings.SETTINGS.size(), Errors.CONSISTENCY_ERROR)
	for i in range(settings_resource.settings.size()):
		assert(settings_resource.settings.keys()[i] == Settings.SETTINGS.keys()[i], Errors.CONSISTENCY_ERROR)
		assert(Settings.SETTINGS[Settings.SETTINGS.keys()[i]].VALUES.size() == Settings.SETTINGS[Settings.SETTINGS.keys()[i]].VALUE_NAMES.size(), Errors.CONSISTENCY_ERROR)

	for key in settings_resource.settings:
		Signals.emit_request_setting_update(self, key, Settings.SETTINGS[key][Settings.DEFAULT_VALUE_INDEX])

	var config_file: ConfigFile = ConfigFile.new()
	if config_file.load(settings_file_path) == OK:
		for section in config_file.get_sections():
			for key in config_file.get_section_keys(section):
				if key in settings_resource.settings:
					var value: String = str(config_file.get_value(section, key))
					if value.is_valid_int():
						Signals.emit_request_setting_update(self, key, value.to_int())


func _on_request_setting_update(_sender: Node, key: StringName, value_index: int) -> void:
	var n_options: int = len(Settings.SETTINGS[key][Settings.VALUE_NAMES])
	assert(value_index >= 0 and value_index < n_options, Errors.INVALID_ARGUMENT)
	settings_resource.settings[key] = value_index
	Signals.emit_setting_updated(self, key, value_index)


func _on_request_settings_save(_sender: Node) -> void:
	var config_file: ConfigFile = ConfigFile.new()
	for key in settings_resource.settings:
		config_file.set_value("Settings", key, settings_resource.settings[key])
	config_file.save(settings_file_path)
