# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name SettingsResource
extends Resource

var settings: Dictionary = {
	Settings.BACKGROUND_MUSIC: Settings.BACKGROUND_MUSIC_OPTION.DEFAULT_VALUE,
	Settings.CAMERA_X_INVERTED: Settings.CAMERA_X_INVERTED_OPTION.DEFAULT_VALUE,
	Settings.CAMERA_Y_INVERTED: Settings.CAMERA_Y_INVERTED_OPTION.DEFAULT_VALUE,
}
