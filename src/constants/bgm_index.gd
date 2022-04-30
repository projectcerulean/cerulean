# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name BgmIndex
extends Node

const BGM_PATH: StringName = &"BGM_PATH"
const BGM_BPM: StringName = &"BGM_BPM"

const SEA_AND_SKY: StringName = &"SEA_AND_SKY"
const WATERWORKS: StringName = &"WATERWORKS"

const BGM_INDEX: Dictionary = {
	SEA_AND_SKY: {
		BGM_PATH: "res://src/sound/bgm/bgm_resources/seaandsky.tres",
		BGM_BPM: 92,
	},
	WATERWORKS: {
		BGM_PATH: "res://src/sound/bgm/bgm_resources/waterworks.tres",
		BGM_BPM: 90,
	},
}
