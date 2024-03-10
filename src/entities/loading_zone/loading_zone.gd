# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Area3D

@export var scene_key: StringName
@export var spawn_point_id: int = -1
@export var scene_transition_color: Color = Color(0.02, 0.02, 0.02)
@export var fade_duration: float = 1.5

@onready var mesh_instance: MeshInstance3D = get_node("MeshInstance3D") as MeshInstance3D
@onready var shader_material: ShaderMaterial = mesh_instance.get_surface_override_material(0) as ShaderMaterial


func _ready() -> void:
	assert(scene_key != null, Errors.NULL_NODE)
	assert(scene_key in Levels.LEVELS, Errors.INVALID_ARGUMENT)
	assert(spawn_point_id >= 0, Errors.INVALID_ARGUMENT)
	assert(mesh_instance != null, Errors.NULL_NODE)
	assert(shader_material != null, Errors.NULL_RESOURCE)

	shader_material.set_shader_parameter("color", scene_transition_color)


func _on_body_entered(body: Node3D) -> void:
	assert(body.name == &"Player", Errors.CONSISTENCY_ERROR)
	var scene_path: String = Levels.LEVELS[scene_key][Levels.LEVEL_PATH]
	Signals.emit_request_scene_transition_start(self, scene_path, spawn_point_id, scene_transition_color, fade_duration)
