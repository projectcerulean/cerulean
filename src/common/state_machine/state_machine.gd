# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later

# Generic state machine. Initializes states and delegates engine callbacks
# (_process, _physics_process, _unhandled_input) to the active state.
# Based on "Finite State Machine in Godot" by GDQuest, https://www.gdquest.com/tutorial/godot/design-patterns/finite-state-machine
@tool
class_name StateMachine
extends Node

const PERSISTENT_STATE_KEY: StringName = &"STATE"

enum TRANSITION_FRAME {
	PROCESS,
	PHYSICS_PROCESS,
};

# Path to the initial active state. We export it to be able to pick the initial state in the inspector.
@export var initial_state: State:
	set(value):
		if not is_same(value, initial_state):
			initial_state = value
			update_configuration_warnings()

# When to handle state transitions.
@export var transition_frame: TRANSITION_FRAME = TRANSITION_FRAME.PROCESS

# Optional data resource for storing persistent state
@export var persistent_data_resource: PersistentDataResource

var current_state: State = null
var is_state_change_pending: bool = false


# Enter the initial state when initializing the state machine.
func _ready() -> void:
	if not Engine.is_editor_hint():
		assert(initial_state != null, Errors.NULL_NODE)
		assert(initial_state in get_children(), Errors.INVALID_ARGUMENT)

		var current_state: State = initial_state

		if persistent_data_resource != null:
			var persistent_state_index: int = persistent_data_resource.get_int(
				self,
				PERSISTENT_STATE_KEY,
				initial_state.get_index(),
			)
			current_state = get_child(persistent_state_index) as State
			assert(current_state != null, Errors.NULL_NODE)

		transition_to_state(current_state.name)


# Delegate `_process` callback to the active state.
func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		if current_state == null or is_state_change_pending:
			return

		current_state.process(delta)

		if transition_frame == TRANSITION_FRAME.PROCESS:
			var target_state: StringName = current_state.get_transition()
			if target_state != StringName():
				transition_to_state(target_state)


# Delegate `_physics_process` callback to the active state.
func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint():
		if current_state == null or is_state_change_pending:
			return

		current_state.physics_process(delta)

		if transition_frame == TRANSITION_FRAME.PHYSICS_PROCESS:
			var target_state: StringName = current_state.get_transition()
			if target_state != StringName():
				transition_to_state(target_state)


# This function calls the current state's exit() function, then changes the active state,
# and calls its enter function.
# It optionally takes a `data` dictionary to pass to the next state's enter() function.
func transition_to_state(target_state: StringName, data: Dictionary = {}) -> void:
	if not Engine.is_editor_hint():
		call_deferred(transition_to_deferred.get_method(), target_state, data)
		is_state_change_pending = true


func transition_to_next_state(data: Dictionary = {}) -> void:
	if not Engine.is_editor_hint():
		var current_state_index: int = -1
		for i in range(get_child_count()):
			if get_children()[i] == current_state:
				current_state_index = i
				break
		assert(current_state_index >= 0, Errors.CONSISTENCY_ERROR)

		var next_state_index: int = (current_state_index + 1) % get_child_count()
		transition_to_state(get_children()[next_state_index].name, data)


func transition_to_deferred(target_state: StringName, data: Dictionary) -> void:
	if not Engine.is_editor_hint():
		assert(target_state != null, Errors.NULL_NODE)

		data[State.OLD_STATE] = StringName()
		data[State.NEW_STATE] = target_state

		if current_state == null or target_state != current_state.name:
			var old_state: State = current_state
			if old_state != null:
				data[State.OLD_STATE] = old_state.name
				old_state.exit(data)
				Signals.emit_state_exited(self, current_state.name, data)

			current_state = get_node(str(target_state)) as State
			current_state.enter(data)
			Signals.emit_state_entered(self, current_state.name, data)

			if persistent_data_resource != null:
				persistent_data_resource.store_int(
					self,
					PERSISTENT_STATE_KEY,
					current_state.get_index(),
				)

		is_state_change_pending = false


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not is_instance_valid(initial_state):
		warnings.append("No initial state set")
	return warnings
