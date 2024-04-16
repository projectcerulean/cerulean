# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name PushButton
extends Area3D

var colliders: Array[Node3D] = []

@onready var state_machine: StateMachine = get_node("StateMachine") as StateMachine


func _ready() -> void:
	assert(state_machine != null, Errors.NULL_NODE)
	assert(state_machine.get_child_count() == 2, Errors.CONSISTENCY_ERROR)


func _on_body_entered(body: Node3D) -> void:
	if body not in colliders:
		colliders.append(body)
	trigger_state_change()


func _on_body_exited(body: Node3D) -> void:
	if body in colliders:
		colliders.erase(body)
	trigger_state_change()


func _on_area_entered(area: Area3D) -> void:
	if area not in colliders:
		colliders.append(area)
	trigger_state_change()


func _on_area_exited(area: Area3D) -> void:
	if area in colliders:
		colliders.erase(area)
	trigger_state_change()


func trigger_state_change() -> void:
	if colliders.size() == 0:
		state_machine.transition_to_state(PuzzleElementStates.DISABLED)
	elif colliders.size() > 0:
		state_machine.transition_to_state(PuzzleElementStates.ENABLED)
