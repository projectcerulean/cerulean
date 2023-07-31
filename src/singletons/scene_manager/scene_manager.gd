# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name SceneManager
extends Node

@export var scene_default: StringName
@export var scene_info_resource: SceneInfoResource

var scene_path_next: String = String()
var spawn_point_id_next: int = 0


func _ready() -> void:
	Signals.request_scene_change.connect(_on_request_scene_change)
	Signals.resource_load_completed.connect(_on_resource_load_completed)

	assert(scene_default, Errors.INVALID_ARGUMENT)
	assert(scene_info_resource, Errors.NULL_RESOURCE)
	call_deferred(load_default_scene.get_method())


func load_default_scene() -> void:
	assert(get_child_count() == 0, Errors.CONSISTENCY_ERROR)
	var scene_path: String = scene_default
	if not scene_path.begins_with("res://"):
		scene_path = Levels.LEVELS[scene_default][Levels.LEVEL_PATH]
	load_scene(scene_path, 0)


func load_scene(scene_path: String, spawn_point_id: int) -> void:
	assert(scene_path_next == String(), Errors.CONSISTENCY_ERROR)
	if get_child_count() > 0:
		assert(get_child_count() == 1, Errors.CONSISTENCY_ERROR)
		get_child(0).queue_free()
	while get_child_count() > 0:
		await get_tree().process_frame
	scene_path_next = scene_path
	spawn_point_id_next = spawn_point_id
	Signals.emit_request_resource_load(self, scene_path)


func _on_request_scene_change(_sender: NodePath, scene_path: String, spawn_point_id: int) -> void:
	assert(get_child_count() == 1, Errors.CONSISTENCY_ERROR)
	load_scene(scene_path, spawn_point_id)


func _on_resource_load_completed(_sender: NodePath, resource_path: String, resource: Resource) -> void:
	if resource_path != scene_path_next:
		return

	assert(get_child_count() == 0, Errors.CONSISTENCY_ERROR)
	var packed_scene: PackedScene = resource as PackedScene
	assert(packed_scene != null, Errors.NULL_RESOURCE)

	scene_info_resource.scene_path = scene_path_next
	scene_info_resource.spawn_point_id = spawn_point_id_next
	scene_path_next = String()
	spawn_point_id_next = 0

	var node: Node = packed_scene.instantiate()
	add_child(node)
