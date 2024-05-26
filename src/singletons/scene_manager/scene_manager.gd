# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name SceneManager
extends Node

@export var game_state_resource: StateResource
@export var scene_info_resource: SceneInfoResource

var scene_path_next: String = String()
var spawn_point_id_next: int = 0


func _enter_tree() -> void:
	assert(scene_info_resource, Errors.NULL_RESOURCE)
	scene_info_resource.claim_ownership(self)


func _exit_tree() -> void:
	scene_info_resource.release_ownership(self)


func _ready() -> void:
	Signals.request_scene_change.connect(_on_request_scene_change)
	Signals.resource_load_completed.connect(_on_resource_load_completed)
	Signals.state_entered.connect(_on_state_entered)


func _on_state_entered(sender: NodePath, state: StringName, _data: Dictionary) -> void:
	if sender == game_state_resource.get_state_machine() and state == GameStates.LOADING_SCREEN:
		if get_child_count() > 0:
			assert(get_child_count() == 1, Errors.CONSISTENCY_ERROR)
			get_child(0).queue_free()
		while get_child_count() > 0:
			await get_tree().process_frame
		Signals.emit_request_resource_load(self, scene_path_next)


func _on_request_scene_change(_sender: NodePath, scene_path: String, spawn_point_id: int) -> void:
	assert(scene_path_next == String(), Errors.CONSISTENCY_ERROR)
	scene_path_next = scene_path
	spawn_point_id_next = spawn_point_id
	Signals.emit_request_loading_screen_start(self)


func _on_resource_load_completed(_sender: NodePath, resource_path: String, resource: Resource) -> void:
	if resource_path != scene_path_next:
		return

	assert(get_child_count() == 0, Errors.CONSISTENCY_ERROR)
	var packed_scene: PackedScene = resource as PackedScene
	assert(packed_scene != null, Errors.NULL_RESOURCE)

	scene_info_resource.set_scene_path(self, scene_path_next)
	scene_info_resource.set_spawn_point_id(self, spawn_point_id_next)
	scene_path_next = String()
	spawn_point_id_next = 0

	var scene: Scene = packed_scene.instantiate()
	assert(scene != null, Errors.NULL_NODE)
	add_child(scene)
