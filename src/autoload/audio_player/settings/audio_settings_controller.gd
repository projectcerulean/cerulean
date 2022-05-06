# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Node

@export var _settings_resource: Resource

@onready var settings_resource: SettingsResource = _settings_resource as SettingsResource
@onready var bus_index_bgm: int = AudioServer.get_bus_index(AudioBuses.BGM)


func _ready() -> void:
	Signals.setting_updated.connect(_on_setting_updated)
	assert(settings_resource != null, Errors.NULL_RESOURCE)
	assert(bus_index_bgm >= 0, Errors.INVALID_AUDIO_BUS)
	AudioServer.set_bus_mute(bus_index_bgm, not Settings.SETTINGS.BACKGROUND_MUSIC.VALUES[settings_resource.settings[Settings.BACKGROUND_MUSIC]])


func _on_setting_updated(_sender: Node, key: StringName) -> void:
	if key == Settings.BACKGROUND_MUSIC:
		AudioServer.set_bus_mute(bus_index_bgm, not Settings.SETTINGS.BACKGROUND_MUSIC.VALUES[settings_resource.settings[Settings.BACKGROUND_MUSIC]])
