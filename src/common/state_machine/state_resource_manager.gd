extends Node

@export var _state_machine: NodePath
@export var _state_resource: Resource

@onready var state_machine: Node = get_node(_state_machine) as Node
@onready var state_resource: StateResource = _state_resource as StateResource


func _ready() -> void:
	Signals.state_entered.connect(_on_state_entered)
	Signals.state_exited.connect(_on_state_exited)

	assert(state_machine != null, Errors.NULL_NODE)
	assert(state_resource != null, Errors.NULL_RESOURCE)

	assert(state_resource.state_machine == null, Errors.RESOURCE_BUSY)
	assert(state_resource.current_state == null, Errors.RESOURCE_BUSY)
	assert(state_resource.states.is_empty(), Errors.RESOURCE_BUSY)

	state_resource.state_machine = state_machine

	for child in state_machine.get_children():
		assert(child as State != null, Errors.TYPE_ERROR)
		state_resource.states[StringName(str(child.name).to_upper())] = child


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		state_resource.state_machine = null
		state_resource.current_state = null
		state_resource.states = {}


func _on_state_entered(sender: Node, state: Node):
	if sender == state_machine:
		state_resource.current_state = state


func _on_state_exited(sender: Node, state: Node):
	if sender == state_machine:
		state_resource.current_state = null
