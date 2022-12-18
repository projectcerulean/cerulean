# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Node

@export var _settings_resource: Resource

@onready var settings_resource: SettingsResource = _settings_resource as SettingsResource


func _ready() -> void:
	Signals.setting_updated.connect(_on_setting_updated)
	assert(settings_resource != null, Errors.NULL_RESOURCE)
	update_settings()


func _on_setting_updated(_sender: Node, _key: StringName) -> void:
	update_settings()


func update_settings() -> void:
	DisplayServer.window_set_vsync_mode(Settings.SETTINGS.VSYNC.VALUES[settings_resource.settings[Settings.VSYNC]])
	get_viewport().msaa_2d = Settings.SETTINGS.MSAA.VALUES[settings_resource.settings[Settings.MSAA]]
	get_viewport().msaa_3d = Settings.SETTINGS.MSAA.VALUES[settings_resource.settings[Settings.MSAA]]
	get_viewport().scaling_3d_scale = Settings.SETTINGS.RENDER_SCALE.VALUES[settings_resource.settings[Settings.RENDER_SCALE]]
