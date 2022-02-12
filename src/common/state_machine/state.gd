# Reference: https://www.gdquest.com/tutorial/godot/design-patterns/finite-state-machine
# Virtual base class for all states.
class_name State
extends Node

var states: Dictionary = {}


# Virtual function. Receives events from the `_unhandled_input()` callback.
func unhandled_input(_event: InputEvent) -> void:
	pass


# Virtual function. Corresponds to the `_process()` callback.
func process(_delta: float) -> void:
	pass


# Virtual function. Corresponds to the `_physics_process()` callback.
func physics_process(_delta: float) -> void:
	pass


# Virtual function. Called by the state machine to determine if the state should be changed. Returns
# an empty string if the state should not be changed.
func get_transition() -> State:
	return null


# Virtual function. Called by the state machine upon changing the active state. The `data` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_old_state: State, _data := {}) -> void:
	pass


# Virtual function. Called by the state machine before changing the active state. Use this function
# to clean up the state.
func exit(_new_state: State) -> void:
	pass
