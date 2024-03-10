# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name Main
extends Node

@export var scene_default: StringName
@export var scene_transition_fade_duration: float = 0.5

@onready var scene_manager: SceneManager = get_node("Singletons/SceneManager") as SceneManager


func _ready() -> void:
	assert(scene_manager != null, Errors.NULL_NODE)
	await get_tree().process_frame
	await get_tree().physics_frame
	load_default_scene()


func load_default_scene() -> void:
	var scene_path: String = scene_default
	if not scene_path.begins_with("res://"):
		scene_path = Levels.LEVELS[scene_default][Levels.LEVEL_PATH]
	var spawn_point_id: int = 0
	var scene_transition_color: Color = RenderingServer.get_default_clear_color()
	Signals.emit_request_scene_transition_start(self, scene_path, spawn_point_id, scene_transition_color, scene_transition_fade_duration)


# For unit testing
func get_current_scene() -> Scene:
	assert(scene_manager.get_child_count() == 1, Errors.CONSISTENCY_ERROR)
	var scene: Scene = scene_manager.get_child(0)
	assert(scene != null, Errors.NULL_NODE)
	return scene
