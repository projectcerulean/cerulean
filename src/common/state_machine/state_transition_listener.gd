# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name StateTransitionListener
extends Node

@export var _target_states: Array[NodePath]

var target_states: Array[StringName]
var target_state_machine: NodePath
var is_in_target_state: bool = false


func _ready() -> void:
	Signals.state_entered.connect(self._on_state_entered)
	Signals.state_exited.connect(self._on_state_exited)

	assert(_target_states.size() > 0, Errors.NULL_NODE)
	target_states.resize(len(_target_states))
	for i: int in range(len(_target_states)):
		target_states[i] = get_node(_target_states[i]).name
		assert(target_states[i] != null, Errors.NULL_NODE)
		for j: int in range(len(_target_states)):
			if i == j:
				continue
			assert(target_states[i] != target_states[j], Errors.INVALID_ARGUMENT)

	target_state_machine = get_node(_target_states[0]).get_parent().get_path()
	assert(target_state_machine != null, Errors.NULL_NODE)
	for i: int in range(len(_target_states)):
		assert(get_node(_target_states[i]).get_parent().get_path() == target_state_machine, Errors.CONSISTENCY_ERROR)


func _on_state_entered(sender: NodePath, _state: StringName, data: Dictionary) -> void:
	if sender == target_state_machine:
		if data[State.NEW_STATE] in target_states and data[State.OLD_STATE] not in target_states:
			is_in_target_state = true
			_on_target_state_entered(data)


func _on_state_exited(sender: NodePath, _state: StringName, data: Dictionary) -> void:
	if sender == target_state_machine:
		if data[State.NEW_STATE] not in target_states and data[State.OLD_STATE] in target_states:
			is_in_target_state = false
			_on_target_state_exited(data)


# Override this
func _on_target_state_entered(_data: Dictionary) -> void:
	pass


# Override this
func _on_target_state_exited(_data: Dictionary) -> void:
	pass
