# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name NextStateInteractionAction
extends InteractionAction

@export var _state_machine: NodePath


func check(caller: Node3D) -> void:
	super.check(caller)
	var state_machine: StateMachine = caller.get_node(_state_machine) as StateMachine
	assert(state_machine != null, Errors.NULL_NODE)


func interact(caller: Node3D) -> void:
	super.interact(caller)
	var state_machine: StateMachine = caller.get_node(_state_machine) as StateMachine
	state_machine.transition_to_next_state()
