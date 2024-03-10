# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name Indicator
extends Node3D

@onready var input_node: Node = get_parent() if get_index() == 0 else get_parent().get_child(get_index() - 1)
@onready var state_machine: StateMachine = get_node("StateMachine") as StateMachine


func _ready() -> void:
	Signals.state_entered.connect(self._on_state_entered)
	assert(input_node != null, Errors.NULL_NODE)
	assert(state_machine != null, Errors.NULL_NODE)
	assert(state_machine.get_child_count() == 2, Errors.CONSISTENCY_ERROR)


func _on_state_entered(sender: NodePath, state: StringName, _data: Dictionary) -> void:
	var sender_state_machine: StateMachine = get_node(sender) as StateMachine
	if is_instance_valid(sender_state_machine):
		var sender_state_machine_owner: Node = sender_state_machine.owner
		if is_instance_valid(sender_state_machine_owner) and sender_state_machine_owner == input_node:
			state_machine.transition_to_state(state)
