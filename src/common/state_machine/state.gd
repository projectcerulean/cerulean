# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later

# Virtual base class for all states.
# Based on "Finite State Machine in Godot" by GDQuest, https://www.gdquest.com/tutorial/godot/design-patterns/finite-state-machine
class_name State
extends Node

const NEW_STATE: StringName = &"NEW_STATE"
const OLD_STATE: StringName = &"OLD_STATE"


# Virtual function. Called by the state machine upon changing the active state. The `data` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_data: Dictionary) -> void:
	pass


# Virtual function. Called by the state machine before changing the active state. Use this function
# to clean up the state.
func exit(_data: Dictionary) -> void:
	pass


# Virtual function. Corresponds to the `_process()` callback.
func process(_delta: float) -> void:
	pass


# Virtual function. Corresponds to the `_physics_process()` callback.
func physics_process(_delta: float) -> void:
	pass


# Virtual function. Called by the state machine to determine if the state should be changed. Returns
# an empty string if the state should not be changed.
func get_transition() -> StringName:
	return StringName()
