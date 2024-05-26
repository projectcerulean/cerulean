# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name DialogueManager
extends Control

@export var text_reveal_speed: float = 180.0
@export var game_state_resource: StateResource

var dialogue_resource: DialogueResource = null
var line_index: int = 0

@onready var label: Label = get_node("Label") as Label
@onready var state_machine: StateMachine = get_node("StateMachine") as StateMachine


func _ready() -> void:
	Signals.request_dialogue_start.connect(self._on_request_dialogue_start)
	Signals.state_entered.connect(self._on_state_entered)
	Signals.state_exited.connect(self._on_state_exited)

	assert(label != null, Errors.NULL_NODE)
	assert(state_machine != null, Errors.NULL_NODE)
	assert(game_state_resource != null, Errors.NULL_RESOURCE)
	self.visible = false


func _on_request_dialogue_start(_sender: NodePath, dialogue_resource_new: DialogueResource) -> void:
	assert(dialogue_resource_new != null, Errors.NULL_RESOURCE)
	dialogue_resource = dialogue_resource_new
	line_index = -1


func _on_request_dialogue_finish(_sender: NodePath) -> void:
	dialogue_resource = null


func _on_state_entered(sender: NodePath, state: StringName, _data: Dictionary) -> void:
	if (
		game_state_resource.is_owned()
		and sender == game_state_resource.get_state_machine()
		and state == GameStates.DIALOGUE
	):
		state_machine.transition_to_state(DialogueStates.OUTPUT)
		self.visible = true


func _on_state_exited(sender: NodePath, state: StringName, _data: Dictionary) -> void:
	if (
		game_state_resource.is_owned()
		and sender == game_state_resource.get_state_machine()
		and state == GameStates.DIALOGUE
	):
		self.visible = false
