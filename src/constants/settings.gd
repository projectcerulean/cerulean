# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name Settings
extends Node

const OPTION_NAME: StringName = &"OPTION_NAME"
const VALUES: StringName = &"VALUES"
const VALUE_NAMES: StringName = &"VALUE_NAMES"
const DEFAULT_VALUE_INDEX: StringName = &"DEFAULT_VALUE_INDEX"

const BOOLEAN_VALUES: Array[int] = [int(false), int(true)]
const BOOLEAN_VALUE_NAMES: Array[String] = ["No", "Yes"]

const BACKGROUND_MUSIC: StringName = &"BACKGROUND_MUSIC"
const CAMERA_X_INVERTED: StringName = &"CAMERA_X_INVERTED"
const CAMERA_Y_INVERTED: StringName = &"CAMERA_Y_INVERTED"
const FIELD_OF_VIEW: StringName = &"FIELD_OF_VIEW"
const VSYNC: StringName = &"VSYNC"

const SETTINGS: Dictionary = {
	BACKGROUND_MUSIC: {
		OPTION_NAME: "Background music",
		VALUES: BOOLEAN_VALUES,
		VALUE_NAMES: BOOLEAN_VALUE_NAMES,
		DEFAULT_VALUE_INDEX: 1,
	},
	CAMERA_X_INVERTED: {
		OPTION_NAME: "Invert camera X",
		VALUES: BOOLEAN_VALUES,
		VALUE_NAMES: BOOLEAN_VALUE_NAMES,
		DEFAULT_VALUE_INDEX: 0,
	},
	CAMERA_Y_INVERTED: {
		OPTION_NAME: "Invert camera Y",
		VALUES: BOOLEAN_VALUES,
		VALUE_NAMES: BOOLEAN_VALUE_NAMES,
		DEFAULT_VALUE_INDEX: 0,
	},
	FIELD_OF_VIEW: {
		OPTION_NAME: "Field of view",
		VALUES: [60, 65, 70, 75, 80, 85, 90, 95, 100, 105, 110, 115, 120],
		VALUE_NAMES: ["60", "65", "70", "75", "80", "85", "90", "95", "100", "105", "110", "115", "120"],
		DEFAULT_VALUE_INDEX: 6,
	},
	VSYNC: {
		OPTION_NAME: "VSync",
		VALUES: BOOLEAN_VALUES,
		VALUE_NAMES: BOOLEAN_VALUE_NAMES,
		DEFAULT_VALUE_INDEX: 1,
	},
}
