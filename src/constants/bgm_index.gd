# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
# Rewrite this file if/when it is possible to create nested const dictionaries.
# https://github.com/godotengine/godot/issues/50285
class_name BgmIndex
extends Node

const BGM_PATH: StringName = &"BGM_PATH"
const BGM_BPM: StringName = &"BGM_BPM"

const SEA_AND_SKY: StringName = &"SEA_AND_SKY"
const SEA_AND_SKY_PARAMS: Dictionary = {
	BGM_PATH: "res://src/sound/bgm/bgm_resources/seaandsky.tres",
	BGM_BPM: 92,
}

const WATERWORKS: StringName = &"WATERWORKS"
const WATERWORKS_PARAMS: Dictionary = {
	BGM_PATH: "res://src/sound/bgm/bgm_resources/waterworks.tres",
	BGM_BPM: 90,
}

const BGM_INDEX: Dictionary = {
	SEA_AND_SKY: SEA_AND_SKY_PARAMS,
	WATERWORKS: WATERWORKS_PARAMS,
}
