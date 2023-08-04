# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name Switch
extends StaticBody3D

@onready var state_machine: StateMachine = get_node("StateMachine") as StateMachine


func _ready() -> void:
	assert(state_machine != null, Errors.NULL_NODE)
	assert(state_machine.get_child_count() == 2, Errors.CONSISTENCY_ERROR)

func flip() -> void:
	state_machine.transition_to_next_state()
