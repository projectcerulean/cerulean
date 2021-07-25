# Reference: https://www.gdquest.com/tutorial/godot/design-patterns/finite-state-machine
# Generic state machine. Initializes states and delegates engine callbacks
# (_process, _physics_process, _unhandled_input) to the active state.
class_name StateMachine
extends Node

# Path to the initial active state. We export it to be able to pick the initial state in the inspector.
@export var initial_state: NodePath

# Resource to hold the state. Other nodes can include this resource to query the state.
@export var state: Resource


# Enter the initial state when initializing the state machine.
func _ready() -> void:
	if not state:
		state = StateResource.new()
	assert(state as StateResource != null, Errors.NULL_RESOURCE)

	state.state_machine = self
	assert(initial_state, Errors.INVALID_ARGUMENT)
	state.state = get_node(initial_state)
	assert(state.state as State != null, Errors.INVALID_ARGUMENT)

	for child in get_children():
		child.state = state
		state.states[StringName(str(child.name).to_upper())] = child

	call_deferred(transition_to.get_method(), state.state)


# Delegate `_unhandled_input` callback to the active state.
func _unhandled_input(event: InputEvent) -> void:
	state.state.unhandled_input(event)


# Delegate `_process` callback to the active state.
func _process(delta: float) -> void:
	state.state.process(delta)

	# Change the current state
	var target_state: State = state.state.get_transition()
	if target_state:
		call_deferred(transition_to.get_method(), target_state)


# Delegate `_physics_process` callback to the active state.
func _physics_process(delta: float) -> void:
	state.state.physics_process(delta)


# This function calls the current state's exit() function, then changes the active state,
# and calls its enter function.
# It optionally takes a `data` dictionary to pass to the next state's enter() function.
func transition_to(target_state: State, data: Dictionary = {}) -> void:
	state.state.exit(target_state)
	SignalsGetter.get_signals().emit_state_exited(self, state.state)

	var old_state: State = state.state
	state.state = target_state
	state.state.enter(old_state, data)
	SignalsGetter.get_signals().emit_state_entered(self, state.state)
