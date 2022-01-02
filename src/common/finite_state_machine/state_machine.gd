# Reference: https://www.gdquest.com/tutorial/godot/design-patterns/finite-state-machine
# Generic state machine. Initializes states and delegates engine callbacks
# (_process, _physics_process, _unhandled_input) to the active state.
class_name StateMachine
extends Node

# Path to the initial active state. We export it to be able to pick the initial state in the inspector.
@export var initial_state: NodePath

# Resource to hold the state. Other nodes can include this resource to query the state.
@export var state_resource: Resource


# Enter the initial state when initializing the state machine.
func _ready() -> void:
	if not state_resource:
		state_resource = StateResource.new()
	assert(state_resource as StateResource != null, Errors.NULL_RESOURCE)

	state_resource.state_machine = self
	assert(initial_state, Errors.INVALID_ARGUMENT)
	state_resource.current_state = get_node(initial_state)
	assert(state_resource.current_state as State != null, Errors.TYPE_ERROR)

	for child in get_children():
		assert(child as State != null, Errors.INVALID_ARGUMENT)
		child.state_resource = state_resource
		state_resource.states[StringName(str(child.name).to_upper())] = child

	transition_to(state_resource.current_state)


# Delegate `_unhandled_input` callback to the active state.
func _unhandled_input(event: InputEvent) -> void:
	state_resource.current_state.unhandled_input(event)


# Delegate `_process` callback to the active state.
func _process(delta: float) -> void:
	state_resource.current_state.process(delta)

	# Change the current state
	var target_state: State = state_resource.current_state.get_transition()
	if target_state:
		transition_to(target_state)


# Delegate `_physics_process` callback to the active state.
func _physics_process(delta: float) -> void:
	state_resource.current_state.physics_process(delta)


# This function calls the current state's exit() function, then changes the active state,
# and calls its enter function.
# It optionally takes a `data` dictionary to pass to the next state's enter() function.
func transition_to(target_state: State, data: Dictionary = {}) -> void:
	call_deferred(transition_to_deferred.get_method(), target_state, data)


func lazy_transition_to(target_state: State, data: Dictionary = {}):
	if target_state != state_resource.current_state:
		transition_to(target_state, data)


func transition_to_next(data: Dictionary = {}):
	var current_state_index: int = -1
	for i in range(get_child_count()):
		if get_children()[i] == state_resource.current_state:
			current_state_index = i
			break
	assert(current_state_index >= 0, Errors.CONSISTENCY_ERROR)

	var next_state_index: int = (current_state_index + 1) % get_child_count()
	lazy_transition_to(get_children()[next_state_index], data)


func transition_to_deferred(target_state: State, data: Dictionary = {}) -> void:
	state_resource.current_state.exit(target_state)
	Signals.emit_state_exited(self, state_resource.current_state)

	var old_state: State = state_resource.current_state
	state_resource.current_state = target_state
	state_resource.current_state.enter(old_state, data)
	Signals.emit_state_entered(self, state_resource.current_state)
