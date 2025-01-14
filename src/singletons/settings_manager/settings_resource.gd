# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name SettingsResource
extends Resource

var settings: Dictionary = {
	Settings.BACKGROUND_MUSIC: Settings.SETTINGS[Settings.BACKGROUND_MUSIC].DEFAULT_VALUE_INDEX,
	Settings.CAMERA_X_INVERTED: Settings.SETTINGS[Settings.CAMERA_X_INVERTED].DEFAULT_VALUE_INDEX,
	Settings.CAMERA_Y_INVERTED: Settings.SETTINGS[Settings.CAMERA_Y_INVERTED].DEFAULT_VALUE_INDEX,
	Settings.FIELD_OF_VIEW: Settings.SETTINGS[Settings.FIELD_OF_VIEW].DEFAULT_VALUE_INDEX,
	Settings.MSAA: Settings.SETTINGS[Settings.MSAA].DEFAULT_VALUE_INDEX,
	Settings.RENDER_SCALE: Settings.SETTINGS[Settings.RENDER_SCALE].DEFAULT_VALUE_INDEX,
	Settings.SCREEN_SHAKE: Settings.SETTINGS[Settings.SCREEN_SHAKE].DEFAULT_VALUE_INDEX,
	Settings.VSYNC: Settings.SETTINGS[Settings.VSYNC].DEFAULT_VALUE_INDEX,
	Settings.MAX_FPS: Settings.SETTINGS[Settings.MAX_FPS].DEFAULT_VALUE_INDEX,
}
