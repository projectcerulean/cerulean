# Reference: https://www.gdquest.com/tutorial/godot/design-patterns/finite-state-machine
# Generic state machine. Initializes states and delegates engine callbacks
# (_process, _physics_process, _unhandled_input) to the active state.
class_name StateMachine
extends Node

# Path to the initial active state. We export it to be able to pick the initial state in the inspector.
@export var initial_state := NodePath()

# The current active state. At the start of the game, we get the `initial_state`.
@onready var state: State = get_node(initial_state)


# Enter the initial state when initializing the state machine.
func _ready() -> void:
	assert(state != null)
	state.enter()
	Signals.emit_state_entered(self, state.name)


# Delegate `_unhandled_input` callback to the active state.
func _unhandled_input(event: InputEvent) -> void:
	state.unhandled_input(event)


# Delegate `_process` callback to the active state.
func _process(delta: float) -> void:
	state.process(delta)


# Delegate `_physics_process` callback to the active state.
func _physics_process(delta: float) -> void:
	state.physics_process(delta)

	# Change the current state
	var target_state_name: String = state.get_transition()
	if not target_state_name.is_empty():
		call_deferred(transition_to.get_method(), target_state_name)


# This function calls the current state's exit() function, then changes the active state,
# and calls its enter function.
# It optionally takes a `data` dictionary to pass to the next state's enter() function.
func transition_to(target_state_name: String, data: Dictionary = {}) -> void:
	assert(has_node(target_state_name))
	state.exit()
	Signals.emit_state_exited(self, state.name)
	state = get_node(target_state_name)
	state.enter(data)
	Signals.emit_state_entered(self, state.name)
