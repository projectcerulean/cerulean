# Reference: https://www.gdquest.com/tutorial/godot/design-patterns/finite-state-machine
# Generic state machine. Initializes states and delegates engine callbacks
# (_process, _physics_process, _unhandled_input) to the active state.
class_name StateMachine
extends Node

# Path to the initial active state. We export it to be able to pick the initial state in the inspector.
@export var _initial_state: NodePath

var current_state: State

@onready var initial_state: State = get_node(_initial_state) as State


# Enter the initial state when initializing the state machine.
func _ready() -> void:
	assert(initial_state != null, Errors.NULL_NODE)

	for child in get_children():
		for child_other in get_children():
			assert(child as State != null, Errors.TYPE_ERROR)
			assert(child_other as State != null, Errors.TYPE_ERROR)
			child.states[StringName(str(child_other.name).to_upper())] = child_other

	transition_to(initial_state)


# Delegate `_unhandled_input` callback to the active state.
func _unhandled_input(event: InputEvent) -> void:
	if current_state != null:
		current_state.unhandled_input(event)


# Delegate `_process` callback to the active state.
func _process(delta: float) -> void:
	if current_state != null:
		current_state.process(delta)

		# Change the current state
		var target_state: State = current_state.get_transition()
		if target_state != null:
			transition_to(target_state)


# Delegate `_physics_process` callback to the active state.
func _physics_process(delta: float) -> void:
	if current_state != null:
		current_state.physics_process(delta)


# This function calls the current state's exit() function, then changes the active state,
# and calls its enter function.
# It optionally takes a `data` dictionary to pass to the next state's enter() function.
func transition_to(target_state: State, data: Dictionary = {}) -> void:
	call_deferred(transition_to_deferred.get_method(), target_state, data)


func lazy_transition_to(target_state: State, data: Dictionary = {}) -> void:
	if target_state != current_state:
		transition_to(target_state, data)


func transition_to_next(data: Dictionary = {}) -> void:
	var current_state_index: int = -1
	for i in range(get_child_count()):
		if get_children()[i] == current_state:
			current_state_index = i
			break
	assert(current_state_index >= 0, Errors.CONSISTENCY_ERROR)

	var next_state_index: int = (current_state_index + 1) % get_child_count()
	lazy_transition_to(get_children()[next_state_index], data)


func transition_to_deferred(target_state: State, data: Dictionary = {}) -> void:
	assert(target_state != null, Errors.NULL_NODE)

	var old_state: State = current_state
	if old_state != null:
		old_state.exit(target_state)
		Signals.emit_state_exited(self, current_state)

	current_state = target_state
	current_state.enter(old_state, data)
	Signals.emit_state_entered(self, current_state)
