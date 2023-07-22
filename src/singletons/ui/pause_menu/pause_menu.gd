# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name PauseMenu
extends Control

@export var game_state_resource: StateResource
@export var sfx_resource_select: SfxResource
@export var scene_info_resource: SceneInfoResource
@export var scene_transition_color: Color = Color.WHITE_SMOKE
@export var scene_transition_fade_duration: float = 0.5


func _ready() -> void:
	Signals.state_entered.connect(self._on_state_entered)
	Signals.state_exited.connect(self._on_state_exited)

	assert(game_state_resource != null, Errors.NULL_RESOURCE)
	assert(sfx_resource_select != null, Errors.NULL_RESOURCE)
	assert(scene_info_resource != null, Errors.NULL_RESOURCE)
	self.visible = false


func _on_state_entered(sender: Node, state: StringName, _data: Dictionary) -> void:
	if sender == game_state_resource.state_machine and state == GameStates.PAUSE:
		self.visible = true


func _on_state_exited(sender: Node, state: StringName, _data: Dictionary) -> void:
	if sender == game_state_resource.state_machine and state == GameStates.PAUSE:
		self.visible = false
