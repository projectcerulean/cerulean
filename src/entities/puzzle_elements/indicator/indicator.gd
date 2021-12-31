class_name Indicator
extends Node3D

@export var input_node_path: NodePath

@onready var input_node = get_node(input_node_path)
@onready var state_machine: StateMachine = get_node("StateMachine")


func _ready() -> void:
	Signals.state_entered.connect(self._on_state_entered)
	assert(input_node != null, Errors.NULL_NODE)
	assert(state_machine != null, Errors.NULL_NODE)
	assert(state_machine.get_child_count() == 2, Errors.CONSISTENCY_ERROR)


func _on_state_entered(sender: Node, state: Node) -> void:
	if sender == input_node.state_machine:
		state_machine.transition_to(state_machine.get_children()[state.get_index()])
