# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name GameStateManager
extends Node

@onready var state_machine: StateMachine = get_node("StateMachine") as StateMachine


func _ready() -> void:
	Signals.request_game_pause.connect(self._on_request_game_pause)
	Signals.request_game_unpause.connect(self._on_request_game_unpause)
	Signals.request_dialogue_start.connect(self._on_request_dialogue_start)
	Signals.request_dialogue_finish.connect(self._on_request_dialogue_finish)
	Signals.request_scene_transition_start.connect(self._on_request_scene_transition_start)
	Signals.request_scene_transition_finish.connect(self._on_request_scene_transition_finish)
	Signals.request_loading_screen_start.connect(self._on_request_loading_screen_start)
	Signals.request_game_quit.connect(self._on_request_game_quit)

	assert(state_machine != null, Errors.NULL_NODE)


func _on_request_game_pause(_sender: NodePath) -> void:
	state_machine.transition_to_state(GameStates.PAUSE)


func _on_request_game_unpause(_sender: NodePath) -> void:
	state_machine.transition_to_state(GameStates.GAMEPLAY)


func _on_request_dialogue_start(_sender: NodePath, _dialogue_resource: DialogueResource) -> void:
	state_machine.transition_to_state(GameStates.DIALOGUE)


func _on_request_dialogue_finish(_sender: NodePath) -> void:
	state_machine.transition_to_state(GameStates.GAMEPLAY)


func _on_request_scene_transition_start(_sender: NodePath, _scene: String, _spawn_point_id: int, _color: Color, _fade_duration: float):
	state_machine.transition_to_state(GameStates.SCENE_TRANSITION)


func _on_request_scene_transition_finish(_sender: NodePath) -> void:
	state_machine.transition_to_state(GameStates.GAMEPLAY)


func _on_request_loading_screen_start(_sender: NodePath) -> void:
	state_machine.transition_to_state(GameStates.LOADING_SCREEN)


func _on_request_game_quit(_sender: NodePath) -> void:
	get_tree().call_deferred(get_tree().quit.get_method())
