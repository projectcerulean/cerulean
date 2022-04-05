# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later

# Rewrite this file if/when it is possible to create nested const dictionaries.
# https://github.com/godotengine/godot/issues/50285
class_name Settings
extends Node

enum Boolean {
	NO,
	YES,
}

const OPTION_NAME: StringName = &"OPTION_NAME"
const VALUE_NAMES: StringName = &"VALUE_NAMES"
const DEFAULT_VALUE: StringName = &"DEFAULT_VALUE"

const BOOLEAN_VALUE_NAMES: Array[String] = ["No", "Yes"]

const BACKGROUND_MUSIC: StringName = &"BACKGROUND_MUSIC"
const BACKGROUND_MUSIC_OPTION: Dictionary = {
	OPTION_NAME: "Background music",
	VALUE_NAMES: BOOLEAN_VALUE_NAMES,
	DEFAULT_VALUE: Boolean.YES,
}

const CAMERA_X_INVERTED: StringName = &"CAMERA_X_INVERTED"
const CAMERA_X_INVERTED_OPTION: Dictionary = {
	OPTION_NAME: "Invert camera X",
	VALUE_NAMES: BOOLEAN_VALUE_NAMES,
	DEFAULT_VALUE: Boolean.NO,
}

const CAMERA_Y_INVERTED: StringName = &"CAMERA_Y_INVERTED"
const CAMERA_Y_INVERTED_OPTION: Dictionary = {
	OPTION_NAME: "Invert camera Y",
	VALUE_NAMES: BOOLEAN_VALUE_NAMES,
	DEFAULT_VALUE: Boolean.NO,
}

const SETTINGS: Dictionary = {
	BACKGROUND_MUSIC: BACKGROUND_MUSIC_OPTION,
	CAMERA_X_INVERTED: CAMERA_X_INVERTED_OPTION,
	CAMERA_Y_INVERTED: CAMERA_Y_INVERTED_OPTION,
}
