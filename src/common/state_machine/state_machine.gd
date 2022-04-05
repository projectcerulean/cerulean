# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later

# Generic state machine. Initializes states and delegates engine callbacks
# (_process, _physics_process, _unhandled_input) to the active state.
# Based on "Finite State Machine in Godot" by GDQuest, https://www.gdquest.com/tutorial/godot/design-patterns/finite-state-machine
class_name StateMachine
extends Node

# Path to the initial active state. We export it to be able to pick the initial state in the inspector.
@export var _initial_state: NodePath

var current_state: State

@onready var initial_state: State = get_node(_initial_state) as State


# Enter the initial state when initializing the state machine.
func _ready() -> void:
	Signals.request_state_change.connect(_on_request_state_change)
	Signals.request_state_change_next.connect(_on_request_state_change_next)
	assert(initial_state != null, Errors.NULL_NODE)
	assert(initial_state in get_children(), Errors.INVALID_ARGUMENT)

	transition_to(initial_state.name, {})


# Delegate `_unhandled_input` callback to the active state.
func _unhandled_input(event: InputEvent) -> void:
	if current_state != null:
		current_state.unhandled_input(event)


# Delegate `_process` callback to the active state.
func _process(delta: float) -> void:
	if current_state != null:
		current_state.process(delta)

		# Change the current state
		var target_state: StringName = current_state.get_transition()
		if target_state != StringName():
			transition_to(target_state, {})


# Delegate `_physics_process` callback to the active state.
func _physics_process(delta: float) -> void:
	if current_state != null:
		current_state.physics_process(delta)


func _on_request_state_change(_sender: Node, state_machine: Node, state: StringName, data: Dictionary = {}):
	if state_machine == self:
		transition_to(state, data)


func _on_request_state_change_next(_sender: Node, state_machine: Node, data: Dictionary = {}):
	if state_machine == self:
		transition_to_next(data)


# This function calls the current state's exit() function, then changes the active state,
# and calls its enter function.
# It optionally takes a `data` dictionary to pass to the next state's enter() function.
func transition_to(target_state: StringName, data: Dictionary) -> void:
	call_deferred(transition_to_deferred.get_method(), target_state, data)


func transition_to_next(data: Dictionary) -> void:
	var current_state_index: int = -1
	for i in range(get_child_count()):
		if get_children()[i] == current_state:
			current_state_index = i
			break
	assert(current_state_index >= 0, Errors.CONSISTENCY_ERROR)

	var next_state_index: int = (current_state_index + 1) % get_child_count()
	transition_to(get_children()[next_state_index].name, data)


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
