# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Marker3D

@export var player_transform_resource: TransformResource
@export var player_state_resource: StateResource
@export var game_state_resource: StateResource

@export var y_lerp_weight_player_grounded: float = 5.491
@export var y_lerp_weight_player_air: float = 4.345

@export var dialogue_lerp_weight: float = 5.491

var dialogue_target: NodePath
var dialogue_target_offset: Vector3
var dialogue_target_position_start: Vector3

@onready var transform_resource_manager: TransformResourceManager = get_node("TransformResourceManager") as TransformResourceManager


func _ready() -> void:
	Signals.scene_changed.connect(self._on_scene_changed)
	Signals.request_dialogue_start.connect(self._on_request_dialogue_start)
	assert(player_transform_resource != null, Errors.NULL_RESOURCE)
	assert(player_state_resource != null, Errors.NULL_RESOURCE)
	assert(game_state_resource != null, Errors.NULL_RESOURCE)
	assert(transform_resource_manager != null, Errors.NULL_NODE)


func _process(delta: float) -> void:
	match game_state_resource.get_current_state():
		GameStates.DIALOGUE:
			if dialogue_target:
				var dialogue_target_node: Node3D = get_node(dialogue_target) as Node3D
				if is_instance_valid(dialogue_target_node):
					dialogue_target_offset = Lerp.delta_lerp3(dialogue_target_offset, (dialogue_target_node.global_position - player_transform_resource.get_value().origin) / 2.0, dialogue_lerp_weight, delta)
					global_position = dialogue_target_position_start + dialogue_target_offset
		GameStates.GAMEPLAY:
			if player_transform_resource.is_owned():
				dialogue_target_offset = Lerp.delta_lerp3(dialogue_target_offset, Vector3.ZERO, dialogue_lerp_weight, delta)
				global_position.x = player_transform_resource.get_value().origin.x + dialogue_target_offset.x
				global_position.z = player_transform_resource.get_value().origin.z + dialogue_target_offset.z
				var y_lerp_weight: float = y_lerp_weight_player_grounded if player_state_resource.get_current_state() in [PlayerStates.RUN, PlayerStates.IDLE] else y_lerp_weight_player_air
				global_position.y = Lerp.delta_lerp(global_position.y, player_transform_resource.get_value().origin.y, y_lerp_weight, delta)


func _on_scene_changed(_sender: NodePath) -> void:
	if player_transform_resource.is_owned():
		global_transform = player_transform_resource.get_value()
	transform_resource_manager.update_resource()


func _on_request_dialogue_start(sender: NodePath, _dialogue_resource: DialogueResource) -> void:
	dialogue_target = sender
	dialogue_target_offset = Vector3.ZERO
	dialogue_target_position_start = global_position
