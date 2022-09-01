# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Marker3D

@export var _player_transform_resource: Resource
@export var _player_state_resource: Resource
@export var _game_state_resource: Resource

@export var y_lerp_weight_player_grounded: float = 5.491
@export var y_lerp_weight_player_air: float = 4.345

@export var dialogue_lerp_weight: float = 5.491

var dialogue_target: Node3D
var dialogue_target_offset: Vector3
var dialogue_target_position_start: Vector3

@onready var player_transform_resource: TransformResource = _player_transform_resource as TransformResource
@onready var player_state_resource: StateResource = _player_state_resource as StateResource
@onready var game_state_resource: StateResource = _game_state_resource as StateResource


func _ready() -> void:
	Signals.scene_changed.connect(self._on_scene_changed)
	Signals.request_dialogue_start.connect(self._on_request_dialogue_start)
	assert(player_transform_resource != null, Errors.NULL_RESOURCE)
	assert(player_state_resource != null, Errors.NULL_RESOURCE)
	assert(game_state_resource != null, Errors.NULL_RESOURCE)


func _process(delta: float) -> void:
	match game_state_resource.current_state:
		GameStates.DIALOGUE:
			if dialogue_target != null:
				dialogue_target_offset = Lerp.delta_lerp3(dialogue_target_offset, (dialogue_target.global_position - player_transform_resource.value.origin) / 2.0, dialogue_lerp_weight, delta)
				global_position = dialogue_target_position_start + dialogue_target_offset
		GameStates.GAMEPLAY:
			dialogue_target_offset = Lerp.delta_lerp3(dialogue_target_offset, Vector3.ZERO, dialogue_lerp_weight, delta)
			global_position.x = player_transform_resource.value.origin.x + dialogue_target_offset.x
			global_position.z = player_transform_resource.value.origin.z + dialogue_target_offset.z
			var y_lerp_weight: float = y_lerp_weight_player_grounded if player_state_resource.current_state in [PlayerStates.RUN, PlayerStates.IDLE] else y_lerp_weight_player_air
			global_position.y = Lerp.delta_lerp(global_position.y, player_transform_resource.value.origin.y, y_lerp_weight, delta)


func _on_scene_changed(_sender: Node) -> void:
	global_position = player_transform_resource.value.origin


func _on_request_dialogue_start(sender: Node3D, _dialogue_resource: DialogueResource) -> void:
	dialogue_target = sender
	dialogue_target_offset = Vector3.ZERO
	dialogue_target_position_start = global_position
