# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later

# Rewrite this file if/when it is possible to create nested const dictionaries.
# https://github.com/godotengine/godot/issues/50285
class_name Levels
extends Node

const LEVEL_NAME: StringName = &"LEVEL_NAME"
const LEVEL_PATH: StringName = &"LEVEL_PATH"

const TEST_DUNGEON: StringName = &"TEST_DUNGEON"
const TEST_DUNGEON_PARAMS: Dictionary = {
	LEVEL_NAME: "Test dungeon",
	LEVEL_PATH: "res://src/levels/test_dungeon/test_dungeon.tscn",
}

const TEST_SCENE: StringName = &"TEST_SCENE"
const TEST_SCENE_PARAMS: Dictionary = {
	LEVEL_NAME: "Test scene",
	LEVEL_PATH: "res://src/levels/test_scene/test_scene.tscn",
}

const LEVELS: Dictionary = {
	TEST_DUNGEON: TEST_DUNGEON_PARAMS,
	TEST_SCENE: TEST_SCENE_PARAMS,
}
