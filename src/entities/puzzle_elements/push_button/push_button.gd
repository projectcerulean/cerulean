# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name PushButton
extends Area3D

var bodies: Array[Node3D] = []

@onready var state_machine: Node = get_node("StateMachine") as Node


func _ready() -> void:
	assert(state_machine != null, Errors.NULL_NODE)
	assert(state_machine.get_child_count() == 2, Errors.CONSISTENCY_ERROR)


func _on_body_entered(body: Node3D) -> void:
	if body not in bodies:
		bodies.append(body)
	if bodies.size() > 0:
		Signals.emit_request_state_change(self, state_machine, PuzzleElementStates.ENABLED)


func _on_body_exited(body: Node3D) -> void:
	if body in bodies:
		bodies.erase(body)
	if bodies.size() == 0:
		Signals.emit_request_state_change(self, state_machine, PuzzleElementStates.DISABLED)
