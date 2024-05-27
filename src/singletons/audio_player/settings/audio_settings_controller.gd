# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Node

const volume_db_high: float = 0.0
const volume_db_low: float = -80.0

@export var bgm_change_tween_time: float = 0.5
@export var _settings_resource: Resource

@onready var settings_resource: SettingsResource = _settings_resource as SettingsResource
@onready var bus_index_bgm: int = AudioServer.get_bus_index(AudioBuses.BGM)
@onready var bgm_tween: Tween


var bgm_volume: float:
	get:
		return bgm_volume
	set(value):
		value = clampf(value, db_to_linear(volume_db_low), db_to_linear(volume_db_high))
		AudioServer.set_bus_volume_db(bus_index_bgm, linear_to_db(value))
		bgm_volume = value


func _ready() -> void:
	Signals.setting_updated.connect(_on_setting_updated)
	assert(settings_resource != null, Errors.NULL_RESOURCE)
	assert(bus_index_bgm >= 0, Errors.INVALID_AUDIO_BUS)
	bgm_volume = float(Settings.SETTINGS.BACKGROUND_MUSIC.VALUES[settings_resource.settings[Settings.BACKGROUND_MUSIC]])
	AudioServer.set_bus_mute(bus_index_bgm, not Settings.SETTINGS.BACKGROUND_MUSIC.VALUES[settings_resource.settings[Settings.BACKGROUND_MUSIC]])


func _on_setting_updated(_sender: NodePath, key: StringName) -> void:
	if key == Settings.BACKGROUND_MUSIC:
		AudioServer.set_bus_mute(bus_index_bgm, false)
		if bgm_tween != null:
			bgm_tween.kill()
		bgm_tween = create_tween()
		bgm_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		bgm_tween.set_trans(Tween.TRANS_QUINT)
		bgm_tween.set_ease(Tween.EASE_OUT)
		bgm_tween.tween_property(self, "bgm_volume", float(Settings.SETTINGS.BACKGROUND_MUSIC.VALUES[settings_resource.settings[Settings.BACKGROUND_MUSIC]]), bgm_change_tween_time)
		bgm_tween.tween_callback(bgm_tween_callback)


func bgm_tween_callback() -> void:
	AudioServer.set_bus_mute(bus_index_bgm, not Settings.SETTINGS.BACKGROUND_MUSIC.VALUES[settings_resource.settings[Settings.BACKGROUND_MUSIC]])
