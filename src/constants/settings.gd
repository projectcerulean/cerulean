# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
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
const CAMERA_X_INVERTED: StringName = &"CAMERA_X_INVERTED"
const CAMERA_Y_INVERTED: StringName = &"CAMERA_Y_INVERTED"

const SETTINGS: Dictionary = {
	BACKGROUND_MUSIC: {
		OPTION_NAME: "Background music",
		VALUE_NAMES: BOOLEAN_VALUE_NAMES,
		DEFAULT_VALUE: Boolean.YES,
	},
	CAMERA_X_INVERTED: {
		OPTION_NAME: "Invert camera X",
		VALUE_NAMES: BOOLEAN_VALUE_NAMES,
		DEFAULT_VALUE: Boolean.NO,
	},
	CAMERA_Y_INVERTED: {
		OPTION_NAME: "Invert camera Y",
		VALUE_NAMES: BOOLEAN_VALUE_NAMES,
		DEFAULT_VALUE: Boolean.NO,
	},
}
