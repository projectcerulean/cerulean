# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later

# Generic state machine. Initializes states and delegates engine callbacks
# (_process, _physics_process, _unhandled_input) to the active state.
# Based on "Finite State Machine in Godot" by GDQuest, https://www.gdquest.com/tutorial/godot/design-patterns/finite-state-machine
class_name StateMachine
extends Node

enum TRANSITION_FRAME {
	PROCESS,
	PHYSICS_PROCESS,
};

# Path to the initial active state. We export it to be able to pick the initial state in the inspector.
@export var _initial_state: Node

# When to handle state transitions.
@export var transition_frame: TRANSITION_FRAME = TRANSITION_FRAME.PROCESS

# Optional data resource for storing persistent state
@export var _persistent_data: Resource

var current_state: State = null
var is_state_change_pending: bool = false

@onready var initial_state: State = _initial_state as State
@onready var persistent_data: DictionaryResource = _persistent_data as DictionaryResource
@onready var persistent_data_state_path: StringName = String(get_path()) + ":current_state"


# Enter the initial state when initializing the state machine.
func _ready() -> void:
	assert(initial_state != null, Errors.NULL_NODE)
	assert(initial_state in get_children(), Errors.INVALID_ARGUMENT)

	if _persistent_data:
		assert(persistent_data != null, Errors.NULL_RESOURCE)
		if persistent_data_state_path in persistent_data.value:
			var persistent_data_value: String = persistent_data.value.get(persistent_data_state_path)
			initial_state = get_node(persistent_data_value) as State
			assert(initial_state != null, Errors.NULL_NODE)

	transition_to_state(initial_state.name)


# Delegate `_process` callback to the active state.
func _process(delta: float) -> void:
	if current_state == null or is_state_change_pending:
		return

	current_state.process(delta)

	if transition_frame == TRANSITION_FRAME.PROCESS:
		var target_state: StringName = current_state.get_transition()
		if target_state != StringName():
			transition_to_state(target_state)


# Delegate `_physics_process` callback to the active state.
func _physics_process(delta: float) -> void:
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
	call_deferred(transition_to_deferred.get_method(), target_state, data)
	is_state_change_pending = true


func transition_to_next_state(data: Dictionary = {}) -> void:
	var current_state_index: int = -1
	for i in range(get_child_count()):
		if get_children()[i] == current_state:
			current_state_index = i
			break
	assert(current_state_index >= 0, Errors.CONSISTENCY_ERROR)

	var next_state_index: int = (current_state_index + 1) % get_child_count()
	transition_to_state(get_children()[next_state_index].name, data)


func transition_to_deferred(target_state: StringName, data: Dictionary) -> void:
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

		if persistent_data != null:
			persistent_data.value[persistent_data_state_path] = String(target_state)

	is_state_change_pending = false
