# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name Levels
extends Node

const LEVEL_NAME: StringName = &"LEVEL_NAME"
const LEVEL_PATH: StringName = &"LEVEL_PATH"

const TEST_DUNGEON: StringName = &"TEST_DUNGEON"
const TEST_SCENE: StringName = &"TEST_SCENE"

const LEVELS: Dictionary = {
	TEST_DUNGEON: {
		LEVEL_NAME: "Test dungeon",
		LEVEL_PATH: "res://src/levels/test_dungeon/test_dungeon.tscn",
	},
	TEST_SCENE: {
		LEVEL_NAME: "Test scene",
		LEVEL_PATH: "res://src/levels/test_scene/test_scene.tscn",
	},
}
