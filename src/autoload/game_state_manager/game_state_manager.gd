# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name GameStateManager
extends Node

@export var _state_resource: Resource

@onready var state_resource: StateResource = _state_resource as StateResource


func _ready() -> void:
	Signals.request_game_pause.connect(self._on_request_game_pause)
	Signals.request_game_unpause.connect(self._on_request_game_unpause)
	Signals.request_dialogue_start.connect(self._on_request_dialogue_start)
	Signals.request_dialogue_finish.connect(self._on_request_dialogue_finish)
	Signals.request_scene_transition_start.connect(self._on_request_scene_transition_start)
	Signals.request_scene_transition_finish.connect(self._on_request_scene_transition_finish)
	Signals.request_scene_change.connect(self._on_request_scene_change)
	Signals.request_game_quit.connect(self._on_request_game_quit)

	assert(state_resource as StateResource != null, Errors.NULL_RESOURCE)


func _on_request_game_pause(_sender: Node) -> void:
	Signals.emit_request_state_change(self, state_resource.state_machine, GameStates.PAUSE)


func _on_request_game_unpause(_sender: Node) -> void:
	Signals.emit_request_state_change(self, state_resource.state_machine, GameStates.GAMEPLAY)


func _on_request_dialogue_start(_sender: Node3D, _dialogue_resource: DialogueResource) -> void:
	Signals.emit_request_state_change(self, state_resource.state_machine, GameStates.DIALOGUE)


func _on_request_dialogue_finish(_sender: Node) -> void:
	Signals.emit_request_state_change(self, state_resource.state_machine, GameStates.GAMEPLAY)


func _on_request_scene_transition_start(_sender: Node, _scene: String, _spawn_point_id: int, _color: Color, _fade_duration: float):
	Signals.emit_request_state_change(self, state_resource.state_machine, GameStates.SCENE_TRANSITION)


func _on_request_scene_transition_finish(_sender: Node) -> void:
	Signals.emit_request_state_change(self, state_resource.state_machine, GameStates.GAMEPLAY)


func _on_request_scene_change(_sender: Node, scene_path: String) -> void:
	get_tree().call_deferred(get_tree().change_scene_to_file.get_method(), scene_path)


func _on_request_game_quit(_sender: Node) -> void:
	get_tree().call_deferred(get_tree().quit.get_method())
