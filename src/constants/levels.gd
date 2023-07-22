# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name Levels
extends Node

const LEVEL_NAME: StringName = &"LEVEL_NAME"
const LEVEL_PATH: StringName = &"LEVEL_PATH"

const PROTOTYPE_DUNGEON: StringName = &"PROTOTYPE_DUNGEON"
const PROTOTYPE_SCENE: StringName = &"PROTOTYPE_SCENE"

const LEVELS: Dictionary = {
	PROTOTYPE_DUNGEON: {
		LEVEL_NAME: "Prototype dungeon",
		LEVEL_PATH: "res://src/levels/prototype_dungeon/prototype_dungeon.tscn",
	},
	PROTOTYPE_SCENE: {
		LEVEL_NAME: "Prototype scene",
		LEVEL_PATH: "res://src/levels/prototype_scene/prototype_scene.tscn",
	},
}
